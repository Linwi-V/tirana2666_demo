extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not WorldFunc.cinematic_2 ==false:
		$Pp.queue_free()
		$Warp.queue_free()
		var cam=load("res://Scenes/cinemateic cam/camera_cinematic.tscn").instantiate()
		var animacion =load("res://Scenes/cinemateic cam/animacion2.tscn").instantiate()
		cam.add_child(animacion)
		add_child(cam)
		$CameraCinematic.make_current()
		$CameraCinematic/AnimationPlayer.play("Cinematic_2")
		await get_tree().create_timer(23.0).timeout
		WorldFunc.cinematic_2 =true
		await FadeLayer.fade_out(1.0)
		await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_int.tscn")
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if get_node_or_null("Pp")!=null:
		if $Pp.position.y<-11:
			respawn()
		
	$WorldEnvironment.environment.sky_rotation.x+=delta/200
	pass

func respawn():
	$Pp.position= $Pp.last_safe_place
	
func _on_warp_casa_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	$Pp.set_busy()
	$Pp.set_external_direction(Vector3(0,0,-1))
	await FadeLayer.fade_out()
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_ext.tscn")
	pass # Replace with function body.
	


func _on_warp_dnc_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:

	$Pp.set_busy()
	
	WorldFunc.cutscene=true
	
	var tween1 = create_tween()
	var tween2 = create_tween()
	
	tween1.tween_property($Pp/Pivot/SpringArm3D/Camera3D, "fov", 55, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property($Pp/Pivot, "rotation:y", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(0.4).timeout
	
	MusicManager.stop_music(1)
	
	await get_tree().create_timer(1.2).timeout
	
	var dnc = load("res://Scenes/DNC/DNC.tscn").instantiate()
	dnc.get_node("DNC_Manager").acabado.connect(_on_dnc_acabado)
	dnc.get_node("DNC_Manager").cerrar.connect(_on_dnc_cerrar)

	add_sibling(dnc)
	$Pp/AnimationPlayer.play("DNC")
	pass # Replace with function body.

func _on_dnc_acabado():
	var tween = create_tween()
	tween.tween_property($Pp/Pivot, "rotation:y", 0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	$Pp/AnimationPlayer.stop()
	
func _on_dnc_cerrar():
	var tween = create_tween()
	tween.tween_property($Pp/Pivot/SpringArm3D/Camera3D, "fov", 75, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	#var dnc = get_parent().get_node("DNC")
	#dnc.visible=false
	#dnc.queue_free()
	$Pp.release_busy()
	
