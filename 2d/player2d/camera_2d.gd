extends Camera2D

@onready var player: CharacterBody2D = get_parent()

var base_y_offset: float = -100.0
var camera_y_position: float
var camera_initialized: bool = false

func _ready() -> void:
	make_current()

func _process(delta: float) -> void:
	if player:
		global_position.x = player.global_position.x
		
		if not camera_initialized:
			camera_y_position = player.global_position.y + base_y_offset
			camera_initialized = true
		
		# camera keeps y axis
		global_position.y = camera_y_position
