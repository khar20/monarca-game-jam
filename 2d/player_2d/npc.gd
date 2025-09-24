extends Area2D

@onready var exclamation_mark = $ExclamationMark

var is_player_2d_close = false

func _process(delta: float) -> void:
	if is_player_2d_close and Input.is_action_just_pressed("ui_accept"):
		print("Conversar")

func _on_area_entered(area: Area2D) -> void:
	exclamation_mark.visible = true
	is_player_2d_close = true


func _on_area_exited(area: Area2D) -> void:
	exclamation_mark.visible = false
	is_player_2d_close = false
