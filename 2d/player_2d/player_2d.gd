extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Handle animations
	update_animations(direction)

func update_animations(direction: float) -> void:
	# Manejar el flip del sprite según la dirección (siempre que haya movimiento)
	if direction != 0:
		animated_sprite.flip_h = direction < 0
	
	# Si está en el aire (saltando o cayendo)
	if not is_on_floor():
		animated_sprite.play("Saltar")
	# Si se está moviendo horizontalmente
	elif direction != 0:
		animated_sprite.play("Correr")
	# Si está quieto
	else:
		animated_sprite.play("Default")

# Camera follow variables
var base_y_offset: float = -100.0
var camera_y_position: float
var camera_initialized: bool = false

func _ready() -> void:
	camera.make_current()

func _process(_delta: float) -> void:
	# Camera follows player horizontally
	camera.global_position.x = global_position.x
		
	if not camera_initialized:
		camera_y_position = global_position.y + base_y_offset
		camera_initialized = true
		
	# camera keeps y axis
	camera.global_position.y = camera_y_position
