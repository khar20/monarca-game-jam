extends Control

@onready var configuracion_button = $VBoxContainer/ConfiguracionContainer/Configuracion
@onready var salir_button = $VBoxContainer/SalirContainer/Salir
@onready var configuracion_rota = $VBoxContainer/ConfiguracionContainer/ConfiguracionRota
@onready var salir_roto = $VBoxContainer/SalirContainer/SalirRoto
@onready var terror_svg = $TerrorSVG

# Posiciones posibles para las esquinas (top-left, top-right, bottom-left, bottom-right)
var corner_positions = [
	Vector2(50, 50),      # Esquina superior izquierda
	Vector2(800, 50),     # Esquina superior derecha  
	Vector2(50, 400),     # Esquina inferior izquierda
	Vector2(800, 400)     # Esquina inferior derecha
]

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2D/Escenas2D/game_2d.tscn")

func _on_configuracion_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	configuracion_button.visible = false
	configuracion_rota.visible = true
	
	# Mostrar el SVG de terror en una esquina aleatoria
	show_terror_svg()

func _on_salir_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	salir_button.visible = false
	salir_roto.visible = true
	
	#Invertir la imagen
	salir_roto.flip_h = true
	
	# Mostrar el SVG de terror en una esquina aleatoria
	show_terror_svg()

func show_terror_svg():
	# Seleccionar una posición aleatoria de las esquinas
	var random_position = corner_positions[randi() % corner_positions.size()]
	
	# Posicionar el SVG en la esquina seleccionada
	terror_svg.position = random_position
	
	# Hacer visible el SVG
	terror_svg.visible = true
	
	# Opcional: añadir un efecto de aparición gradual
	terror_svg.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(terror_svg, "modulate:a", 1.0, 0.5)
	
	
