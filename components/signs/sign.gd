extends Area2D

## The dialogue resource to play when the player interacts with this area.
@export var dialogue: Resource

@onready var exclamation_mark: Sprite2D = $ExclamationMark

var is_dialogue_active: bool = false
var player_2d: CharacterBody2D = null

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	exclamation_mark.visible = false

func _input(event: InputEvent) -> void:
	if not dialogue:
		return

	# interact input
	if event.is_action_just_pressed("interact"):
		if player_2d and not is_dialogue_active:
			DialogueManager.show_dialogue_balloon(dialogue, "start")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_2d = area.owner as CharacterBody2D
		if player_2d:
			exclamation_mark.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		exclamation_mark.visible = false
		player_2d = null
	
func _on_dialogue_started(started_dialogue) -> void:
	is_dialogue_active = true
	# Block the player's movement.
	if player_2d:
		player_2d.set_physics_process(false)
	
func _on_dialogue_ended(ended_dialogue) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
	if player_2d:
		player_2d.set_physics_process(true)
