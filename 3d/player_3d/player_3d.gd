# player.gd
extends CharacterBody3D

# properties
const SPEED: float = 1.0
const JUMP_VELOCITY: float = 4.5
const SENS: float = 0.001
const ACCELERATION: float = 0.5
const FRICTION: float = 0.5
const FOOTSTEP_INTERVAL: float = 0.8
const SLOPE_SPEED_MULTIPLIER: float = 0.7

var current_fs_material

# states
enum States { MOVE, PLAYING }

# default initial state
var state = States.MOVE

@onready var camera: Camera3D = $Camera3D
@onready var footstep_timer: Timer = $FootstepTimer

func _ready() -> void:
	# initial mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Wwise.register_game_obj(self, self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.NEW_SOUNDBANK)
	Wwise.set_switch_id(AK.SWITCHES.FS_MATERIAL_SWITCH.GROUP, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE, self)
	Wwise.set_switch_id(AK.SWITCHES.ROOMTONE_SWITCH.GROUP, AK.SWITCHES.ROOMTONE_SWITCH.SWITCH.LIVING, self)
	current_fs_material = AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE
	
	# footstep setup
	footstep_timer.wait_time = FOOTSTEP_INTERVAL
	footstep_timer.one_shot = false
	footstep_timer.connect("timeout", _on_FootstepTimer_timeout)

# state changer
func set_state(new_state: States) -> void:
	# if already in new state dont change
	if state == new_state:
		return

	state = new_state
	match state:
		States.MOVE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		States.PLAYING:
			velocity = Vector3.ZERO
			footstep_timer.stop()


# input handler
func _unhandled_input(event: InputEvent) -> void:
	if state != States.MOVE:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENS)
		camera.rotate_x(-event.relative.y * SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# states router
func _physics_process(delta: float) -> void:
	match state:
		States.MOVE:
			_move_state(delta)
		States.PLAYING:
			_playing_state(delta)

# states logic
func _move_state(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		footstep_timer.stop()

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# directional input
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var current_speed: float = SPEED
	if is_on_floor():
		var floor_normal: Vector3 = get_floor_normal()
		var floor_angle: float = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
		if floor_angle > 0.1: # Check if on a slope
			var is_moving_downhill: float = direction.dot(floor_normal) > 0
			if is_moving_downhill:
				current_speed *= SLOPE_SPEED_MULTIPLIER

	# movement
	if direction and is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION)
		if footstep_timer.is_stopped():
			footstep_timer.start()
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		velocity.z = lerp(velocity.z, 0.0, FRICTION)
		footstep_timer.stop()

	move_and_slide()

func _playing_state(_delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION)
	velocity.z = lerp(velocity.z, 0.0, FRICTION)
	move_and_slide()

func _on_FootstepTimer_timeout() -> void:
	Wwise.post_event_id(AK.EVENTS.PLAY_PLAYER_FS, self)


func _on_wood_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
		
	if current_fs_material != AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.WOOD:
		print("wood")
		Wwise.set_switch_id(AK.SWITCHES.FS_MATERIAL_SWITCH.GROUP, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.WOOD, self)
		current_fs_material = AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.WOOD


func _on_tile_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D:
		return
	
	if current_fs_material != AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE:
		print("tile")
		Wwise.set_switch_id(AK.SWITCHES.FS_MATERIAL_SWITCH.GROUP, AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE, self)
		current_fs_material = AK.SWITCHES.FS_MATERIAL_SWITCH.SWITCH.TILE
