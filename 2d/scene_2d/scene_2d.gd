extends Node2D

@onready var player: CharacterBody2D = $Player2D
# @onready var camera: Camera2D = $Camera2D  # Camera2D node doesn't exist in the scene
@onready var crt_shader: ColorRect = $CanvasLayer/TextureRect
