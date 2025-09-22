extends Control

@onready var configuracion_button = $VBoxContainer/ConfiguracionContainer/Configuracion
@onready var salir_button = $VBoxContainer/SalirContainer/Salir
@onready var configuracion_rota = $VBoxContainer/ConfiguracionContainer/ConfiguracionRota
@onready var salir_roto = $VBoxContainer/SalirContainer/SalirRoto
@onready var terror_svg = $TerrorSVG
@onready var simbolos_svg = $SimbolosSVG

# Posiciones específicas para cada imagen
var terror_position = Vector2(800, 50)      # Esquina superior derecha para texto_terror_simbolos
var simbolos_position = Vector2(50, 400)    # Esquina inferior izquierda para simbolos_menu

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2d/main_scene/main_scene.tscn")

func _on_configuracion_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	configuracion_button.visible = false
	configuracion_rota.visible = true
	
	# Mostrar el SVG de terror en la esquina superior derecha
	show_terror_svg()

func _on_salir_pressed() -> void:
	#Ocultar el botón y mostrar la imagen
	salir_button.visible = false
	salir_roto.visible = true
	
	#Invertir la imagen
	salir_roto.flip_h = true
	
	# Mostrar el SVG de símbolos en la esquina inferior izquierda
	show_simbolos_svg()

func show_terror_svg():
	# Posicionar el SVG en la esquina superior derecha
	terror_svg.position = terror_position
	
	# Añadir rotación inclinada aleatoria (entre -25 y 25 grados)
	var random_rotation = randf_range(-25.0, 25.0)
	terror_svg.rotation_degrees = random_rotation
	
	# Hacer visible el SVG
	terror_svg.visible = true
	
	# Efecto de aparición gradual con rotación
	terror_svg.modulate.a = 0.0
	var tween = create_tween()
	tween.parallel().tween_property(terror_svg, "modulate:a", 1.0, 0.5)
	# Añadir un ligero efecto de rotación durante la aparición
	tween.parallel().tween_property(terror_svg, "rotation_degrees", random_rotation + randf_range(-5.0, 5.0), 0.5)

func show_simbolos_svg():
	# Posicionar el SVG en la esquina inferior izquierda
	simbolos_svg.position = simbolos_position
	
	# Añadir rotación inclinada aleatoria (entre -25 y 25 grados)
	var random_rotation = randf_range(-25.0, 25.0)
	simbolos_svg.rotation_degrees = random_rotation
	
	# Hacer visible el SVG
	simbolos_svg.visible = true
	
	# Efecto de aparición gradual con rotación
	simbolos_svg.modulate.a = 0.0
	var tween = create_tween()
	tween.parallel().tween_property(simbolos_svg, "modulate:a", 1.0, 0.5)
	# Añadir un ligero efecto de rotación durante la aparición
	tween.parallel().tween_property(simbolos_svg, "rotation_degrees", random_rotation + randf_range(-5.0, 5.0), 0.5)
	
	
