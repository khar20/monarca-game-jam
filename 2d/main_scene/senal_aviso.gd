extends StaticBody2D

@onready var area_2d = $Area2D
var dialog_shown = false

func _ready():
	# Conectar las señales del Area2D
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Verificar si el cuerpo que entró es el jugador
	if body.name == "Player2D" and not dialog_shown:
		dialog_shown = true
		# Iniciar el diálogo usando Dialogic
		Dialogic.start("res://2d/Dialogos/cartel_aviso.dtl")

func _on_body_exited(body):
	# Resetear la bandera cuando el jugador se aleje
	if body.name == "Player2D":
		dialog_shown = false