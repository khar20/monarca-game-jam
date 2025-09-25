extends Control

@onready var texture_rect = $TextureRect2
@onready var background = $TextureRect

var crash_timer: float = 0.0
var glitch_timer: float = 0.0
var is_crashing: bool = false
var crash_intensity: float = 0.0

# Colores espeluznantes para el efecto de crasheo
var horror_colors = [
	Color.RED,
	Color(0.8, 0.0, 0.0, 1.0),  # Rojo oscuro
	Color(0.2, 0.0, 0.0, 1.0),  # Rojo muy oscuro
	Color.BLACK,
	Color(0.1, 0.1, 0.1, 1.0),  # Gris muy oscuro
	Color(1.0, 0.0, 0.0, 0.8),  # Rojo semi-transparente
]

func _ready() -> void:
	# Iniciar el efecto de crasheo después de un momento
	await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
	start_crash_effect()

func _process(delta: float) -> void:
	if is_crashing:
		crash_timer += delta
		glitch_timer += delta * 10.0  # Más rápido para el glitch
		
		# Intensidad del crasheo aumenta con el tiempo
		crash_intensity = min(crash_timer * 0.5, 2.0)
		
		# Efectos de glitch en el shader
		update_shader_effects()
		
		# Efectos de parpadeo y distorsión
		apply_glitch_effects()
		
		# Cambios de color espeluznantes
		apply_horror_colors()

func start_crash_effect() -> void:
	is_crashing = true
	crash_timer = 0.0
	
	# Crear efectos de "lag" simulado
	create_lag_spikes()

func update_shader_effects() -> void:
	if texture_rect and texture_rect.material:
		var material = texture_rect.material as ShaderMaterial
		if material:
			# Aumentar la intensidad del ruido y distorsión
			material.set_shader_parameter("noise_intensity", 0.02 + crash_intensity * 0.3)
			material.set_shader_parameter("distortion_intensity", 0.003 + crash_intensity * 0.05)
			material.set_shader_parameter("flicker_intensity", 0.05 + crash_intensity * 0.4)
			material.set_shader_parameter("time_speed", 1.0 + crash_intensity * 3.0)

func apply_glitch_effects() -> void:
	# Parpadeo aleatorio
	if randf() < 0.1 + crash_intensity * 0.2:
		texture_rect.modulate.a = randf_range(0.3, 1.0)
	else:
		texture_rect.modulate.a = 1.0
	
	# Distorsión de posición
	if randf() < 0.05 + crash_intensity * 0.1:
		var glitch_offset = Vector2(
			randf_range(-10, 10) * crash_intensity,
			randf_range(-10, 10) * crash_intensity
		)
		texture_rect.position = glitch_offset
		
		# Volver a la posición normal después de un momento
		var tween = create_tween()
		tween.tween_property(texture_rect, "position", Vector2.ZERO, 0.1)
	
	# Escalado aleatorio para simular "freezing"
	if randf() < 0.03 + crash_intensity * 0.05:
		var glitch_scale = Vector2(
			randf_range(0.95, 1.05),
			randf_range(0.95, 1.05)
		)
		texture_rect.scale = glitch_scale
		
		var tween = create_tween()
		tween.tween_property(texture_rect, "scale", Vector2.ONE, 0.2)

func apply_horror_colors() -> void:
	# Cambios de color espeluznantes aleatorios
	if randf() < 0.08 + crash_intensity * 0.15:
		var horror_color = horror_colors[randi() % horror_colors.size()]
		background.modulate = horror_color
		
		# Volver al color normal gradualmente
		var tween = create_tween()
		tween.tween_property(background, "modulate", Color.WHITE, randf_range(0.5, 2.0))
	
	# Efecto de "sangrado" de color
	if randf() < 0.05 + crash_intensity * 0.1:
		texture_rect.modulate = Color(
			randf_range(0.8, 1.2),
			randf_range(0.3, 0.8),
			randf_range(0.3, 0.8),
			1.0
		)
		
		var tween = create_tween()
		tween.tween_property(texture_rect, "modulate", Color.WHITE, 1.0)

func create_lag_spikes() -> void:
	# Simular "lag spikes" pausando el juego brevemente
	while is_crashing:
		await get_tree().create_timer(randf_range(3.0, 8.0)).timeout
		
		if randf() < 0.3 + crash_intensity * 0.2:
			# "Freeze" temporal
			get_tree().paused = true
			await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
			get_tree().paused = false
			
			# Efecto visual después del freeze
			create_post_freeze_effect()

func create_post_freeze_effect() -> void:
	# Efecto visual después de un "freeze"
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.0, 0.0, 0.3)
	flash.size = get_viewport().get_visible_rect().size
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)

func _input(event: InputEvent) -> void:
	# Hacer que los inputs sean "glitchy" durante el crasheo
	if is_crashing and randf() < 0.1 + crash_intensity * 0.2:
		# "Consumir" el input aleatoriamente para simular no-responsividad
		get_viewport().set_input_as_handled()
