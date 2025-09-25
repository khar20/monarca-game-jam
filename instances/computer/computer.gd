# arcade_cabinet.gd
extends Area3D

# This signal tells the main 3D scene that a player wants to interact.
signal interaction_requested(player_3d, arcade_cabinet)
# This signal tells the main 3D scene that the 2D game has ended.
signal interaction_ended(arcade_cabinet)

## Assign the SubViewport node that contains your 2D game here.
@export var subviewport: SubViewport

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# --- Setup for the Viewport Screen ---
	if not subviewport:
		print("ERROR: No SubViewport assigned to this ArcadeCabinet instance.")
		return

	# Get the active material from the mesh (surface 0).
	var material = mesh.get_active_material(0)
	if not material:
		print("ERROR: The MeshInstance3D has no material to apply the screen to.")
		return
	
	# 1. Duplicate the material to make it unique for this instance.
	#    This is CRITICAL to prevent all arcade cabinets from sharing the same screen.
	var unique_material = material.duplicate() as StandardMaterial3D
	
	# 2. Get the live texture from the SubViewport.
	var viewport_texture = subviewport.get_texture()
	
	# 3. Set the viewport texture as the albedo (base color) texture.
	unique_material.albedo_texture = viewport_texture
	
	# 4. Apply this unique, updated material to the mesh.
	mesh.material_override = unique_material
	# --- End of Screen Setup ---

	# Ensure the 2D game is initially disabled.
	set_game_active(false)
	
	# This line assumes a node called 'Player2D' is inside your SubViewport scene.
	# You will need to connect a signal from your 2D game to trigger this.
	# For example: subviewport.get_node("Player2D").exited_game.connect(_on_player_2d_exited_game)


# This function can be called by an external object, like a player's raycast.
func interact(player_3d: CharacterBody3D) -> void:
	# Emit the signal to let a controller scene handle the logic.
	interaction_requested.emit(player_3d, self)

# The main scene controller will call this to activate/deactivate the 2D game.
func set_game_active(is_active: bool) -> void:
	# Pass input events to the 2D game only when it's active.
	subviewport.set_process_input(is_active)
	subviewport.set_process_unhandled_input(is_active)
	
	# If your 2D game has physics, you might also want to toggle its process.
	# This requires getting the nodes inside the viewport.
	# Example:
	# var player_2d = subviewport.get_node_or_null("Player2D")
	# if player_2d:
	#	 player_2d.set_physics_process(is_active)


# This function should be connected to a signal from your 2D game.
# For example, when the 2D player presses "quit" or the game ends.
func _on_player_2d_exited_game() -> void:
	# The 2D game wants to quit. Tell the main scene controller.
	interaction_ended.emit(self)
