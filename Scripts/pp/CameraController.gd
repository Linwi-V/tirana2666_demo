extends Node3D

@export var rotation_speed := 0.01
@export var step_rotation_deg := 45.0
@export var min_pitch := deg_to_rad(-45)
@export var max_pitch := deg_to_rad(45)

var dragging := false
var last_mouse_pos := Vector2.ZERO
var yaw := 0.0  # horizontal angle
var pitch := 0.0  # vertical angle

var active = true
var exterior = true

func _ready():
	yaw = rotation.y
	## pitch = rotation.x

func _unhandled_input(event):
	if active and exterior:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				dragging = event.pressed
				last_mouse_pos = event.position
		elif event is InputEventMouseMotion and dragging:
			yaw -= event.relative.x * rotation_speed
			## pitch = clamp(pitch - event.relative.y * rotation_speed, min_pitch, max_pitch)
			_update_rotation()

func _update_rotation():
	rotation = Vector3(pitch, yaw, 0)

func rotate_step(dir: int):
	yaw += deg_to_rad(step_rotation_deg * dir)
	_update_rotation()
