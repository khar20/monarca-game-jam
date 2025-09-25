# arcade_cabinet.gd
extends Area3D

# This signal is the most important part.
# It tells the main 3D scene: "Hey, a player wants to start playing me!"
signal game_session_requested(player_3d, arcade_cabinet)
signal game_session_ended(arcade_cabinet)

@onready var subviewport: SubViewport = $SubViewport
#@onready var player_2d = $SubViewport/Game2D/Player2D

func _ready() -> void:
	# Ensure the 2D game is initially disabled and connects its exit signal.
	set_game_active(false)
	#player_2d.exited_game.connect(_on_player_2d_exited_game)

# This function is called by the 3D player's raycast.
func start_game(player_3d: CharacterBody3D) -> void:
	# Don't handle the logic here. Just emit the signal to the main scene controller.
	game_session_requested.emit(player_3d, self)

# The main scene will call this to activate the 2D game.
func set_game_active(is_active: bool) -> void:
	subviewport.set_process_input(is_active)
	subviewport.set_process_unhandled_input(is_active)
	#player_2d.set_physics_process(is_active)

func _on_player_2d_exited_game():
	# The 2D player wants to quit. Tell the main scene.
	game_session_ended.emit(self)
