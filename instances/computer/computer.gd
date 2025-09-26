# computer.gd
# This script should be attached to the root Node3D of your computer/arcade cabinet.
extends StaticBody3D

# --- Assign these in the Godot Editor ---

## The SubViewport node that contains your 2D game.
@export var subviewport: SubViewport

## How long the transition for the player and camera should take.
@export var transition_time: float = 1.0


# --- Node references, automatically found at runtime ---

## The visual mesh of the computer. Assumes it's a direct child.
@onready var mesh: MeshInstance3D = $MeshInstance3D

## The target for the player's camera. Assumes it's a direct child.
@onready var screen_camera: Camera3D = $ScreenCamera

## The target for the player's body. Assumes it's a direct child.
@onready var stand_position: Marker3D = $StandPosition


func _ready() -> void:
	# --- Setup for the Viewport Screen ---
	# This section correctly sets up the screen material at runtime.
	if not subviewport:
		push_error("No SubViewport assigned to this Computer instance.")
		return

	var material: Material = mesh.get_active_material(0)
	if not material:
		push_error("The MeshInstance3D has no material to apply the screen to.")
		return
	
	# 1. Duplicate the material to make it unique for this instance.
	#    This is CRITICAL to prevent all computers from sharing the same screen.
	var unique_material: StandardMaterial3D = material.duplicate() as StandardMaterial3D
	
	# 2. Get the live texture from the SubViewport.
	var viewport_texture: ViewportTexture = subviewport.get_texture()
	
	# 3. Set the viewport texture as the albedo (base color) texture.
	unique_material.albedo_texture = viewport_texture
	
	# 4. Apply this unique, updated material to the mesh.
	mesh.material_override = unique_material
	# --- End of Screen Setup ---

	# Ensure the 2D game input is disabled from the start.
	subviewport.set_process_input(false)
	subviewport.set_process_unhandled_input(false)
	
	# Add this node to a group so the player's raycast can identify it easily.
	add_to_group("interactable")


# This function is called directly by the player's raycast when they press "interact".
func start_interaction(player: CharacterBody3D) -> void:
	# 1. Activate the 2D game's input processing.
	subviewport.set_process_input(true)
	subviewport.set_process_unhandled_input(true)
	
	# 2. Create a dictionary with all the instructions for the player.
	var interaction_data: Dictionary = {
		# Where the player's body should move to.
		"target_player_transform": stand_position.global_transform,
		# Where the player's camera should move to.
		"target_camera_transform": screen_camera.global_transform,
		# How long the transition should take.
		"transition_time": transition_time,
		# What the mouse mode should be (visible for UI interaction).
		"mouse_mode": Input.MOUSE_MODE_VISIBLE
	}
	
	# 3. Call the player's function to begin the transition, passing along the instructions
	#    and a reference to this computer node (self).
	player.enter_interaction(interaction_data, self)

# This function is called by the player when they press "ui_cancel" (Escape).
func end_interaction(_player: CharacterBody3D) -> void:
	# Deactivate the 2D game's input processing.
	subviewport.set_process_input(false)
	subviewport.set_process_unhandled_input(false)
