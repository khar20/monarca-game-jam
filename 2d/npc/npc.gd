extends Area2D

@onready var exclamation_mark: Sprite2D = $ExclamationMark

const dialogo_ninio = preload("res://dialogues/npc.dialogue")

var is_player_2d_close: bool = false
var is_dialogue_active: bool = false
var player_2d: CharacterBody2D = null

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	# Buscar el jugador en la escena
	player_2d = get_node("../player_2d") if has_node("../player_2d") else null
	# Ocultar el icono de exclamación al inicio
	exclamation_mark.visible = false

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if is_player_2d_close and not is_dialogue_active:
			DialogueManager.show_dialogue_balloon(dialogo_ninio, "start")

func _on_area_entered(area: Area2D) -> void:
	exclamation_mark.visible = true
	is_player_2d_close = true
	
func _on_area_exited(area: Area2D) -> void:
	exclamation_mark.visible = false
	is_player_2d_close = false
	
func _on_dialogue_started(dialogue) -> void:
	is_dialogue_active = true
	# Bloquear el movimiento del jugador
	if player_2d:
		player_2d.set_physics_process(false)
	
func _on_dialogue_ended(dialogue: DialogueResource) -> void:
	await get_tree().create_timer(0.2).timeout
	is_dialogue_active = false
	if player_2d:
		player_2d.set_physics_process(true)
	
	# Mover el NPC después del diálogo
	move_npc_after_dialogue()

func move_npc_after_dialogue() -> void:
	# Crear un tween para el movimiento suave
	var tween: Tween = create_tween()
	
	# Posición actual del NPC
	var current_position: Vector2 = global_position
	
	# Calcular nueva posición: cuadros a la derecha (100 píxeles) y hacia abajo (350 píxeles)
	var target_position: Vector2 = current_position + Vector2(100, 350)
	
	# Mover primero a la derecha, luego hacia abajo
	tween.tween_property(self, "global_position", current_position + Vector2(100, 0), 1.0)
	tween.tween_property(self, "global_position", target_position, 1.0)
	
	# Cuando termine el movimiento, cambiar la visibilidad de los nodos
	tween.tween_callback(change_scene_visibility)

func change_scene_visibility() -> void:
	# Obtener referencia a la escena principal
	var main_scene: Node = get_parent()
	
	# Cambiar visibilidad de la pared (StaticBody2D)
	var pared: Node = main_scene.get_node("pared")
	if pared:
		pared.visible = false
		# Desactivar la colisión de CollisionPared
		var collision_pared: Node = pared.get_node("CollisionPared")
		if collision_pared:
			collision_pared.disabled = true		
	
	# Cambiar visibilidad de FrenteInvi (TileMapLayer)
	var frente_invi: Node = main_scene.get_node("FrenteInvi")
	if frente_invi:
		frente_invi.visible = true
