extends Control

# Añade la referencia al botón de Jugar, asumiendo una estructura similar
signal scene_change_requested(scene_path: String)

# onready var
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	play_button.grab_focus()
	play_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	options_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exit_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		print("a")
		return

func _on_play_button_pressed() -> void:
	# change to first scene
	scene_change_requested.emit("res://2d/scene_2d/scene_2d.tscn")

func _on_options_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
	
