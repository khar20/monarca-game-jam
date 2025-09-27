class_name Interactable
extends Area3D

signal focused(interactor)
signal unfocused(interactor)
signal interacted(interactor)

@export var prompt_message: String = "Interact"

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		focused.emit(body)

func _on_body_exited(body) -> void:
	if body.is_in_group("player"):
		unfocused.emit(body)

func do_interact(interactor) -> void:
	interacted.emit(interactor)
