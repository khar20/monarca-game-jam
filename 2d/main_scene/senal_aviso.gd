extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var dialogue_balloon: Control = $DialogueBalloon
var dialog_shown: bool = false

func _ready() -> void:
	# Conectar las señales del Area2D
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
	
	# Asegurar que el globo esté oculto al inicio
	if dialogue_balloon:
		dialogue_balloon.visible = false

func _on_body_entered(body) -> void:
	# Verificar si el cuerpo que entró es el jugador
	if body.name == "Player2D" and not dialog_shown:
		dialog_shown = true
		show_dialogue_balloon()

func _on_body_exited(body) -> void:
	# Resetear la bandera cuando el jugador se aleje
	if body.name == "Player2D":
		dialog_shown = false
		hide_dialogue_balloon()

func show_dialogue_balloon() -> void:
	if dialogue_balloon:
		dialogue_balloon.visible = true
		# Animación de aparición suave
		var tween: Tween = create_tween()
		dialogue_balloon.modulate.a = 0.0
		tween.tween_property(dialogue_balloon, "modulate:a", 1.0, 0.3)

func hide_dialogue_balloon() -> void:
	if dialogue_balloon:
		# Animación de desaparición suave
		var tween: Tween = create_tween()
		tween.tween_property(dialogue_balloon, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): dialogue_balloon.visible = false)
