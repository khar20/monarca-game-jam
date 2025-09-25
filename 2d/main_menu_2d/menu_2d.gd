extends Control

# Añade la referencia al botón de Jugar, asumiendo una estructura similar
@onready var jugar_button: Button = $VBoxContainer/Jugar
@onready var configuracion_button: Button = $VBoxContainer/ConfiguracionContainer/Configuracion
@onready var salir_button: Button = $VBoxContainer/SalirContainer/Salir
@onready var configuracion_rota: TextureRect = $VBoxContainer/ConfiguracionContainer/ConfiguracionRota
@onready var salir_roto: TextureRect = $VBoxContainer/SalirContainer/SalirRoto
@onready var terror_svg: TextureRect = $TerrorSVG
@onready var simbolos_svg: TextureRect = $SimbolosSVG

# Posiciones específicas para cada imagen
var terror_position: Vector2 = Vector2(800, 50)
var simbolos_position: Vector2 = Vector2(50, 400)

func _ready() -> void:
	# 1. Desactivar la interacción del ratón en todos los botones.
	# Esto evita que se puedan clickear o que cambien de apariencia con el cursor.
	#jugar_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	configuracion_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	salir_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 2. Establecer el foco inicial en el botón de "Jugar".
	# Esto hace que el primer botón esté "seleccionado" al empezar.
	jugar_button.grab_focus()

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2d/scene_2d/scene_2d.tscn")

func _on_configuracion_pressed() -> void:
	# Ocultar el botón y mostrar la imagen
	configuracion_button.visible = false
	configuracion_rota.visible = true
	
	# Mostrar el SVG de terror en la esquina superior derecha
	show_terror_svg()

func _on_salir_pressed() -> void:
	# Ocultar el botón y mostrar la imagen
	salir_button.visible = false
	salir_roto.visible = true
	
	# Invertir la imagen
	salir_roto.flip_h = true
	
	# Mostrar el SVG de símbolos en la esquina inferior izquierda
	show_simbolos_svg()

func show_terror_svg() -> void:
	# Posicionar el SVG en la esquina superior derecha
	terror_svg.position = terror_position
	
	# Añadir rotación inclinada aleatoria (entre -25 y 25 grados)
	var random_rotation: float = randf_range(-25.0, 25.0)
	terror_svg.rotation_degrees = random_rotation
	
	# Hacer visible el SVG
	terror_svg.visible = true
	
	# Efecto de aparición gradual con rotación
	terror_svg.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.parallel().tween_property(terror_svg, "modulate:a", 1.0, 0.5)
	# Añadir un ligero efecto de rotación durante la aparición
	tween.parallel().tween_property(terror_svg, "rotation_degrees", random_rotation + randf_range(-5.0, 5.0), 0.5)

func show_simbolos_svg() -> void:
	# Posicionar el SVG en la esquina inferior izquierda
	simbolos_svg.position = simbolos_position
	
	# Añadir rotación inclinada aleatoria (entre -25 y 25 grados)
	var random_rotation: float = randf_range(-25.0, 25.0)
	simbolos_svg.rotation_degrees = random_rotation
	
	# Hacer visible el SVG
	simbolos_svg.visible = true
	
	# Efecto de aparición gradual con rotación
	simbolos_svg.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.parallel().tween_property(simbolos_svg, "modulate:a", 1.0, 0.5)
	# Añadir un ligero efecto de rotación durante la aparición
	tween.parallel().tween_property(simbolos_svg, "rotation_degrees", random_rotation + randf_range(-5.0, 5.0), 0.5)
