extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if WorldFunc.cinematic_1 ==false:
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
		await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_int.tscn")
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
