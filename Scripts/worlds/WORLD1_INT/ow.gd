extends Node3D

const dialog = preload("res://Dialogues/prueba.dialogue")
const dialog2 = preload("res://Dialogues/worlds/World1/main/d2.dialogue")
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	if WorldFunc.primera_vez_w1_int:
		WorldFunc.cutscene=true
		WorldFunc.primera_vez_w1_int=false
		$Pp.set_busy()
		$Pp.velocidad_mov=0.3
		$Pp.set_external_direction(Vector3.RIGHT)
		var tortux = $Level/npcs/Tortu
		tortux.set_busy()
		tortux.set_external_direction(Vector3.LEFT)
		tortux.velocidad_mov=0.3
		await get_tree().create_timer(1).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		tortux.set_external_direction(Vector3.ZERO)
		$Pp.set_current_npc(tortux)
		$Pp.d_started(dialog)
		await get_tree().create_timer(0.5).timeout
		tortux.velocity.y+=2
		await get_tree().create_timer(0.5).timeout
		tortux.velocity.y+=2
		await get_tree().create_timer(0.5).timeout
		tortux.velocity.y+=2
		await get_tree().create_timer(0.7).timeout
		tortux.set_external_direction(Vector3.RIGHT)
		await get_tree().create_timer(0.2).timeout
		
		tortux.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.5).timeout
		tortux.velocidad_mov=5
		tortux.set_external_direction(Vector3.LEFT)
		tortux.velocity.y+=2
		await FadeLayer.fade_out(0.2)
		WorldFunc.start_battle(PartyData.active_party,["Eterna Ancestral"],"res://Assets/BTL/BGs/BTL_Dummy.tres",true, "res://Scripts/BTL/Events/tutorial1.gd")
		
	else:
		#posoicionar
		#$Pp/Pivot/SpringArm3D/Camera3D.fov = 65
		$Pp.position=Vector3(0,1,4)
		WorldFunc.cutscene=false
		$Pp/Pivot.exterior=false
		$Pp/Pivot.top_level=true
		$Pp.position=Vector3(-0.4,0.7,0.8)
		$Level/npcs/Tortu.position.x=0.4
		_on_pp_dialog_changer($Level/npcs/Tortu)
		$Pp.set_current_npc($Level/npcs/Tortu)
		DialogueManager.show_dialogue_balloon(dialog2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pp_dialog_changer(npc: Variant) -> void:
	$Pp.set_busy()
	if npc.name == "Tortu":
		$Pp.current_dialog=dialog2
	pass # Replace with function body.


func _on_warp_ext_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	$Pp.set_busy()
	$Pp.set_external_direction(Vector3(1,1,1))
	MusicManager.stop_music(0.5)
	await FadeLayer.fade_out()
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_ext.tscn")
