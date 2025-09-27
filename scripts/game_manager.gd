# GameManager.gd
extends Node

var ritual_step :int = 0

func advance_ritual() -> void:
	ritual_step += 1
