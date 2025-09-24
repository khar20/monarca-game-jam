# player.gd
extends CharacterBody3D

# properties
const SPEED: float = 4.0
const JUMP_VELOCITY: float = 4.5
const SENS: float = 0.001
const ACCELERATION: float = 0.1
const FRICTION: float = 0.5

# states
enum States { MOVE, PLAYING }

# default initial state
var state = States.MOVE

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	# initial mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
			print("move")
			_move_state(delta)
		States.PLAYING:
			print("playing")
			_playing_state(delta)

# states logic
func _move_state(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# directional input
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# movement
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)
		velocity.z = lerp(velocity.z, 0.0, FRICTION)

	move_and_slide()

func _playing_state(_delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION)
	velocity.z = lerp(velocity.z, 0.0, FRICTION)
	move_and_slide()
