extends Control

@onready var configuracion_button = $VBoxContainer/ConfiguracionContainer/Configuracion
@onready var salir_button = $VBoxContainer/SalirContainer/Salir
@onready var configuracion_rota = $VBoxContainer/ConfiguracionContainer/ConfiguracionRota
@onready var salir_roto = $VBoxContainer/SalirContainer/SalirRoto

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2D/Escenas2D/game_2d.tscn")

func _on_configuracion_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	configuracion_button.visible = false
	configuracion_rota.visible = true
	

func _on_salir_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	salir_button.visible = false
	salir_roto.visible = true
	
	#Invertir la imagen
	salir_roto.flip_h = true
	
	
