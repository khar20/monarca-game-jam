# player.gd
extends CharacterBody3D

# Constants
const SPEED: float = 1.0
const JUMP_VELOCITY: float = 4.5
const SENSITIVITY: float = 0.002
const ACCELERATION: float = 0.25
const FRICTION: float = 0.1
const FOOTSTEP_INTERVAL: float = 0.5
const SLOPE_SPEED_MULTIPLIER: float = 0.8

# Sprint
const SPRINT_SPEED_MULTIPLIER: float = 2.0
const SPRINT_PRESS_TIME_WINDOW: float = 0.3
const MIN_PRESSES_TO_SPRINT: int = 2

# States
enum State { FREELOOK, INTERACTING }
var current_state: State = State.FREELOOK

# Camera interpolation
var target_camera_transform: Transform3D
var initial_camera_transform: Transform3D
var freelook_camera_local_transform: Transform3D # <-- FIX: Store original camera position
var camera_lerp_speed: float = 2.0
var camera_lerp_t: float = 0.0

# OnReady variables
@onready var camera: Camera3D = $Camera3D
@onready var footstep_timer: Timer = $FootstepTimer
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay

# Private variables
var _current_fs_material
var _sprint_press_count: int = 0
var _last_sprint_press_time: float = 0.0
var _is_sprinting: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_initialize_wwise()
	_setup_footstep_timer()
	
	freelook_camera_local_transform = camera.transform

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

func _input(event: InputEvent) -> void:
	match current_state:
		State.FREELOOK:
			_input_freelook(event)
		State.INTERACTING:
			if Input.is_action_just_pressed("ui_cancel"):
				set_state(State.FREELOOK)

func _input_freelook(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
	if Input.is_action_just_pressed("interact"):
		check_interact()
		
	if Input.is_action_just_pressed("sprint"):
		var current_time: float = Time.get_ticks_msec() / 1000.0
		if current_time - _last_sprint_press_time < SPRINT_PRESS_TIME_WINDOW:
			_sprint_press_count += 1
		else:
			_sprint_press_count = 1
		_last_sprint_press_time = current_time

func _physics_process(delta: float) -> void:
	match current_state:
		State.FREELOOK:
			process_freelook(delta)
		State.INTERACTING:
			process_interacting(delta)

#region process

func process_freelook(delta: float) -> void:
	# FIX: Also process camera interpolation when returning to freelook
	if target_camera_transform:
		camera_lerp_t = clamp(camera_lerp_t + delta * camera_lerp_speed, 0, 1)
		camera.global_transform = initial_camera_transform.interpolate_with(target_camera_transform, camera_lerp_t)
		if camera_lerp_t >= 1.0:
			# Snap to final local position to ensure accuracy
			camera.transform = freelook_camera_local_transform
			target_camera_transform = Transform3D() # Clear the transform
		return # Don't allow movement while camera is transitioning back

	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta # Using a standard gravity value
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
	
func process_interacting(delta: float) -> void:
	# Stop player movement completely
	velocity = Vector3.ZERO
	move_and_slide()

	# Process camera interpolation
	if target_camera_transform:
		camera_lerp_t = clamp(camera_lerp_t + delta * camera_lerp_speed, 0, 1)
		camera.global_transform = initial_camera_transform.interpolate_with(target_camera_transform, camera_lerp_t)
	
		if camera_lerp_t >= 1.0:
			target_camera_transform = Transform3D() # Clear the transform to stop processing

#endregion

func set_state(new_state: State) -> void:
	if new_state == current_state:
		return
		
	match new_state:
		State.FREELOOK:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# Path to SubViewport might need to be adjusted based on your scene tree
			get_tree().get_root().get_node("Main/Computer/SubViewport").set_disable_input(true)
			
			# FIX: Correctly set up the reverse camera interpolation
			initial_camera_transform = camera.global_transform
			# We calculate the target by getting the player's global transform and applying the camera's original local offset
			target_camera_transform = global_transform * freelook_camera_local_transform
			camera_lerp_t = 0
			
		State.INTERACTING:
			# FIX: Stop all player movement immediately
			velocity = Vector3.ZERO
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # You may want the mouse visible to interact with the 2D game
			
			var computer = interaction_ray.get_collider()
			if computer and computer.is_in_group("computer"):
				var screen_camera = computer.get_node("Camera3D") # Assumes computer has a camera named "Camera3D"
				initial_camera_transform = camera.global_transform
				target_camera_transform = screen_camera.global_transform
				camera_lerp_t = 0
				# Path to SubViewport might need to be adjusted based on your scene tree
				get_tree().get_root().get_node("Main/Computer/SubViewport").set_disable_input(false)

	current_state = new_state

func check_interact() -> void:
	if not interaction_ray.is_colliding():
		return
		
	var collider: Object = interaction_ray.get_collider()
	
	if collider.is_in_group("computer"):
		set_state(State.INTERACTING)


	


func _playing_state(_delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, FRICTION)
	move_and_slide()

#region footstep

func _on_footstep_timer_timeout() -> void:
	Wwise.post_event_id(AK.EVENTS.PLAY_PLAYER_FS, self)

func _on_body_entered(body: Node3D, material_switch) -> void:
	if body != self:
		return
	
	if _current_fs_material != material_switch:
		Wwise.set_switch_id(AK.SWITCHES.FS_MATERIAL_SWITCH.GROUP, material_switch, self)
		_current_fs_material = material_switch

func _on_wood_body_entered(body: Node3D) -> void:
	_on_body_entered(body, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.WOOD)

func _on_tile_body_entered(body: Node3D) -> void:
	_on_body_entered(body, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE)

#endregion
