extends Node3D

var og_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WorldFunc.cutscene=true
	
	$Pp.position=Vector3(-5.538075, -0.563124, 1.729)
	$Pp.fixed_cam=true
	$Pp/Pivot.exterior=false
	$Pp/Pivot.top_level=true
	$Pp.position=Vector3(-4,0,0)
	$Pp/Pivot/SpringArm3D/Camera3D.fov = 50
	og_pos = $Pp/Pivot.position
	
	$Pp.set_busy()
	$Pp.GRAVITY=0
	$Pp.velocidad_mov=0.01
	
	for i in range(15):
		$Pp.set_external_direction(Vector3.FORWARD)
		await get_tree().create_timer(0.01*i).timeout
		$Pp.set_external_direction(Vector3.RIGHT)
		await get_tree().create_timer(0.01*i).timeout
		$Pp.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(0.01*i).timeout
		$Pp.set_external_direction(Vector3.LEFT)
		await get_tree().create_timer(0.01*i).timeout
	$Pp.set_external_direction(Vector3.ZERO)
	$Pp.GRAVITY=ProjectSettings.get_setting("physics/3d/default_gravity")
	await get_tree().create_timer(0.1).timeout
	WorldFunc.cutscene=false
	$Pp.release_busy()
	
	$Pp.velocidad_mov=4
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Pp.position.x<=og_pos.x and $Pp.position.x<=og_pos.x+2.5 :
		$Pp/Pivot.position.x=$Pp.position.x
	$Pp/Pivot.position.y=og_pos.y
	$Pp/Pivot.position.z=og_pos.z
	pass


func _on_warp_int_iglesiamain_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	WorldFunc.cutscene=true
	$Pp.set_busy()
	$Pp.set_external_direction(Vector3.LEFT)
	await FadeLayer.fade_out()
	WorldFunc.cutscene=false
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_int_iglesiamain.tscn")
	
