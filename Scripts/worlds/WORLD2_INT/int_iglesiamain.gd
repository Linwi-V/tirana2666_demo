extends Node3D

var og_pos
const dialog1 = preload("res://Dialogues/worlds/World2/d1.dialogue")
const dialog1b = preload("res://Dialogues/worlds/World2/d1b.dialogue")
const dialog2 = preload("res://Dialogues/worlds/World2/d2.dialogue")
const dialog3 = preload("res://Dialogues/worlds/World2/d3.dialogue")
const dialog4 = preload("res://Dialogues/worlds/World2/d4.dialogue")
const dialog5 = preload("res://Dialogues/worlds/World2/d5.dialogue")
const dialog6 = preload("res://Dialogues/worlds/World2/d6.dialogue")

var portal: PackedScene= preload("res://Meshs/PORTAL.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	DialogueManager.dialogue_ended.connect(d_ended)
	$Pp.position=Vector3(-0,00,0)
	$Pp.fixed_cam=true
	$Pp/Pivot.active=false
	$Pp/Pivot.exterior=false
	$Pp/Pivot.top_level=true
	$Pp.position=Vector3(4.9,0,-1.571)
	$Pp/Pivot/SpringArm3D/Camera3D.fov = 55
	og_pos = $Pp/Pivot.position
	var npcs = $Level/npcs
	for npc in npcs.get_children():
		npc.get_node("SpriteEmotes").modulate=Color(0,0,0,0)
	
	if WorldFunc.primera_vez_w2_intmain: 
		$Pp/Pivot.rotation_degrees.x+=25
		WorldFunc.cutscene=true
		$Pp.set_busy()
		$Pp.velocidad_mov=0.4
		var fortunato = $Level/npcs/Fortunato
		fortunato.external_look=Vector3.FORWARD
		$Pp.set_current_npc(fortunato)
		_on_pp_dialog_changer(fortunato)
		
		await get_tree().create_timer(1).timeout
		$Pp.set_external_direction(Vector3.LEFT)
		await get_tree().create_timer(5).timeout
		$Pp.velocidad_mov=0.3
		DialogueManager.show_dialogue_balloon(dialog1)
		fortunato.external_look=Vector3.RIGHT
		create_tween().tween_property($Pp/Pivot,"rotation_degrees:x",0,0.4)
		await get_tree().create_timer(7).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.1).timeout
		#WorldFunc.cutscene=false
		#WorldFunc.primera_vez_w2_intmain=false
	elif WorldFunc.segunda_vez_w2_intmain:
		#pos de camara
		$Pp/Pivot.rotation_degrees.x+=0
		$Pp/Pivot.position.y-=1
		$Pp/Pivot.position.z-=2
		#vars de cutscene
		WorldFunc.cutscene=true
		$Pp.set_busy()
		$Pp.velocidad_mov=0.4
		var fortunato = $Level/npcs/Fortunato
		var esbirro1 = $Level/npcs/Esbirro1
		var esbirro2 = $Level/npcs/Esbirro2
		fortunato.position
		$Pp.position=fortunato.position
		$Pp.position.x=-($Pp.position.x)
		$Pp.set_current_npc(esbirro1)
		$Pp.current_dialog=dialog2
		esbirro1.position.z=0.3
		esbirro2.position.z=0.3
		#animacion
		await get_tree().create_timer(0.5).timeout
		DialogueManager.show_dialogue_balloon(dialog2)
	else:
		WorldFunc.cutscene=true
		npcs.get_node("Esbirro1").queue_free()
		npcs.get_node("Esbirro2").queue_free()
		$Pp.position=Vector3(0,0,17)
		$Pp/Pivot.position.z=13.9
		
		$Pp.set_busy()
		$Pp.velocidad_mov=2
		$Pp.set_external_direction(Vector3.FORWARD)
		await get_tree().create_timer(3.0).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.5).timeout
		$Pp.velocity.y+=2
		await get_tree().create_timer(0.5).timeout
		$Pp.velocity.y+=2
		await get_tree().create_timer(0.8).timeout
		$Pp.velocidad_mov=4
		$Pp.set_external_direction(Vector3.FORWARD)
		$Pp.current_npc=npcs.get_node("Fortunato")
		DialogueManager.show_dialogue_balloon(dialog5)
		await get_tree().create_timer(2.9).timeout
		$Pp.set_external_direction(Vector3.ZERO)
