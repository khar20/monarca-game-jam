extends Area2D

# signal
signal coin_collected

# default properties
var initial_position: Vector2
var time_passed: float = 0.0
var float_amplitude: float = 2.0
var float_speed: float = 3.0
var rotation_speed: float = 2.0

func _ready() -> void:
	initial_position = position

func _process(delta: float) -> void:
	time_passed += delta
	var float_offset: float = sin(time_passed * float_speed) * float_amplitude
	position.y = initial_position.y + float_offset
	
func _on_body_entered(_body: Node2D) -> void:
	coin_collected.emit()
	Wwise.post_event_id(AK.EVENTS.PLAY_COINPICKUP, self)
	queue_free()
