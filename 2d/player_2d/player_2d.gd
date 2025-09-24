extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const LADDER_SPEED: float = 200.0

var base_y_offset: float = -100.0
var camera_y_position: float
var camera_initialized: bool = false

var is_on_ladder: bool = false
var ladder_tilemap: TileMapLayer

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	camera.make_current()
	ladder_tilemap = get_node("../Frente")

func _physics_process(delta: float) -> void:
	check_ladder_collision()
	
	if is_on_ladder:
		handle_ladder_movement()
	else:
		handle_normal_movement(delta)

	move_and_slide()
	
	var direction: float = Input.get_axis("left", "right")
	update_animations(direction)
	
func handle_normal_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_ladder_movement() -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		is_on_ladder = false  
		return
	
	velocity.y = 0
	
	var vertical_input: float = Input.get_axis("forward", "backward")
	if vertical_input != 0:
		velocity.y = vertical_input * LADDER_SPEED  
	
	var horizontal_input: float = Input.get_axis("left", "right")
	if horizontal_input != 0:
		velocity.x = horizontal_input * SPEED * 0.7 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func check_ladder_collision() -> void:
	if not ladder_tilemap:
		is_on_ladder = false
		return
	
	var tile_pos: Vector2i = ladder_tilemap.local_to_map(global_position)
	
	var tile_data: int = ladder_tilemap.get_cell_source_id(tile_pos)
	
	is_on_ladder = (tile_data == 15)
	
	if not is_on_ladder:
		var tile_above: Vector2i = ladder_tilemap.local_to_map(global_position + Vector2(0, -16))
		var tile_below: Vector2i = ladder_tilemap.local_to_map(global_position + Vector2(0, 16))
		is_on_ladder = (ladder_tilemap.get_cell_source_id(tile_above) == 15) or (ladder_tilemap.get_cell_source_id(tile_below) == 15)
	
func _process(_delta: float) -> void:
	camera.global_position.x = global_position.x
		
	if not camera_initialized:
		camera_y_position = global_position.y + base_y_offset
		camera_initialized = true
		
	camera.global_position.y = camera_y_position

func update_animations(direction: float) -> void:
	if direction != 0:
		animated_sprite.flip_h = direction < 0
	
	if is_on_ladder and Input.get_axis("forward", "backward") != 0:
		animated_sprite.play("run")  
	elif not is_on_floor() and not is_on_ladder:
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("default")
