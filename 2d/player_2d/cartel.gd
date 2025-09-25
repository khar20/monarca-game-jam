extends Area2D

@onready var exclamation_mark = $ExclamationMark

const dialogo_ninio = preload("res://2d/dialogos2D/cartel1.dialogue")

var is_player_2d_close = false
var is_dialogue_active = false
var player_2d: CharacterBody2D = null

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	# Buscar el jugador en la escena
	player_2d = get_node("../Player2D") if has_node("../Player2D") else null

func _process(delta: float) -> void:
	if is_player_2d_close and Input.is_action_just_pressed("ui_accept") and not is_dialogue_active:
		DialogueManager.show_dialogue_balloon(dialogo_ninio, "start")

func _on_area_entered(area: Area2D) -> void:
	exclamation_mark.visible = true
	is_player_2d_close = true


func _on_area_exited(area: Area2D) -> void:
	exclamation_mark.visible = false
	is_player_2d_close = false
	
func _on_dialogue_started(dialogue) -> void:
	is_dialogue_active = true
	# Bloquear el movimiento del jugador
	if player_2d:
		player_2d.set_physics_process(false)
	
func _on_dialogue_ended(dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
	if player_2d:
		player_2d.set_physics_process(true)
