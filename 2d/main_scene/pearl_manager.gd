# Singleton para manejar el sistema global de perlas
extends Node

signal pearl_collected

var total_pearls = 0

func collect_pearl():
	total_pearls += 1
	pearl_collected.emit()
	print("Perla recolectada! Total: ", total_pearls)

func get_pearl_count():
	return total_pearls

func reset_count():
	total_pearls = 0