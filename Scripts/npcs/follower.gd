extends Node3D

@export var target: Node3D
@export var follow_distance := 1.8
@export var smoothing := 8.0
@export var vertical_offset := Vector3.ZERO

func _physics_process(delta):
	if target == null: return

	# Asegurarse de que el target tenga transform válido
	if not target.is_inside_tree(): return
	if not target.has_method("get_global_transform"): return

	var target_forward = -target.global_transform.basis.z.normalized()
	var desired_pos = target.global_position + target_forward * follow_distance + vertical_offset
	global_position = global_position.lerp(desired_pos, delta * smoothing)

	look_at(target.global_position + vertical_offset, Vector3.UP)
