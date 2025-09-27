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
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# --- Public Variables ---
var focused_interactable: Interactable
var held_object: Node3D = null

# --- Private Variables ---
var _controls_enabled: bool = true
var _current_fs_material: int
var _sprint_press_count: int = 0
var _last_sprint_press_time: float = 0.0
var _is_sprinting: bool = false

var tween_in_progress: bool = false

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
	
	if tween_in_progress:
		return
	
	if not _controls_enabled:
		# If controls are disabled, kill velocity and do nothing else.
		#velocity = velocity.lerp(Vector3.ZERO, FRICTION)
		#move_and_slide()
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
	#tween.tween_property(camera, "global_transform", target_transform, duration)
	tween.tween_property(camera, "global_transform", target_transform, duration)
	
# Place this function in your player_3d.gd script

func tween_camera_to_look_at(target_point: Vector3, duration: float) -> void:
	# This function smoothly rotates the camera to look at a world-space point
	# without changing the camera's position.
	
	# 1. Create the final transform we want to reach.
	#    The .looking_at() method creates a copy of the transform that is
	#    rotated to point towards the target_point. We use Vector3.UP as a reference
	#    to keep the camera from rolling sideways.
	var final_transform: Transform3D = camera.global_transform.looking_at(target_point, Vector3.UP)
	
	# 2. Create and configure the tween.
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 3. Tween the entire "global_transform" property.
	#    Godot will handle the complex rotation interpolation for you.
	tween.tween_property(camera, "global_transform", final_transform, duration)
	
func tween_body_to_transform(target_transform: Transform3D, duration: float) -> void:
	# This function tweens the entire CharacterBody3D, which is better for
	# interactions that require the player to be in a specific spot.
	tween_in_progress = true
	velocity.y = 0
	collision_shape.disabled = true
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_transform", target_transform, duration)
	
	#tween_camera_to_look_at(camera_target, duration)
	await tween.finished
	tween_in_progress = false
	
# Add this function to your player_3d.gd script.

func tween_body_and_camera_look_at(body_target_transform: Transform3D, camera_look_at_point: Vector3, duration: float) -> void:
	# This function smoothly moves the player body to a target transform while
	# simultaneously rotating the camera to look at a specific world point.
	
	if tween_in_progress:
		return
		
	tween_in_progress = true
	collision_shape.disabled = true
	velocity.y = 0
	
	# --- 1. Calculate the Camera's Final Transform ---
	# We need to figure out where the camera will be AND how it will be rotated
	# at the end of the movement.
	
	# First, find the camera's final position. This is the body's target position
	# plus the camera's local offset from the body.
	var final_camera_position: Vector3 = body_target_transform.origin + (body_target_transform.basis * camera.transform.origin)
	
	# Now, create a temporary transform at that final position.
	var final_camera_transform: Transform3D = Transform3D(Basis(), final_camera_position)
	
	# Finally, rotate this transform to look at the target point.
	final_camera_transform = final_camera_transform.looking_at(camera_look_at_point, Vector3.UP)

	# --- 2. Create and Run Tweens in Parallel ---
	
	# Tween for the player's body
	var body_tween: Tween = create_tween()
	body_tween.set_parallel() # Ensures tweens added to this run at the same time
	body_tween.set_trans(Tween.TRANS_SINE)
	body_tween.set_ease(Tween.EASE_IN_OUT)
	body_tween.tween_property(self, "global_transform", body_target_transform, duration)
	
	# Tween for the camera
	# By adding it to the same parallel tween, it will run alongside the body's movement.
	body_tween.tween_property(camera, "global_transform", final_camera_transform, duration)
	
	# --- 3. Wait for the movement to finish and clean up ---
	await body_tween.finished
	
	collision_shape.disabled = false
	tween_in_progress = false
	
func tween_body_to_position(target_position: Vector3, duration: float) -> void:
	# This function tweens the entire CharacterBody3D, which is better for
	# interactions that require the player to be in a specific spot.
	tween_in_progress = true
	velocity.y = 0
	collision_shape.disabled = true
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target_position, duration)
	#global_position = target_position
	await tween.finished
	
	#velocity.y = 9.8
	#collision_shape.disabled = false
	tween_in_progress = false

func begin_subviewport_interaction(viewport: SubViewport) -> void:
	pass
	set_controls_enabled(false) # Disable player movement
	_active_subviewport = viewport
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Show the mouse for the 2D game

func end_subviewport_interaction() -> void:
	_active_subviewport = null
	set_controls_enabled(true) # Re-enable player movement
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Capture the mouse for freelook

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

func _on_footstep_timer_timeout() -> void:
	Wwise.post_event_id(AK.EVENTS.PLAY_PLAYER_FS, self)
	
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
