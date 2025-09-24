extends Node3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var player: CharacterBody3D = $Player

var is_playing_2d_game: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		is_playing_2d_game = !is_playing_2d_game
		
		if is_playing_2d_game:
			player.set_state(player.States.PLAYING)
		else:
			player.set_state(player.States.MOVE)

func _input(event: InputEvent) -> void:
	if is_playing_2d_game:
		sub_viewport.push_input(event)
		get_viewport().set_input_as_handled()
