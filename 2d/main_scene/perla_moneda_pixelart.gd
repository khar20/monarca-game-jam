extends Sprite2D

# Variables para el movimiento
var initial_position: Vector2
var time_passed: float = 0.0
var float_amplitude: float = 1.0  # Altura del movimiento flotante
var float_speed: float = 2.0       # Velocidad del movimiento flotante
var rotation_speed: float = 2.0    # Velocidad de rotación

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Guardamos la posición inicial de la moneda
	initial_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	# Movimiento flotante usando una función seno
	var float_offset = sin(time_passed * float_speed) * float_amplitude
	position.y = initial_position.y + float_offset
	
	# Rotación continua de la moneda
	rotation += rotation_speed * delta
