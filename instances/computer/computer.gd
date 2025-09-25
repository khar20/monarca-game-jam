# arcade_cabinet.gd
extends Area3D

# This signal is the most important part.
# It tells the main 3D scene: "Hey, a player wants to start playing me!"
signal interaction_requested(player_3d, arcade_cabinet)
signal interaction_ended(arcade_cabinet)

@onready var subviewport: SubViewport = $SubViewport
#@onready var player_2d = $SubViewport/Game2D/Player2D

func _ready() -> void:
	# Ensure the 2D game is initially disabled and connects its exit signal.
	set_game_active(false)
	#player_2d.exited_game.connect(_on_player_2d_exited_game)

# This function is called by the 3D player's raycast.
func interact(player_3d: CharacterBody3D) -> void:
	# Don't handle the logic here. Just emit the signal to the main scene controller.
	interaction_requested.emit(player_3d, self)

# The main scene will call this to activate the 2D game.
func set_game_active(is_active: bool) -> void:
	subviewport.set_process_input(is_active)
	subviewport.set_process_unhandled_input(is_active)
	#player_2d.set_physics_process(is_active)

func _on_player_2d_exited_game() -> void:
	# The 2D player wants to quit. Tell the main scene.
	interaction_ended.emit(self)
