extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

# default properties
var initial_position: Vector2
var time_passed: float = 0.0
var float_amplitude: float = 1.0 
var float_speed: float = 2.0      
var rotation_speed: float = 2.0

func _ready() -> void:
	# Guardamos la posición inicial de la moneda
	initial_position = position

func _process(delta: float) -> void:
	time_passed += delta
	
	# Movimiento flotante usando una función seno
	var float_offset = sin(time_passed * float_speed) * float_amplitude
	position.y = initial_position.y + float_offset
	
	# Rotación continua de la moneda
	rotation += rotation_speed * delta
