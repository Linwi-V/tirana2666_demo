extends CanvasLayer

@export var fade_rect_path: NodePath = "ColorRectFade"
@export var fade_duration := 0.5
@export var fade_color := Color.BLACK

var _fade_rect: ColorRect


func _ready():
	_fade_rect = get_node(fade_rect_path)
	_fade_rect.color = fade_color
	_fade_rect.modulate.a = 1.0  # Comienza opaco
	visible = true
	# Fade-in al cargar
	fade_in()

func fade_in():
	visible = true
	var tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished
	visible = false

func fade_out() -> void:
	visible = true
	var tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished
