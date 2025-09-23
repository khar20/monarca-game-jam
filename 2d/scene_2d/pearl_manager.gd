# Singleton para manejar el sistema global de perlas
extends Node

signal pearl_collected

var total_pearls: int = 0

func collect_pearl() -> void:
	total_pearls += 1
	pearl_collected.emit()
	print("Perla recolectada! Total: ", total_pearls)

func get_pearl_count() -> int:
	return total_pearls

func reset_count() -> void:
	total_pearls = 0
