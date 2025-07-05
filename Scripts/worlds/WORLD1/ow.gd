extends Node3D

var last_safe_position: Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if $Pp.position.y<-10:
		respawn()
		
	$WorldEnvironment.environment.sky_rotation.y+=delta/200
	pass

func respawn():
	$Pp.position= $Pp.last_safe_place
	
func _on_warp_casa_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	await FadeLayer.fade_out()
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2.tscn")
	pass # Replace with function body.
	
