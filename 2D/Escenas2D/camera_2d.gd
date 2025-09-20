extends Camera2D

@onready var player: CharacterBody2D = get_parent()
var initial_y_position: float
var camera_offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Guardamos la posición Y inicial de la cámara
	initial_y_position = global_position.y
	# Guardamos el offset inicial de la cámara respecto al jugador
	camera_offset = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		# Solo seguimos al jugador en el eje X
		# Mantenemos la posición Y fija en la posición inicial
		global_position.x = player.global_position.x + camera_offset.x
		global_position.y = initial_y_position
