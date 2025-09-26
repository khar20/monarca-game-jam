# computer.gd
# Attach to the root Node3D of the computer.
extends Node3D

# --- Exports ---
@export var subviewport: SubViewport

# --- OnReady Variables ---
@onready var interactable: Interactable = $InteractableComponent
@onready var interaction_point: Node3D = $InteractionPoint
@onready var mesh: MeshInstance3D = $StaticBody3D/MeshInstance3D

# --- Private Variables ---
var _original_player_transform: Transform3D
var _original_player_position: Vector3
var _is_active: bool = false

func _ready() -> void:
	# --- Validation ---
	if not subviewport:
		push_error("Computer Error: No SubViewport has been assigned in the Inspector.")
		return
	if not interactable:
		push_error("Computer Error: No child node of type 'Interactable' was found.")
		return
	if not interaction_point:
		push_error("Computer Error: No child node named 'InteractionPoint' was found.")
		return

	# --- Material Setup for the Screen ---
	var material: Material = mesh.get_active_material(0)
	if material:
		var unique_material: StandardMaterial3D = material.duplicate() as StandardMaterial3D
		var viewport_texture: ViewportTexture = subviewport.get_texture()
		unique_material.albedo_texture = viewport_texture
		mesh.material_override = unique_material
	else:
		push_warning("Computer Warning: The mesh has no material on slot 0 to apply the screen texture to.")

	subviewport.child_entered_tree.connect(_on_subviewport_child_entered)
	
	# This will trigger the connection for the initial scene (the menu) at startup.
	if subviewport.get_child_count() > 0:
		_on_subviewport_child_entered(subviewport.get_child(0))
	
	# --- Initial State ---
	add_to_group("computer_interaction")
	interactable.interacted.connect(_on_interacted)

# --- Interaction Logic ---

func _on_interacted(player: CharacterBody3D) -> void:
	if _is_active:
		return
	_is_active = true

	_original_player_transform = player.global_transform
	_original_player_position = player.global_position
	
	# Move the player into position.
	print(player.global_position)
	#player.tween_body_to_transform(interaction_point.global_transform, 1.0)
	#player.tween_camera_to_look_at(mesh.global_position, 1)
	player.tween_body_and_camera_look_at(interaction_point.global_transform, mesh.global_position, 1)
	print(player.global_position)
	#player.tween_body_to_position(interaction_point.global_position, 1.0)
	
	# Tell the player to start forwarding input to our subviewport.
	player.begin_subviewport_interaction(subviewport)
	print(player.global_position)

func end_interaction(player) -> void:
	if not _is_active:
		return
	_is_active = false
	
	# Tell the player to stop forwarding input.
	player.end_subviewport_interaction()

	# Move the player back to where they were.
	#player.tween_body_to_transform(_original_player_transform, 1.0)
	player.tween_body_to_position(_original_player_transform, 1.0)

# --- NEW: This function connects signals from the scene inside the viewport ---
func _on_subviewport_child_entered(child_node: Node) -> void:
	# Check if the new scene has the signal we're looking for.
	if child_node.has_signal("scene_change_requested"):
		# Connect this computer's _on_scene_change_requested function to that signal.
		# The .connect() call will now persist until that child_node is freed.
		child_node.scene_change_requested.connect(_on_scene_change_requested)

# --- NEW: This function executes the scene change ---
func _on_scene_change_requested(scene_path: String) -> void:
	# 1. Free the current scene inside the viewport.
	if subviewport.get_child_count() > 0:
		var current_scene: Node = subviewport.get_child(0)
		current_scene.queue_free()

	# 2. Load the new scene resource from the path provided by the signal.
	var new_scene_packed: PackedScene = load(scene_path)
	if new_scene_packed:
		# 3. Instantiate the new scene.
		var new_scene_instance: Node = new_scene_packed.instantiate()
		
		# 4. Add the new instance as a child of the SubViewport.
		#    This will trigger `_on_subviewport_child_entered` again for the new scene,
		#    setting up its signals if it has any (like a "back to menu" signal).
		subviewport.add_child(new_scene_instance)
