extends CanvasLayer

@export var fade_rect_path: NodePath = "ColorRectFade"
@export var fade_rect_btl_path: NodePath = "ColorRectBTL"  # Nuevo path exportado
@export var fade_duration := 0.5
@export var fade_color := Color.BLACK

var _fade_rect: ColorRect
var _fade_rect_BTL: ColorRect

func _ready():
	_fade_rect = get_node(fade_rect_path)
	_fade_rect.color = fade_color
	_fade_rect.modulate.a = 1.0

	_fade_rect_BTL = get_node(fade_rect_btl_path)
	_fade_rect_BTL.color = fade_color
	_fade_rect_BTL.modulate.a = 0.0  # Por defecto invisible

	visible = true
	fade_in()

func fade_in():
	visible = true
	var tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished
	visible = false

func fade_out(dur:float=0) -> void:
	if dur!=0:
		visible = true
		var tween = create_tween()
		tween.tween_property(_fade_rect, "modulate:a", 1.0, dur)
		await tween.finished
	else:
		visible = true
		var tween = create_tween()
		tween.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration)
		await tween.finished


# 🎬 Función secundaria para efecto extra (BTL)
func flash_btl(color := Color.BLACK, strength := 0.6, duration := 1) -> void:
	_fade_rect_BTL.color = color
	_fade_rect_BTL.modulate.a = strength
	visible = true

	var tween = create_tween()
	tween.tween_property(_fade_rect_BTL, "modulate:a", 0.0, duration)
	await tween.finished
	visible = false
