extends Sprite2D

# Script para animar la perla moneda con efecto de rotación
var tween: Tween
var original_scale: Vector2

func _ready():
	# Guardar la escala original
	original_scale = scale
	
	# Crear el tween para la animación
	tween = create_tween()
	tween.set_loops() # Repetir infinitamente
	
	# Iniciar la animación de rotación
	start_coin_animation()

func start_coin_animation():
	# Animación de moneda girando (efecto de escala horizontal)
	# Fase 1: Comprimir horizontalmente (vista de perfil)
	tween.tween_property(self, "scale", Vector2(0.3 * original_scale.x, original_scale.y), 0.5)
	tween.tween_callback(add_sparkle_effect)
	
	# Fase 2: Expandir a normal
	tween.tween_property(self, "scale", original_scale, 0.5)
	
	# Fase 3: Comprimir horizontalmente otra vez (vista de perfil opuesta)
	tween.tween_property(self, "scale", Vector2(0.3 * original_scale.x, original_scale.y), 0.5)
	tween.tween_callback(add_sparkle_effect)
	
	# Fase 4: Expandir a normal
	tween.tween_property(self, "scale", original_scale, 0.5)

func add_sparkle_effect():
	# Efecto de destello cuando la moneda está de perfil
	var original_modulate = modulate
	modulate = Color.WHITE * 1.3  # Brillo más intenso
	
	# Crear un tween temporal para el destello
	var sparkle_tween = create_tween()
	sparkle_tween.tween_property(self, "modulate", original_modulate, 0.1)

# Función para pausar/reanudar la animación si es necesario
func pause_animation():
	if tween:
		tween.pause()

func resume_animation():
	if tween:
		tween.play()
