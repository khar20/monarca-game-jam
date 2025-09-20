extends Control

@onready var configuracion_button = $VBoxContainer/Configuracion
@onready var salir_button = $VBoxContainer/Salir
@onready var configuracion_rota = $VBoxContainer/ConfiguracionRota
@onready var salir_roto = $VBoxContainer/SalirRoto

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2D/Escenas2D/game_2d.tscn")

func _on_configuracion_pressed() -> void:
	# Ocultar el botón y mostrar la imagen rota
	configuracion_button.visible = false
	configuracion_rota.visible = true
	

func _on_salir_pressed() -> void:
	# Ocultar el botón y mostrar la imagen rota
	salir_button.visible = false
	salir_roto.visible = true
	
