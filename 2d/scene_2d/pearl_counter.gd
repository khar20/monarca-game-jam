# Script para manejar el contador global de perlas
extends Control

@onready var count_label = $HBoxContainer/CountLabel
var pearl_count = 0

func _ready():
	# Conectar a la señal global de perlas recolectadas
	var pearl_manager = get_node("/root/PearlManager")
	if pearl_manager and not pearl_manager.pearl_collected.is_connected(_on_pearl_collected):
		pearl_manager.pearl_collected.connect(_on_pearl_collected)
	update_display()

func _on_pearl_collected():
	pearl_count += 1
	update_display()

func update_display():
	count_label.text = "x " + str(pearl_count)
