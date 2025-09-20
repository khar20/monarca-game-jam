extends Control



func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://2D/Escenas2D/game_2d.tscn")


func _on_configuracion_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
