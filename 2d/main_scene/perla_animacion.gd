extends Sprite2D

@onready var area_2d = $Area2D

var tween: Tween
var sparkle_tween: Tween
var camera_offset: Vector2
var camera: Camera2D

func _ready():
	if area_2d:
		area_2d.body_entered.connect(_on_body_entered)
	
	camera = get_viewport().get_camera_2d()
	
	if camera:
		camera_offset = global_position - camera.global_position
	
	start_spinning_animation()

func _process(delta):
	if camera:
		global_position = camera.global_position + camera_offset

func start_spinning_animation():
	tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(self, "scale:x", -0.5, 1.0)
	tween.tween_property(self, "scale:x", 0.5, 1.0)
	
	sparkle_tween = create_tween()
	sparkle_tween.set_loops()
	sparkle_tween.tween_property(self, "modulate:a", 0.8, 0.5)
	sparkle_tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _on_body_entered(body):
	if body.name == "Player" or body.has_method("is_player"):
		collect_pearl()

func collect_pearl():
	if has_node("/root/PearlManager"):
		get_node("/root/PearlManager").collect_pearl()
	else:
		print("Error: PearlManager no encontrado")
	
	var disappear_tween = create_tween()
	disappear_tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	disappear_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	disappear_tween.tween_callback(queue_free)

func pause_animation():
	if tween:
		tween.pause()
	if sparkle_tween:
		sparkle_tween.pause()

func resume_animation() -> void:
	if tween:
		tween.play()
	if sparkle_tween:
		sparkle_tween.play()
