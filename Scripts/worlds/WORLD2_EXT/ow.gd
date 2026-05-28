extends Node3D

var titulo_d: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogueManager.dialogue_ended.connect(d_ended)
	if WorldFunc.cinematic_1 ==false:
			
		#matar
		var gemelo1=$Level/npcs/Gemelo1
		gemelo1.queue_free()
		var gemelo2=$Level/npcs/Gemelo2
		gemelo2.queue_free()
		
		
		
		$Pp.queue_free()
		$Warp.queue_free()
		var cam=load("res://Scenes/cinemateic cam/camera_cinematic.tscn").instantiate()
		var animacion =load("res://Scenes/cinemateic cam/animacion1.tscn").instantiate()
		cam.add_child(animacion)
		add_child(cam)
		$CameraCinematic.make_current()
		$CameraCinematic/AnimationPlayer.play("Cinematic_1")
		await get_tree().create_timer(18.0).timeout
		WorldFunc.cinematic_1 =true
		await FadeLayer.fade_out(1.0)
		await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_ext.tscn")
	
	elif WorldFunc.primera_vez_w2_ext:
		WorldFunc.primera_vez_w2_ext=false
		WorldFunc.cutscene=true
		WorldFunc.quest = "comprar_1"
		PartyData.active_party=["Katari"]
		$Pp.set_busy()
		$Pp.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(0.7).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		await get_tree().create_timer(0.5).timeout
		DialogueManager.show_dialogue_balloon(load("res://Dialogues/worlds/World2/EXT/d1.dialogue"))
	
	elif WorldFunc.quest=="casimiro":
		$Pp.fixed_cam=true
		WorldFunc.cutscene=true
		WorldFunc.quest="ladron"
		$Pp.position=(Vector3(-11.151,-2.452,-9.385))

		
		var gemelo1=$Level/npcs/Gemelo1
		gemelo1.global_position=(Vector3(-12.16,-2.452,-9.406))
		var gemelo2=$Level/npcs/Gemelo2
		gemelo2.global_position=(Vector3(-10.65,-2.452,-8.817))
		var casimiro = $Level/npcs/Casimiro
		casimiro.show()
		
		var ladron =$Level/npcs/Ladron
		ladron.global_position=Vector3(11.5,-2.452,-8)
		mirar("Ladron","arriba")
		var sprite_ladrona=load("res://Sprites/Chars/ladrona/ladrona_sprt.png")
		ladron.walk=sprite_ladrona
		var sprite_gemela=load("res://Sprites/Chars/gemelos/gemela_sprt.png")
		var sprite_gemelo=load("res://Sprites/Chars/gemelos/gemelo_sprt.png")
		var sprite_casimiro=load("res://Sprites/Chars/casimiro/casimiro_sprt.png")
		gemelo1.walk=sprite_gemelo
		gemelo2.walk=sprite_gemela
		casimiro.walk=sprite_casimiro
		
		$Level/npcs/Perro1.queue_free()
		$Level/npcs/Perro2.queue_free()
		$Level/npcs/Perro3.queue_free()
		$Level/npcs/Perro4.queue_free()
		
		
		gemelo1.get_node("CollisionShape3D").disabled=true
		gemelo1.get_node("CollisionShape3DFollow").disabled=false
		gemelo1.set_collision_layer_value(1,false )
		
		
		gemelo2.get_node("CollisionShape3D").disabled=true
		gemelo2.get_node("CollisionShape3DFollow").disabled=false
		gemelo2.set_collision_layer_value(1,false )
		
		casimiro.get_node("CollisionShape3D").disabled=true
		casimiro.get_node("CollisionShape3DFollow").disabled=false
		casimiro.set_collision_layer_value(1,false )
		
		gemelo1.set_follow($Pp)
		gemelo2.set_follow(gemelo1)
		casimiro.set_follow(gemelo2)
		
		
		mirar("Gemelo1","izquierda")
		$Pp.set_busy()
		var dialogo= load("res://Dialogues/worlds/World2/EXT/quests/terreno_baldio.dialogue")
		$Pp.current_dialog=(dialogo)
		$Pp.set_current_npc(casimiro)
		
		titulo_d="terreno_baldio_post"
		
		DialogueManager.show_dialogue_balloon(dialogo,"terreno_baldio_post",[self])
	
	elif WorldFunc.quest=="ladron":
		
		WorldFunc.cutscene=true
		WorldFunc.quest="post_ladron"
		
		$Pp.position=(Vector3(9.119,-2.452,-8.936))
		
		
		
		var gemelo1=$Level/npcs/Gemelo1
		gemelo1.global_position=(Vector3(8.8,-2.452,-8))
		var gemelo2=$Level/npcs/Gemelo2
		gemelo2.global_position=(Vector3(9.6,-2.452,-8))
		var casimiro = $Level/npcs/Casimiro
		casimiro.show()
		casimiro.global_position=(Vector3(9.2,-2.452,-7.1))
		var ladron =$Level/npcs/Ladron
		ladron.queue_free()
		var sprite_gemela=load("res://Sprites/Chars/gemelos/gemela_sprt.png")
		var sprite_gemelo=load("res://Sprites/Chars/gemelos/gemelo_sprt.png")
		var sprite_casimiro=load("res://Sprites/Chars/casimiro/casimiro_sprt.png")
		
		gemelo1.walk=sprite_gemelo
		gemelo2.walk=sprite_gemela
		casimiro.walk=sprite_casimiro
		$Level/npcs/Perro1.queue_free()
		$Level/npcs/Perro2.queue_free()
		$Level/npcs/Perro3.queue_free()
		$Level/npcs/Perro4.queue_free()
		
		
		gemelo1.get_node("CollisionShape3D").disabled=true
		gemelo1.get_node("CollisionShape3DFollow").disabled=false
		gemelo1.set_collision_layer_value(1,false )
		
		gemelo2.get_node("CollisionShape3D").disabled=true
		gemelo2.get_node("CollisionShape3DFollow").disabled=false
		gemelo2.set_collision_layer_value(1,false )
		
		casimiro.get_node("CollisionShape3D").disabled=true
		casimiro.get_node("CollisionShape3DFollow").disabled=false
		casimiro.set_collision_layer_value(1,false )
		
		gemelo1.set_busy()
		gemelo2.set_busy()
		casimiro.set_busy()
		
		mirar("Gemelo1","izquierda")
		mirar("Gemelo2","izquierda")
		mirar("Casimiro","izquierda")
		
		$Pp.set_busy()
		$Pp/Sprite3D.frame_coords.y=2
		var dialogo= load("res://Dialogues/worlds/World2/EXT/d4.dialogue")
		$Pp.current_dialog=(dialogo)
		$Pp.set_current_npc(casimiro)
		
		titulo_d="post_ladron"
		await get_tree().create_timer(1.0).timeout
		DialogueManager.show_dialogue_balloon(dialogo,"start",[self])




