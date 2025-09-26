extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const LADDER_SPEED: float = 200.0

# Add a multiplier to control how much the jump is shortened.
# A value of 0.5 will cut the upward velocity in half when the jump button is released.
const SHORT_JUMP_VELOCITY_MULTIPLIER: float = 0.5

var is_on_ladder: bool = false
var ladder_tilemap: TileMapLayer

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var counter_label: Label = $Camera2D/CanvasLayer/CounterUI/CounterLabel

func _ready() -> void:
	ladder_tilemap = get_node("../Frente")
	update_counter_display()

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
		velocity.y += get_gravity().y * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# If the jump button is released while the character is moving upwards,
	# reduce the upward velocity to perform a shorter jump.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= SHORT_JUMP_VELOCITY_MULTIPLIER

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

func update_counter_display() -> void:
	if counter_label:
		# Obtener el contador desde el scene principal
		var scene_2d: Node = get_node("../")
		if scene_2d and scene_2d.has_method("get_coin_count"):
			counter_label.text = "x " + str(scene_2d.get_coin_count())
		else:
			counter_label.text = "x 0"
