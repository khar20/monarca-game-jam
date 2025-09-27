extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const LADDER_SPEED: float = 200.0
const FOOTSTEP_INTERVAL: float = 0.3 # Time between footstep sounds

# A value of 0.5 will cut the upward velocity in half when the jump button is released.
const SHORT_JUMP_VELOCITY_MULTIPLIER: float = 0.5

var is_on_ladder: bool = false
var ladder_tilemap: TileMapLayer

# --- Private Variables ---
var _was_in_air: bool = false # Used to detect the moment of landing

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var counter_label: Label = $Camera2D/CanvasLayer/CounterUI/CounterLabel
@onready var footstep_timer: Timer = $FootstepTimer


func _ready() -> void:
	ladder_tilemap = get_node("../Frente")
	update_counter_display()
	Wwise.register_game_obj(self, self.name)
	
	# Setup the timer for footstep sounds
	footstep_timer.wait_time = FOOTSTEP_INTERVAL
	footstep_timer.one_shot = false
	footstep_timer.connect("timeout", _on_footstep_timer_timeout)


func _physics_process(delta: float) -> void:
	# --- Landing Sound Check ---
	# This must be checked before gravity is applied for the current frame.
	# If we were in the air last frame, but we are on the floor now, we have landed.
	if _was_in_air and is_on_floor():
		Wwise.post_event_id(AK.EVENTS.MPLAY_JUMPLAND, self) # Play landing sound

	check_ladder_collision()

	# Get player input once to avoid redundant calls
	var direction: float = Input.get_axis("left", "right")

	if is_on_ladder:
		# --- Ladder Movement Logic ---
		velocity.y = 0
		footstep_timer.stop() # No footsteps on ladder
		
		# Jump off the ladder
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			Wwise.post_event_id(AK.EVENTS.MPLAY_JUMP, self) # Play jump sound
			is_on_ladder = false
		else:
			# Vertical ladder movement
			var vertical_input: float = Input.get_axis("forward", "backward")
			velocity.y = vertical_input * LADDER_SPEED
			
			# Horizontal movement on ladder (slower)
			if direction:
				velocity.x = direction * SPEED * 0.7
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# --- Normal Movement Logic ---
		# Add gravity
		if not is_on_floor():
			velocity.y += get_gravity().y * delta

		# Handle Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			Wwise.post_event_id(AK.EVENTS.MPLAY_JUMP, self) # Play jump sound

		# Handle variable jump height
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= SHORT_JUMP_VELOCITY_MULTIPLIER

		# Horizontal movement
		if direction:
			velocity.x = direction * SPEED
			# Start footstep timer only if on floor and moving
			if is_on_floor() and footstep_timer.is_stopped():
				footstep_timer.start()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			footstep_timer.stop()
			
		# Stop footstep sound if in the air
		if not is_on_floor():
			footstep_timer.stop()

	move_and_slide()
	update_animations(direction)

	# --- Update State for Next Frame ---
	# Record if the player is in the air now, so we can check it next frame.
	_was_in_air = not is_on_floor()


# This function is called every time the footstep_timer times out
func _on_footstep_timer_timeout() -> void:
	Wwise.post_event_id(AK.EVENTS.MPLAY_FS, self)

func check_ladder_collision() -> void:
	# Note: This method of checking for a tile's source_id is brittle.
	# A more robust solution is to use a custom data layer on your TileMap
	# to specifically mark which tiles are ladders.
	if not ladder_tilemap:
		is_on_ladder = false
		return
	
	var tile_pos: Vector2i = ladder_tilemap.local_to_map(global_position)
	var tile_data: int = ladder_tilemap.get_cell_source_id(tile_pos)
	is_on_ladder = (tile_data == 15)
	
	# This allows the player to "snap" to the ladder from slightly above or below it
	if not is_on_ladder:
		var tile_above: Vector2i = ladder_tilemap.local_to_map(global_position + Vector2(0, -16))
		var tile_below: Vector2i = ladder_tilemap.local_to_map(global_position + Vector2(0, 16))
		var tile_above_data: int = ladder_tilemap.get_cell_source_id(tile_above)
		var tile_below_data: int = ladder_tilemap.get_cell_source_id(tile_below)
		is_on_ladder = (tile_above_data == 15) or (tile_below_data == 15)


func update_animations(direction: float) -> void:
	if direction != 0:
		animated_sprite.flip_h = direction < 0
	
	if is_on_ladder and Input.get_axis("forward", "backward") != 0:
		animated_sprite.play("run") # Consider a "climb" animation here
	elif not is_on_floor() and not is_on_ladder:
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("default")


func update_counter_display() -> void:
	print("a")
	if counter_label:
		# Obtener el contador desde el scene principal
		var scene_2d: Node = get_node("../")
		if scene_2d and scene_2d.has_method("get_coin_count"):
			counter_label.text = "x " + str(scene_2d.get_coin_count())
		else:
			counter_label.text = "x 0"
