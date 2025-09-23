extends Node2D

#@onready var player: CharacterBody2D = $Player2D
#@onready var crt_shader: ColorRect = $CanvasLayer/TextureRect
@onready var count_label: Label = $Control/Label
var coin_count = 0

func _ready() -> void:
	update_display()

func update_display() -> void:
	count_label.text = "x " + str(coin_count)

func _on_coin_coin_collected() -> void:
	coin_count += 1
	update_display()
