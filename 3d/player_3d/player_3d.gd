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

# States
enum States { MOVE, PLAYING }
var state = States.MOVE

# OnReady variables
@onready var camera: Camera3D = $Camera3D
@onready var footstep_timer: Timer = $FootstepTimer
@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay

# Private variables
var _current_fs_material

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_initialize_wwise()
	_setup_footstep_timer()

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

func set_state(new_state: States) -> void:
	if state == new_state:
		return

	state = new_state
	match state:
		States.MOVE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		States.PLAYING:
			velocity = Vector3.ZERO
			footstep_timer.stop()

func _unhandled_input(event: InputEvent) -> void:
	if state != States.MOVE:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("interact"):
		_interact()

func _physics_process(delta: float) -> void:
	match state:
		States.MOVE:
			_move_state(delta)
		States.PLAYING:
			_playing_state(delta)

func _move_state(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		footstep_timer.stop()

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed: float = SPEED
	if is_on_floor():
		var floor_normal: Vector3 = get_floor_normal()
		var floor_angle: float = rad_to_deg(acos(floor_normal.dot(Vector3.UP)))
		if floor_angle > 0.1:
			if direction.dot(floor_normal) > 0:
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

	move_and_slide()

func _playing_state(_delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, FRICTION)
	move_and_slide()

func _interact() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider.has_method("start_game"):
			collider.call("start_game", self)

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
