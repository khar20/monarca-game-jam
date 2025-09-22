extends Camera2D

@onready var player = get_parent()
var base_y_offset: float = -100.0  # Offset Y relativo al jugador
var camera_y_position: float
var camera_initialized: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configuramos la cámara como actual
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		# Siempre seguimos al jugador en X
		global_position.x = player.global_position.x
		
		# Inicializamos la posición Y solo una vez
		if not camera_initialized:
			camera_y_position = player.global_position.y + base_y_offset
			camera_initialized = true
		
		# SIEMPRE mantenemos la posición Y fija, sin importar si salta o cae
		global_position.y = camera_y_position