# Called every frame. 'delta' is the elapsed time s	ince the previous frame.
func _process(delta: float) -> void:
	if not WorldFunc.primera_vez_w2_intmain and not WorldFunc.segunda_vez_w2_intmain:
		if not $Pp.position.z<=og_pos.z-5 and $Pp.position.z<=og_pos.z+13.9 :
			$Pp/Pivot.position.z=$Pp.position.z
		#$Pp/Pivot.position.y=og_pos.y
	$Pp/Pivot.position.x=og_pos.x
	pass


func _on_pp_dialog_changer(npc: Variant) -> void:
	$Pp.set_busy()
	if npc.name == "Fortunato":
		$Pp.current_dialog=dialog1
	if npc.name == "Esbirro1":
		pass
	pass # Replace with function body.
	
func d_ended(dialog):
	if dialog==dialog1:
		
		
		$Pp.cam_final=Vector3.ZERO
		create_tween().tween_property($Pp/Pivot/SpringArm3D/Camera3D,"fov",55,0.4)
		create_tween().tween_property($Pp/Pivot,"rotation_degrees:x",25,0.4)
		var fortunato = $Level/npcs/Fortunato
		$Pp.set_current_npc(fortunato)
		_on_pp_dialog_changer(fortunato)
		var esbirro1 = $Level/npcs/Esbirro1
		var esbirro2 = $Level/npcs/Esbirro2
		$Pp.set_busy()
		
		$Pp.set_external_direction(Vector3.RIGHT)
		await get_tree().create_timer(1.0).timeout
		fortunato.external_look=Vector3.FORWARD
		await get_tree().create_timer(1.4).timeout
		$Pp.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(0.0).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.5).timeout
		$Pp.velocity.y+=2
		await get_tree().create_timer(1).timeout
		fortunato.set_busy()
		fortunato.velocidad_mov=0.3
		fortunato.external_look=(Vector3.BACK)
		await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.5).timeout
		fortunato.velocity.y+=2
		await get_tree().create_timer(1).timeout
		$Pp.set_current_npc(esbirro1)
		_on_pp_dialog_changer(esbirro1)
		var portalito1= portal.instantiate()

		add_child(portalito1)
		portalito1.position.y =-1.13+1.5
		portalito1.position.z =4.525
		portalito1.rotation_degrees.x=0
		var tween = create_tween()
		tween.tween_property($Pp/Pivot, "position:z",4 , 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		var tweem = create_tween()
		tweem.tween_property($Portal, "scale",Vector3(0.001,0.001,0.001) , 2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		esbirro1.velocity.y+=2
		esbirro2.velocity.y+=2
		await get_tree().create_timer(1.9).timeout
		$Portal.queue_free()
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		await get_tree().create_timer(0.2).timeout
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		
		
		create_tween().tween_property($Pp/Pivot,"rotation_degrees:x",25,0.4)
		DialogueManager.show_dialogue_balloon(dialog1b,"start",[self])
		esbirro1.external_look=Vector3.FORWARD
		esbirro2.external_look=Vector3.FORWARD
	elif dialog==dialog1b:
		var esbirro1 = $Level/npcs/Esbirro1
		var esbirro2 = $Level/npcs/Esbirro2
		esbirro1.set_busy()
		esbirro2.set_busy()
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		await get_tree().create_timer(0.2).timeout
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		await get_tree().create_timer(0.2).timeout
		esbirro1.set_external_direction(Vector3.FORWARD)
		await get_tree().create_timer(0.1).timeout
		esbirro2.set_external_direction(Vector3.FORWARD)
		await get_tree().create_timer(0.2).timeout
		var tween2 = create_tween()
		tween2.tween_property($Pp/Pivot, "position:z",0 , 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(0.2).timeout
		await FadeLayer.fade_out(0.2)
		WorldFunc.primera_vez_w2_intmain=false
		WorldFunc.start_battle(PartyData.active_party+["Fortunato"],["Esbirro","Esbirro"],"res://Assets/BTL/BGs/BTL_Dummy.tres",false, "res://Scripts/BTL/Events/tutorial2.gd")
		
	elif dialog==dialog2:
		var fortunato = $Level/npcs/Fortunato
		var esbirro1 = $Level/npcs/Esbirro1
		var esbirro2 = $Level/npcs/Esbirro2
		esbirro1.set_busy()
		esbirro2.set_busy()
		
		$Pp.clear_current_npc(null)
		
		var portalito1= portal.instantiate()
		portalito1.position.y =1.8
		portalito1.position.z =0.3
		portalito1.scale=Vector3(0.001,0.001,0.001)
		add_child(portalito1)
		var tweex = create_tween()
		tweex.tween_property($Portal, "scale",Vector3(1,1,1) , 1.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		await get_tree().create_timer(0.2).timeout
		esbirro1.velocity.y+=2
		await get_tree().create_timer(0.3).timeout
		esbirro2.velocity.y+=2
		await get_tree().create_timer(0.4).timeout

		var tweem=create_tween()
		var tween=create_tween()
		tween.tween_property(esbirro1, "position:y",5.5 , 3.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tweem.tween_property(esbirro2, "position:y",5.5 , 3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(2.9).timeout
		create_tween().tween_property($Portal, "scale",Vector3(0.001,0.001,0.001) , 1.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		esbirro1.queue_free()
		esbirro2.queue_free()
		
		
		await get_tree().create_timer(0.5).timeout

		$Pp.set_current_npc(fortunato)
		$Pp.current_dialog=dialog3
		
		DialogueManager.show_dialogue_balloon(dialog3)
		await get_tree().create_timer(0.5).timeout
		$Portal.queue_free()
	
		

	elif dialog==dialog3:
		$Pp.velocidad_mov=0.4
		$Pp.set_external_direction(Vector3.RIGHT)
		await get_tree().create_timer(2).timeout
		var portalito1= portal.instantiate()
		portalito1.position.x = $Pp.position.x+0.9
		portalito1.position.y =0.2
		portalito1.position.z =$Pp.position.z
		portalito1.scale=Vector3(0.001,0.001,0.001)
		portalito1.rotation_degrees.z=90
		add_child(portalito1)
		var tweex = create_tween()
		tweex.tween_property($Portal, "scale",Vector3(1,1,1) , 1.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(1.4).timeout
		$Pp.velocity.y+=3.5
		await get_tree().create_timer(0.2).timeout
		$Pp.GRAVITY=0
		$Pp.velocity.y=0
		create_tween().tween_property($Pp, "scale",Vector3(0.1,0.1,0.1) , 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		create_tween().tween_property($Portal, "scale",Vector3(0.001,0.001,0.001) , 1.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(1.5).timeout
		$Portal.queue_free()
		var fortunato = $Level/npcs/Fortunato
		$Pp.hide()
		fortunato.set_busy()
		fortunato.set_external_direction(Vector3.FORWARD)
		fortunato.velocidad_mov=0.1
		await get_tree().create_timer(1).timeout
		fortunato.set_external_direction(Vector3.ZERO)
		DialogueManager.show_dialogue_balloon(dialog4)
		
	elif dialog==dialog4:
		WorldFunc.segunda_vez_w2_intmain=false
		await FadeLayer.fade_out(1.0)
		await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_int_iglesiamain.tscn")
		
	elif dialog==dialog5:
		$Pp.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(2).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		DialogueManager.show_dialogue_balloon(dialog6)
		await get_tree().create_timer(0.2).timeout
		$Pp.velocidad_mov=0.3
		$Pp.set_external_direction(Vector3.FORWARD)
		await get_tree().create_timer(0.2).timeout
		$Pp.set_external_direction(Vector3.ZERO)
	elif dialog==dialog6:
		$Pp.velocidad_mov=4
		$Pp.set_external_direction(Vector3.BACK)
func _on_warp_int_iglesiamain_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	WorldFunc.cutscene=false
	await FadeLayer.fade_out(1.0)
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_ext.tscn")


func salto_esbirro1():
	var esbirro1 = $Level/npcs/Esbirro1
	esbirro1.velocity.y+=2
		
func salto_esbirro2():
	var esbirro2 = $Level/npcs/Esbirro2
	esbirro2.velocity.y+=2