func d_ended(dialog):
	if dialog.titles=={"primera_vez":"1"}:
		WorldFunc.cutscene=false
		$Pp.release_busy()
		
		
	elif titulo_d=="gemelos":
		$Pp.velocidad_mov=0.5
		$Pp.set_external_point(Vector3(-10,0,12))
		await get_tree().create_timer(1.0).timeout
		$Pp.set_external_direction(Vector3.ZERO)
		$Pp.velocity.y+=2
		await get_tree().create_timer(1.5).timeout
		var gemelo1=$Level/npcs/Gemelo1
		var gemelo2=$Level/npcs/Gemelo2
		

		await get_tree().create_timer(0.3).timeout
		var dialogo= load("res://Dialogues/worlds/World2/EXT/d3.dialogue")
		$Pp.current_dialog=(dialogo)
		$Pp.set_current_npc(gemelo1)
		
		titulo_d="robada"
		
		DialogueManager.show_dialogue_balloon(dialog,"robada",[self])
		await get_tree().create_timer(0.5).timeout
		
		
	elif titulo_d=="robada":
		WorldFunc.cutscene=false
		await get_tree().create_timer(0.5).timeout
		$Pp.release_busy()
		var gemelo1=$Level/npcs/Gemelo1
		var gemelo2=$Level/npcs/Gemelo2
		

		
		gemelo1.get_node("CollisionShape3D").disabled=true
		gemelo1.get_node("CollisionShape3DFollow").disabled=false
		gemelo1.set_collision_layer_value(1,false )
		
		gemelo2.get_node("CollisionShape3D").disabled=true
		gemelo2.get_node("CollisionShape3DFollow").disabled=false
		gemelo2.set_collision_layer_value(1,false )
		
		gemelo1.set_follow($Pp)
		gemelo2.set_follow(gemelo1)
		
		PartyData.active_party=["Katari","Gemelo 1", "Gemelo 2"]
		$Pp.velocidad_mov=4
		WorldFunc.quest="casimiro"
		$Level/npcs/Perro1.show()
		mirar("Perro1","derecha")
		$Level/npcs/Perro2.show()
		mirar("Perro2","arriba")
		$Level/npcs/Perro3.show()
		mirar("Perro3","derecha")
		$Level/npcs/Perro4.show()
		mirar("Perro4","arriba")
		var sprite_perro=load("res://Sprites/Chars/randoms/perro/perro_sprt.png")
		$Level/npcs/Perro1.walk=sprite_perro
		$Level/npcs/Perro2.walk=sprite_perro
		$Level/npcs/Perro3.walk=sprite_perro
		$Level/npcs/Perro4.walk=sprite_perro
		$Level/npcs/Casimiro.show()
		var casimiro=$Level/npcs/Casimiro
		var sprite_casimiro=load("res://Sprites/Chars/casimiro/casimiro_sprt.png")
		casimiro.walk=sprite_casimiro


	
	elif titulo_d=="terreno_baldio":
		$Level/npcs/Perro1.set_busy()
		$Level/npcs/Perro1.set_external_point($Pp.position)
		$Level/npcs/Perro2.set_busy()
		$Level/npcs/Perro2.set_external_point($Pp.position)
		$Level/npcs/Perro3.set_busy()
		$Level/npcs/Perro3.set_external_point($Pp.position)
		$Level/npcs/Perro4.set_busy()
		$Level/npcs/Perro4.set_external_point($Pp.position)
		await FadeLayer.fade_out(0.5)
		PartyData.active_party=["Katari","Gemelo 1", "Gemelo 2","Casimiro"]
		WorldFunc.start_battle(PartyData.active_party,["Perro","Perro","Perro","Perro"],"res://Assets/BTL/BGs/BTL_Dummy.tres",false,"res://Scripts/BTL/Events/casimiro.gd")
	
	elif titulo_d=="terreno_baldio_post":
		WorldFunc.cutscene=false
		await get_tree().create_timer(0.5).timeout
		$Pp.release_busy()	
		
	elif titulo_d=="pelea_ladron":
		WorldFunc.cutscene=false
		await FadeLayer.fade_out(0.5)
		WorldFunc.start_battle(PartyData.active_party,["Ladrón"],"res://Assets/BTL/BGs/BTL_Dummy.tres",false,"res://Scripts/BTL/Events/ladron.gd")
	
	elif titulo_d=="post_ladron":
		WorldFunc.cutscene=true
		WorldFunc.quest="comprar_2"
		titulo_d=""
		var gemelo1=$Level/npcs/Gemelo1
		var gemelo2=$Level/npcs/Gemelo2
		var casimiro=$Level/npcs/Casimiro
		gemelo1.rotation.y=deg_to_rad(-90)
		gemelo2.set_follow(gemelo1)
		casimiro.set_follow(gemelo2)
		gemelo1.set_external_direction(Vector3.BACK)
		await get_tree().create_timer(2.5).timeout
		gemelo1.queue_free()
		gemelo2.queue_free()
		casimiro.queue_free()
		WorldFunc.cutscene=false
		var tienda = load("res://Scenes/npcs/npc.tscn").instantiate()
		tienda.name="Tienda"
		tienda.GRAVITY=0
		tienda.get_node("CollisionShape3D").disabled=true
		tienda.position=Vector3(-10.2,-0.3,12.5)
		
		#tienda.talks=true
		tienda.get_node("Sprite3D").hide()
		tienda.get_node("Sombra").hide()
		get_node("Level").get_node("npcs").add_child(tienda)
		
		tienda.exclamar()
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
	create_tween().tween_property($Pp, "yaw", shortest_rad, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_pp_dialog_changer(npc: Variant) -> void:
	$Pp.set_busy()
	if npc.name =="Tienda":
		rotate_pp_to(30)
		titulo_d="comprar_tienda"
		$Pp.current_dialog=load("res://Dialogues/worlds/World2/EXT/quests/tienda.dialogue")
		
		
	elif npc.name == "Ladron":
		
		var sprite_ladrona=load("res://Sprites/Chars/ladrona/ladrona_sprt.png")
		$Level/npcs/Ladron.walk=sprite_ladrona
		mirar("Ladron","izquierda")
		titulo_d="pelea_ladron"
		create_tween().tween_property($Level/npcs/Ladron,"position:x",12.5,0.5 )
		$Pp.current_dialog=load("res://Dialogues/worlds/World2/EXT/quests/ladron_rincon.dialogue")
		$Pp.fixed_cam=false
		$Pp/Pivot/SpringArm3D/Camera3D.global_position= $Areas_cutscenes/AreaLadron/Camera3D.global_position
		$Pp/Pivot/SpringArm3D/Camera3D.global_rotation= Vector3(deg_to_rad(-19.3),0,0)
		$Pp/Pivot/SpringArm3D/Camera3D.current=true
		$Level/npcs/Gemelo1.position.x=$Pp.position.x-2
		$Level/npcs/Gemelo2.position.x=$Pp.position.x-2
		$Level/npcs/Casimiro.position.x=$Pp.position.x-2
		$Level/npcs/Gemelo1.position.z=$Pp.position.z-2
		$Level/npcs/Gemelo2.position.z=$Pp.position.z
		$Level/npcs/Casimiro.position.z=$Pp.position.z+2
		$Level/npcs/Gemelo1.follow_distance=1.3
		$Level/npcs/Gemelo2.follow_distance=1.3
		$Level/npcs/Casimiro.follow_distance=1.3
		$Level/npcs/Gemelo1.set_follow($Pp)
		$Level/npcs/Gemelo2.set_follow($Pp)
		$Level/npcs/Casimiro.set_follow($Pp)

	elif npc.name =="CasaKatari":
		if WorldFunc.quest=="fin_demo":
			$Pp.current_dialog=load("res://Dialogues/worlds/World2/EXT/quests/fin_demo.dialogue")
			
		#aqui va el warp
		else:
			$Pp.current_dialog=load("res://Dialogues/worlds/World2/EXT/quests/casa.dialogue")











# Callbacks conectados a las señales de las áreas

func _on_area_norte_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body == $Pp and WorldFunc.quest!="post_ladron":
			rotate_pp_to(0)

func _on_area_sur_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body == $Pp:
			rotate_pp_to(180)

func _on_area_este_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
		
	if get_node_or_null("Pp"):
		if body == $Pp:
			rotate_pp_to(270)
			if WorldFunc.quest == "comprar_1":
				WorldFunc.cutscene=true
				$Pp.set_busy()
				$Pp.external_direction=Vector3.BACK
				var sprite_ladrona=load("res://Sprites/Chars/ladrona/ladrona_sprt.png")
				$Level/npcs/Ladron.walk=sprite_ladrona
				await get_tree().create_timer(0.5).timeout
				$Level/npcs/Ladron.set_busy()
				$Level/npcs/Ladron.velocidad_mov=5
				$Level/npcs/Ladron.GRAVITY=0
				$Level/npcs/Ladron/CollisionShape3D.disabled=true
				$Level/npcs/Ladron.external_direction=Vector3.FORWARD
				$Level/npcs/Ladron.external_look=Vector3.FORWARD
				DialogueManager.show_dialogue_balloon(load("res://Dialogues/worlds/World2/EXT/d2.dialogue"),"start",[self])
				await get_tree().create_timer(0.3).timeout
				
				$Level/npcs/Ladron.velocidad_mov=5

				
				$Pp.external_direction=Vector3.ZERO
				$Pp.velocity.y+=2
				await get_tree().create_timer(1.5).timeout
				$Level/npcs/Ladron.external_direction=Vector3.ZERO
				$Level/npcs/Ladron.position.y-=10
				$Level/npcs/Ladron.hide()
				WorldFunc.cutscene=false
				$Pp.release_busy()
				WorldFunc.quest = "comprar_robado"

func _on_area_oeste_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body == $Pp:
			rotate_pp_to(90)


func _on_tienda_d_3_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body == $Pp and WorldFunc.quest == "comprar_robado" and WorldFunc.cutscene!=true:
			WorldFunc.cutscene=true
			rotate_pp_to(90)
			
			$Pp.set_busy()
			$Pp.velocidad_mov=3
			$Pp.set_external_point(Vector3(-10,0,12))
			await get_tree().create_timer(0.7).timeout
			$Pp.set_external_direction(Vector3.ZERO)
			var gemelo1=$Level/npcs/Gemelo1
			var gemelo2=$Level/npcs/Gemelo2
			var sprite_gemela=load("res://Sprites/Chars/gemelos/gemela_sprt.png")
			var sprite_gemelo=load("res://Sprites/Chars/gemelos/gemelo_sprt.png")
			
			gemelo1.walk=sprite_gemelo
			gemelo2.walk=sprite_gemela
			
			gemelo1.position=Vector3(4,0,17.5)
			gemelo2.position=Vector3(4,0,16.2)
			
			gemelo1.rotation.y = 90
			gemelo2.rotation.y = 90
			
			gemelo1.set_busy()
			gemelo2.set_busy()
			gemelo1.set_external_direction(Vector3.LEFT)
			gemelo2.set_external_direction(Vector3.LEFT)
			
			await get_tree().create_timer(0.3).timeout
			var dialog= load("res://Dialogues/worlds/World2/EXT/d3.dialogue")
			$Pp.current_dialog=(dialog)
			
			DialogueManager.show_dialogue_balloon(dialog,"grito",[self])
			await get_tree().create_timer(2.8).timeout

			gemelo1.external_look=Vector3.RIGHT
			gemelo1.set_external_direction(Vector3.ZERO)
			salto("Gemelo1")
			await get_tree().create_timer(0.2).timeout
			$Pp.set_current_npc(gemelo1)
			titulo_d="gemelos"
			DialogueManager.show_dialogue_balloon(dialog,"gemelos",[self])
			gemelo2.external_look=Vector3.RIGHT
			gemelo2.set_external_direction(Vector3.ZERO)
			salto("Gemelo2")
		

	pass # Replace with function body.



func _on_area_terreno_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body==$Pp:
			$Pp.fixed_cam=true
			$Pp.yaw=deg_to_rad(50)
			var pos_final_cam = $Areas_cam/AreaTerreno/Camera3D.position
			var rot_final_cam = $Areas_cam/AreaTerreno/Camera3D.rotation
			$Areas_cam/AreaTerreno/Camera3D.global_position= get_viewport().get_camera_3d().global_position
			$Areas_cam/AreaTerreno/Camera3D.global_rotation= get_viewport().get_camera_3d().global_rotation
			var twink = create_tween()
			var twonk= create_tween()
			twink.tween_property($Areas_cam/AreaTerreno/Camera3D,"position",pos_final_cam,0.4)
			twonk.tween_property($Areas_cam/AreaTerreno/Camera3D,"rotation",rot_final_cam,0.4)
			$Areas_cam/AreaTerreno/Camera3D.current=true

func _on_area_terreno_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
		
	if get_node_or_null("Pp"):
		if body==$Pp:
			if body.position.x>-8:
				$Pp.fixed_cam=false
				$Areas_cam/AreaTerreno/Camera3D.current=false
				rotate_pp_to(0)
			
		

func _on_area_casimiro_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body==$Pp:
			if WorldFunc.quest=="casimiro":
				WorldFunc.cutscene=true
				body.yaw=-0.3
				var pos_final_cam = $Areas_cam/AreaCasimiro/Camera3D.position
				var rot_final_cam = $Areas_cam/AreaCasimiro/Camera3D.rotation
				$Areas_cam/AreaCasimiro/Camera3D.global_position= get_viewport().get_camera_3d().global_position
				$Areas_cam/AreaCasimiro/Camera3D.global_rotation= get_viewport().get_camera_3d().global_rotation
				var twink = create_tween()
				var twonk= create_tween()
				twink.tween_property($Areas_cam/AreaCasimiro/Camera3D,"position",pos_final_cam,0.4)
				twonk.tween_property($Areas_cam/AreaCasimiro/Camera3D,"rotation",rot_final_cam,0.4)
				$Areas_cam/AreaCasimiro/Camera3D.current=true
				var gemelo1=$Level/npcs/Gemelo1
				var gemelo2=$Level/npcs/Gemelo2
				gemelo1.set_busy()
				gemelo2.set_busy()
				gemelo1.yaw=-0.3
				gemelo2.yaw=-0.3
				gemelo1.position.x= -12.16
				gemelo1.position.x= -10.65
				$Pp.set_busy()
				$Pp.velocidad_mov=1
				gemelo1.velocidad_mov=4
				gemelo2.velocidad_mov=4
				$Pp.set_external_point(Vector3(-11.151,-2.452,-9.385))
				gemelo1.set_external_point(Vector3(-12.16,-2.452,-9.406))
				gemelo2.set_external_point(Vector3(-10.65,-2.452,-8.817))
				await get_tree().create_timer(1.5).timeout
				
				gemelo2.set_external_direction(Vector3.ZERO)
				var dialog= load("res://Dialogues/worlds/World2/EXT/quests/terreno_baldio.dialogue")
				$Pp.current_dialog=(dialog)
				titulo_d="terreno_baldio"
				$Pp.current_npc=$Level/npcs/Casimiro
				DialogueManager.show_dialogue_balloon(dialog,"terreno_baldio",[self])
				
			if WorldFunc.quest=="ladron" or WorldFunc.quest=="comprar_2":
				body.yaw=-0.3
				var pos_final_cam = $Areas_cam/AreaCasimiro/Camera3D.position
				var rot_final_cam = $Areas_cam/AreaCasimiro/Camera3D.rotation
				$Areas_cam/AreaCasimiro/Camera3D.global_position= get_viewport().get_camera_3d().global_position
				$Areas_cam/AreaCasimiro/Camera3D.global_rotation= get_viewport().get_camera_3d().global_rotation
				var twink = create_tween()
				var twonk= create_tween()
				twink.tween_property($Areas_cam/AreaCasimiro/Camera3D,"position",pos_final_cam,0.4)
				twonk.tween_property($Areas_cam/AreaCasimiro/Camera3D,"rotation",rot_final_cam,0.4)
				$Areas_cam/AreaCasimiro/Camera3D.current=true
				
			elif WorldFunc.quest=="comprar_1":
				
				$Pp.set_busy()
				var dialog= load("res://Dialogues/worlds/World2/EXT/quests/terreno_baldio.dialogue")
				$Pp.current_dialog=(dialog)
				titulo_d="terreno_baldio_pre"
				$Pp.velocidad_mov=1
				$Pp.set_external_direction(Vector3.BACK)
				DialogueManager.show_dialogue_balloon(dialog,"terreno_baldio_pre",[self])
				await get_tree().create_timer(1.0).timeout
				$Pp.set_external_direction(Vector3.ZERO)
				$Pp.velocidad_mov=4
				$Pp.release_busy()




func _on_area_casimiro_cut_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body ==$Pp and WorldFunc.quest=="casimiro":
			$Pp.set_external_direction(Vector3.ZERO)
		
func _on_area_casimiro_cut_g_1_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:

	if get_node_or_null("Level/npcs/Gemelo1")and WorldFunc.quest=="casimiro":
		if body== $Level/npcs/Gemelo1:
			body.set_external_direction(Vector3.ZERO)
			body.external_look=Vector3.FORWARD
	pass # Replace with function body.		
	
func _on_area_casimiro_cut_g_2_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Level/npcs/Gemelo2") and WorldFunc.quest=="casimiro":
		
		if body== $Level/npcs/Gemelo2:
			body.set_external_direction(Vector3.ZERO)
			body.external_look=Vector3.FORWARD
	pass # Replace with function body.		
		
		
func _on_area_ladron_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body ==$Pp and WorldFunc.quest!="post_ladron":
			$Pp.fixed_cam=true
			
			var pos_final_cam = $Areas_cutscenes/AreaLadron/Camera3D.position
			var rot_final_cam = $Areas_cutscenes/AreaLadron/Camera3D.rotation

			$Areas_cutscenes/AreaLadron/Camera3D.global_position= get_viewport().get_camera_3d().global_position
			$Areas_cutscenes/AreaLadron/Camera3D.global_rotation= get_viewport().get_camera_3d().global_rotation
			var twink = create_tween()
			var twonk= create_tween()
			twink.tween_property($Areas_cutscenes/AreaLadron/Camera3D,"position",pos_final_cam,0.4)
			twonk.tween_property($Areas_cutscenes/AreaLadron/Camera3D,"rotation",rot_final_cam,0.4)

			$Areas_cutscenes/AreaLadron/Camera3D.current=true
			$Pp.yaw=0
			$Pp.set_busy()
			$Pp.external_direction=Vector3.ZERO
			await get_tree().create_timer(0.4).timeout
			$Pp.release_busy()
			$Pp.yaw=deg_to_rad(-90)
			$Pp/Pivot.rotation.y=0
			
		elif body ==$Pp and WorldFunc.quest=="post_ladron":
			$Pp.fixed_cam=true
			
			var pos_final_cam = $Areas_cutscenes/AreaLadron/Camera3D.position
			var rot_final_cam = $Areas_cutscenes/AreaLadron/Camera3D.rotation

			$Areas_cutscenes/AreaLadron/Camera3D.global_position= get_viewport().get_camera_3d().global_position
			$Areas_cutscenes/AreaLadron/Camera3D.global_rotation= get_viewport().get_camera_3d().global_rotation
			var twink = create_tween()
			var twonk= create_tween()
			twink.tween_property($Areas_cutscenes/AreaLadron/Camera3D,"position",pos_final_cam,0.4)
			twonk.tween_property($Areas_cutscenes/AreaLadron/Camera3D,"rotation",rot_final_cam,0.4)
			
			$Areas_cutscenes/AreaLadron/Camera3D.current=true

			$Pp.yaw=deg_to_rad(-90)
			

func _on_area_ladron_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if get_node_or_null("Pp"):
		if body==$Pp:
			$Pp.fixed_cam=false
			$Areas_cutscenes/AreaLadron/Camera3D.current=false
			body.rotation.y=0
			rotate_pp_to(0)
			





##_----------anuimaciones

func salto(nodo:String):
	if nodo=="":
		$Pp.velocity.y+=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		nodet.velocity.y +=2

func lanzar_piedra(nodo:String):
	if nodo=="":
		$Pp.velocity.y+=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		create_tween().tween_property(nodet,"position:z",nodet.position.z+0.5,1.0)
		await get_tree().create_timer(1.1).timeout
		create_tween().tween_property(nodet,"position:z",nodet.position.z-0.5,0.3)
		await get_tree().create_timer(0.4).timeout
		
func mirar(nodo:String,dir:String):
	if nodo=="":
		$Pp.velocity.y+=2
	else:
		var nodet = $Level/npcs.get_node(nodo)
		match dir:
			"derecha": nodet.external_look=Vector3.RIGHT
			"izquierda": nodet.external_look=Vector3.LEFT
			"arriba": nodet.external_look=Vector3.FORWARD
			"abajo": nodet.external_look=Vector3.BACK
			
func tirar_d_arriba():
	var layerb = $"/root/main/ExampleBalloon"
	layerb.layer=69

func tirar_d_abajo():
	var layerb = $"/root/main/ExampleBalloon"
	layerb.layer=67
	
func cambio_npc(nodo:String):
	if nodo=="":
		$Pp.current_npc=null
	else:
		var nodet = $Level/npcs.get_node(nodo)
		$Pp.current_npc=nodet
		$Pp.d_started(null)






#sete de hablamientos
