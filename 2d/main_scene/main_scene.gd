extends Node2D

@onready var player = $Player2D
@onready var camera = $Camera2D
@onready var crt_shader = $CanvasLayer/TextureRect

func _ready() -> void:
	# Iniciar el diálogo de bienvenida
	Dialogic.start("res://2d//Dialogos/timeline.dtl")

func _process(_delta: float) -> void:
	# camera.position.x = player.position.x  # Comentado para mantener la cámara fija
	crt_shader.position = camera.position
