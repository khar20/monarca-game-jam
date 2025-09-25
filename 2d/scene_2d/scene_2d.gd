extends Node2D

@onready var player_2d: CharacterBody2D = $Player2D
@onready var menu_final_area: Area2D = $MenuFinal
#@onready var crt_shader: ColorRect = $CanvasLayer/TextureRect
@onready var count_label: Label = $Control/Label
var coin_count = 0

func _ready() -> void:
	update_display()
	# Conectar la señal de colisión del MenuFinal
	if menu_final_area:
		menu_final_area.body_entered.connect(_on_menu_final_body_entered)

func update_display() -> void:
	count_label.text = "x " + str(coin_count)
	# También actualizar el contador en el Player2D
	if player_2d and player_2d.has_method("update_counter_display"):
		player_2d.update_counter_display()

func get_coin_count() -> int:
	return coin_count

func _on_coin_coin_collected() -> void:
	coin_count += 1
	update_display()

func _on_menu_final_body_entered(body: Node2D) -> void:
	# Verificar si el cuerpo que entró es el jugador
	if body == player_2d:
		# Cambiar a la escena del menu final
		get_tree().change_scene_to_file("res://2d/main_menu_2d/menu_final.tscn")
