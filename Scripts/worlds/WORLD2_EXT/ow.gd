extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(d_ended)
	if not WorldFunc.cinematic_1 ==false:
		
		#matar
		var gemelo1=$Pueblo/npcs/Gemelo1
		gemelo1.queue_free()
		var gemelo2=$Pueblo/npcs/Gemelo2
		gemelo2.queue_free()
		
		
		
		$Pp.queue_free()
		$Warp.queue_free()
		var cam=load("res://Scenes/cinemateic cam/camera_cinematic.tscn").instantiate()
		var animacion =load("res://Scenes/cinemateic cam/animacion1.tscn").instantiate()
		cam.add_child(animacion)
		add_child(cam)
		$CameraCinematic.make_current()
		$CameraCinematic/AnimationPlayer.play("Cinematic_1")
		await get_tree().create_timer(9.0).timeout
		WorldFunc.cinematic_1 =true
		await FadeLayer.fade_out(1.0)
		await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_ext.tscn")
	
	elif WorldFunc.primera_vez_w2_ext:
		WorldFunc.cutscene=true
		$Pp.set_busy()
		$Pp.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(0.7).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.5).timeout
		DialogueManager.show_dialogue_balloon(load("res://Dialogues/worlds/World2/EXT/d1.dialogue"))
		var gemelo1=$Pueblo/npcs/Gemelo1
		gemelo1.set_follow($Pp)
		gemelo1.get_node("CollisionShape3D").disabled=true
		gemelo1.get_node("CollisionShape3DFollow").disabled=false
		gemelo1.set_collision_layer_value(1,false )
		
		
		


func d_ended(dialog):
	if dialog.titles=={"primera_vez":"1"}:
		WorldFunc.cutscene=false
		$Pp.release_busy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func normalize_angle_deg(angle: float) -> float:
	return fmod((angle + 360.0), 360.0)

func shortest_angle(from: float, to: float) -> float:
	var delta := fmod((to - from + 540.0), 360.0) - 180.0
	return from + delta

func rotate_pp_to(target_angle_deg: float) -> void:
	var current_yaw_deg := rad_to_deg($Pp.yaw)
	var target_normalized := normalize_angle_deg(target_angle_deg)
	var shortest := shortest_angle(current_yaw_deg, target_normalized)
	var shortest_rad := deg_to_rad(shortest)
	create_tween().tween_property($Pp, "yaw", shortest_rad, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# Callbacks conectados a las señales de las áreas

func _on_area_norte_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == $Pp:
		rotate_pp_to(0)

func _on_area_sur_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == $Pp:
		rotate_pp_to(180)

func _on_area_este_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == $Pp:
		rotate_pp_to(90)

func _on_area_oeste_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == $Pp:
		rotate_pp_to(270)
