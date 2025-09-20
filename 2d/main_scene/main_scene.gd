extends Node2D

@onready var player = $Player2D
@onready var camera = $Camera2D

func _process(_delta: float) -> void:
	camera.position.x = player.position.x
