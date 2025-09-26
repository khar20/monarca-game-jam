# player.gd
extends CharacterBody3D

# --- Constants ---
const SPEED: float = 1.0
const JUMP_VELOCITY: float = 4.5
const SENSITIVITY: float = 0.002
const ACCELERATION: float = 0.25
const FRICTION: float = 0.1
const FOOTSTEP_INTERVAL: float = 0.5
const SLOPE_SPEED_MULTIPLIER: float = 0.8

# Sprint
const SPRINT_SPEED_MULTIPLIER: float = 3.0
const SPRINT_PRESS_TIME_WINDOW: float = 0.3
const MIN_PRESSES_TO_SPRINT: int = 2

# --- OnReady Variables ---
@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
@onready var hold_point: Node3D = $Camera3D/HoldPoint
@onready var footstep_timer: Timer = $FootstepTimer

# --- Public Variables ---
var focused_interactable: Interactable
var held_object: Node3D = null

# --- Private Variables ---
var _controls_enabled: bool = true
var _current_fs_material: int
var _sprint_press_count: int = 0
var _last_sprint_press_time: float = 0.0
var _is_sprinting: bool = false

var _active_subviewport: SubViewport = null

# --- Engine Functions ---
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_initialize_wwise()
	_setup_footstep_timer()

func _input(event: InputEvent) -> void:
	if _active_subviewport:
		_active_subviewport.push_input(event)
		return
		
	if not _controls_enabled:
		return
	
	# Freelook mouse movement is handled here.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# Interaction input.
	if Input.is_action_just_pressed("interact"):
		if held_object:
			drop_object()
		elif focused_interactable:
			focused_interactable.do_interact(self)
			
	# Sprinting input.
	if Input.is_action_just_pressed("sprint"):
		var current_time: float = Time.get_ticks_msec() / 1000.0
		if current_time - _last_sprint_press_time < SPRINT_PRESS_TIME_WINDOW:
			_sprint_press_count += 1
		else:
			_sprint_press_count = 1
		_last_sprint_press_time = current_time
		
	# Temporary: allow exiting computer view
	if Input.is_action_just_pressed("ui_cancel"):
		if focused_interactable and focused_interactable.is_in_group("computer_interaction"):
			focused_interactable.end_interaction(self)

func _physics_process(delta: float) -> void:
	_update_focused_interactable()
	
	if not _controls_enabled:
		# If controls are disabled, kill velocity and do nothing else.
		velocity = velocity.lerp(Vector3.ZERO, FRICTION)
		move_and_slide()
		return
		
	# --- Movement Logic (only runs if controls are enabled) ---
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		footstep_timer.stop()
		_is_sprinting = false

	# Sprinting check
	var current_time: float = Time.get_ticks_msec() / 1000.0
	if current_time - _last_sprint_press_time > SPRINT_PRESS_TIME_WINDOW:
		_is_sprinting = false
		_sprint_press_count = 0

	if _sprint_press_count >= MIN_PRESSES_TO_SPRINT:
		_is_sprinting = true
		
	# Movement
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed: float = SPEED
	if _is_sprinting:
		current_speed *= SPRINT_SPEED_MULTIPLIER

	if is_on_floor():
		var floor_normal: Vector3 = get_floor_normal()
		var floor_angle: float = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
		if floor_angle > 0.1 and direction.dot(floor_normal) > 0:
			current_speed *= SLOPE_SPEED_MULTIPLIER

	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION)
		if is_on_floor() and footstep_timer.is_stopped():
			footstep_timer.start()
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		velocity.z = lerp(velocity.z, 0.0, FRICTION)
		footstep_timer.stop()
		_is_sprinting = false
		
	move_and_slide()
	
	# Update held object's position
	if held_object:
		held_object.global_position = hold_point.global_position
		held_object.global_rotation = hold_point.global_rotation


# --- Public Functions (called by other objects) ---

func set_controls_enabled(is_enabled: bool) -> void:
	_controls_enabled = is_enabled

func tween_camera_to_transform(target_transform: Transform3D, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "global_transform", target_transform, duration)
	
func tween_body_to_transform(target_transform: Transform3D, duration: float) -> void:
	# This function tweens the entire CharacterBody3D, which is better for
	# interactions that require the player to be in a specific spot.
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_transform", target_transform, duration)

func begin_subviewport_interaction(viewport: SubViewport) -> void:
	set_controls_enabled(false) # Disable player movement
	_active_subviewport = viewport
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Show the mouse for the 2D game

func end_subviewport_interaction() -> void:
	_active_subviewport = null
	set_controls_enabled(true) # Re-enable player movement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Capture the mouse for freelook

func pick_up_object(obj: Node3D) -> void:
	if held_object:
		return # Already holding something
		
	held_object = obj
	
	# Disable the object's physics and collision
	if obj is RigidBody3D:
		obj.freeze = true
	obj.get_node("CollisionShape3D").disabled = true
	
	# Prevent re-interacting with the object while holding it
	if obj.has_node("Interactable"):
		obj.get_node("Interactable").monitoring = false

func drop_object() -> void:
	if not held_object:
		return
		
	# Re-enable physics and collision
	if held_object is RigidBody3D:
		held_object.freeze = false
		# Optional: apply a small force to "throw" the object
		held_object.apply_central_impulse(camera.global_transform.basis.z * -2.0)
	held_object.get_node("CollisionShape3D").disabled = false
	
	# Allow interacting with the object again
	if held_object.has_node("Interactable"):
		held_object.get_node("Interactable").monitoring = true
		
	held_object = null

# --- Private Functions ---

func _update_focused_interactable() -> void:
	var new_focus: Object = interaction_ray.get_collider() if interaction_ray.is_colliding() else null
	
	# Check if the collider is actually an Interactable
	if new_focus and not new_focus is Interactable:
		new_focus = null

	if new_focus != focused_interactable:
		if focused_interactable:
			focused_interactable.emit_signal("unfocused", self)
		
		focused_interactable = new_focus
		
		if focused_interactable:
			focused_interactable.emit_signal("focused", self)
	
#region setup

func _initialize_wwise() -> void:
	Wwise.register_game_obj(self, self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.NEW_SOUNDBANK)
	Wwise.set_switch_id(AK.SWITCHES.FS_MATERIAL_SWITCH.GROUP, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE, self)
	Wwise.set_switch_id(AK.SWITCHES.ROOMTONE_SWITCH.GROUP, AK.SWITCHES.ROOMTONE_SWITCH.SWITCH.LIVING, self)
	_current_fs_material = AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE

func _setup_footstep_timer() -> void:
	footstep_timer.wait_time = FOOTSTEP_INTERVAL
	footstep_timer.one_shot = false
	#footstep_timer.connect("timeout", _on_footstep_timer_timeout)

#endregion
