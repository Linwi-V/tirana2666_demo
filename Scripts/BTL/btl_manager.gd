extends Node

#------------------INSTANCIAS-------------
@export var Enemy : PackedScene
@export var Ally : PackedScene

#-----------PARA DIALOGOS-----------------
var _msg_panel
var _msg_label
#-----------SCRIPT DE PELEAS OPCIONAL---------
var battle_event_controller: Node = null

#--------------ESTADOS FSM----------
enum BattleState {
	IDLE,
	DIALOGUE,
	PLAYER_SELECTING,
	TARGET_SELECTING,
	PLAYER_ACTING,
	ENEMY_TURN,
	VICTORY,
	DEFEAT
}
#-------------- VAR FSM-----------
var current_state

#-----------FLAGS PELEA----------
var ambush 
var og_state

#-----------VAR DINAMICAS PELEA-----------
var turn = 0

var current_ally_index := 0
var player_actions := {}

var target_index = 0
var enemy_list = []

# Lista dinámica de nodos que recibirán target (aliados/enemigos)
var target_list: Array = []

var current_action_index = 0

var enemy_actions := []
var current_enemy_index := 0


#-------override para comandos------

var command_overrides := {}




func _ready() -> void:
	#----------- SEÑALES DIALOGOS--------
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	#---------------panel acciones-----------
	_msg_panel = $UI/CombatMsgPanel
	_msg_label = $UI/CombatMsgPanel/MarginContainer/CombatMsgLabel

	#-----------EMBOSCADA--------------
	ambush = WorldFunc.BTL_AMBUSH
	
	#-----------------FOndo-------------
	$Background.texture = load(WorldFunc.BTL_BG)
	
	
	#------------------crea aliados-------
	for i in WorldFunc.Party_BTL.size():
		#-----------------vars-----------
		var chars = WorldFunc.Party_BTL[i]
		var new_ally = Ally.instantiate()
		var retrato = new_ally.get_node("Ally")
		#--------------cambio nombre----------
		new_ally.name=chars
		#--------entrega id y textura----------
		new_ally.character_id=chars
		retrato.texture = load(PartyData.characters[chars]["textura"])
		#---------------señales---------------
		new_ally.hp_changed.connect(_on_ally_hp_changed)
		new_ally.died.connect(_on_ally_died)
		#-------------añade a escena---------
		get_node("Party/AllyContainers").add_child(new_ally)
	
	
	#----------crea enemigos-------------
	for i in WorldFunc.Enemy_BTL.size():
		#-------------vars-------------
		var chars = WorldFunc.Enemy_BTL[i]
		var new_enemy = Enemy.instantiate()
		var retrato = new_enemy.get_node("Enemy")
		#----------cambio nombre-------
		new_enemy.name=chars+str(i)
		#---------entrega id y textuRa----------
		new_enemy.character_id=chars
		retrato.texture = load(EnemyData.enemies[chars]["textura"])
		#-------------señales----------------
		new_enemy.hp_changed.connect(_on_enemy_hp_changed)
		new_enemy.died.connect(_on_enemy_died)
		#-------------orden en pantalla---------
		if i <3:
			get_node("Enemies/EnemyContainersFront").add_child(new_enemy)
		else:
			get_node("Enemies/EnemyContainersBack").add_child(new_enemy)
			if WorldFunc.Enemy_BTL.size() ==4:
				var dummy = Control.new()
				get_node("Enemies/EnemyContainersBack").add_child(dummy)
	
	#--------- CARGA SCRIPT OPCIONAL PELEA--------
	if WorldFunc.BTL_EVENT_SCRIPT_PATH != "":
		var battle_event_script = load(WorldFunc.BTL_EVENT_SCRIPT_PATH)
		if battle_event_script:
			battle_event_controller = battle_event_script.new()
			add_child(battle_event_controller)
	
	#------Setea ESTADO---------------
	if ambush:
		_change_state(BattleState.ENEMY_TURN)
	else:
		_change_state(BattleState.IDLE)
	

#-------------FSM LOGICA AQUI----------------

func _change_state(new_state: BattleState) -> void:
	if current_state == BattleState.VICTORY or current_state == BattleState.DEFEAT:
		return

	match new_state:
		BattleState.IDLE:
			handle_state(BattleState.IDLE, func() -> void:
				turn += 1
				print("TURNO: " + str(turn))
				print("IDLE")
				check_combat_end()
				current_ally_index = 0
				await get_tree().create_timer(1.0).timeout
				_change_state(BattleState.PLAYER_SELECTING)
			)

		BattleState.DIALOGUE:
			handle_state(BattleState.DIALOGUE, func() -> void:
				print("DIALOGUE")
			)

		BattleState.PLAYER_SELECTING:
			handle_state(BattleState.PLAYER_SELECTING, func() -> void:

				await get_tree().process_frame
				
		# 1) Saltar aliados muertos
				while current_ally_index < WorldFunc.Party_BTL.size():
					var actor_id = WorldFunc.Party_BTL[current_ally_index]
					var node: Control = $Party/AllyContainers.get_node_or_null(actor_id)
					if node and not node.rip:
						break
					current_ally_index += 1

				# 2) Si no queda ningún aliado vivo → DERROTA
				if get_alive_allies().is_empty():
					_change_state(BattleState.DEFEAT)
					return

				# 3) Si pasamos el final de la lista (p. ej. todos actuaron), vamos a ACTING
				if current_ally_index >= WorldFunc.Party_BTL.size():
					_change_state(BattleState.PLAYER_ACTING)
					return


				set_panel_comandos(true)
				_apply_command_overrides()
				print("PLAYER SELECT")
			)
		BattleState.TARGET_SELECTING:
			handle_state(BattleState.TARGET_SELECTING, func() -> void:
				set_panel_comandos(false)
				print("TARGET_SELECTING")
				var actor  = WorldFunc.Party_BTL[current_ally_index]
				var action = player_actions[actor]
				target_list  = build_target_list(action.targets)
				target_index = 0
				highlight_target_list(target_list, true, target_index)
				highlight_current_ally(true)
				)

		BattleState.PLAYER_ACTING:
			handle_state(BattleState.PLAYER_ACTING, func() -> void:
				print(player_actions)
				perform_player_actions()
				print("PLAYER ACTS")
			)

			
		BattleState.ENEMY_TURN:
			handle_state(BattleState.ENEMY_TURN, func() -> void:
				
				set_panel_comandos(false)
				print("ENEMY TURN")
				prepare_enemy_actions()
				perform_enemy_actions()
				
			)


		BattleState.VICTORY:
			handle_state(BattleState.VICTORY, func() -> void:
				set_panel_comandos(false)
				print("GANASTE")
			)

		BattleState.DEFEAT:
			handle_state(BattleState.DEFEAT, func() -> void:
				set_panel_comandos(false)
				print("PERDISTE")
			)

#-----------FSM MANEJADOR DE ESTADOS DE SCRIPT--------------
func handle_state(next_state: BattleState, fallback_func: Callable) -> void:
	current_state = next_state
	
	if battle_event_controller and battle_event_controller.has_method("trigger_event"):
		var handled = await battle_event_controller.trigger_event(self)
		if handled:
			return # Evento interrumpe la lógica normal
	
	# Si no hay evento, sigue con el flujo normal
	fallback_func.call()

# TESTEO MANUAL SOLO POR AHORA
func _input(_event):
	
	if Input.is_action_just_pressed("x"):
		if current_state == BattleState.TARGET_SELECTING:
			var actor = WorldFunc.Party_BTL[current_ally_index]
			var action = player_actions.get(actor)
			# Si era ítem, devolver cantidad
			if action and action.type == "item":
				PartyData.inventario[action.item]["cantidad"] += 1
			highlight_current_ally(false)
			highlight_target_list(enemy_list,false)
			# Caso 1: Si estás en targeting, vuelves a seleccionar acción para el mismo aliado
			_change_state(BattleState.PLAYER_SELECTING)
			return
		elif current_state == BattleState.PLAYER_SELECTING:
			# Caso 2: Si estás en selección de acción y no es el primer aliado,
			# retrocedes a targeting del aliado anterior

			if $UI/ItemPanel.visible:
				$UI/ItemPanel.visible=false
				$UI/ItemDesPanel.visible=false
				$UI/CommandPanel/CommandContainer/Objetos.grab_focus()
			if current_ally_index > 0:
				highlight_current_ally(false)
				current_ally_index -= 1
				_change_state(BattleState.TARGET_SELECTING)
				return
	
	# --- Selección de objetivo ---
	if current_state == BattleState.TARGET_SELECTING:
		
		var enemy_count = enemy_list.size()
		
		if Input.is_action_just_pressed("ui_right"):
			target_index = (target_index + 1) % target_list.size()
			return
		elif Input.is_action_just_pressed("ui_left"):
			target_index = (target_index - 1 + target_list.size()) % target_list.size()
			return
		elif Input.is_action_just_pressed("ui_accept"):
			on_target_selected(target_list[target_index])
			return
		elif Input.is_action_just_pressed("ui_cancel"):
			cancel_targeting()
			return
		highlight_target_list(target_list, true, target_index)
		return

#------------CHECKEO DE EVENTOS-----------
func _check_battle_events() -> bool:
	if battle_event_controller == null:
		return false
	
	if battle_event_controller.has_method("trigger_event"):
		var handled = await battle_event_controller.trigger_event(self)
		return handled
	
	return false

#-------------LLAMADA DE DIALOGOS----------
func _handle_dialogue() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_parent(), "modulate", Color(0, 0, 0,0.3), 1)

#---------SEÑALES DIALOGOS---------------
func _on_dialogue_started(_d):
	og_state=current_state
	_change_state(BattleState.DIALOGUE)
	$UI/CommandPanel.visible=false
	_fade_in_overlay()
	
func _on_dialogue_ended(_d):
	$UI/CommandPanel.visible=true
	_fade_out_overlay()
	_change_state(og_state)

#-------------FADES DIALOGO------------
func _fade_in_overlay():
	var overlay = $DarkOverlay
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(overlay, "color:a", 0.6, 0.3)  # Alpha a 0.6 (ajustable)

func _fade_out_overlay():
	var overlay = $DarkOverlay
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(overlay, "color:a", 0.0, 0.3)  # Vuelve a transparente

#-------------SEÑALES PARTY----------
func _on_ally_hp_changed(new_hp,party_member,negativo):
	if negativo: 
		heleo_visual(party_member)
	else:
		daño_visual(party_member)
	var hp = party_member.get_node("Vida")
	var tween = hp.create_tween()
	temblor(party_member)
	tween.tween_property(hp, "value", new_hp, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_ally_died(party_member):
	var retrato = party_member.get_node("Ally")
	temblor(party_member)
	retrato.modulate = Color(0.2,0.2,0.2)
	party_member.rip=true
	check_combat_end()

#-------------SEÑALES ENEMIGOS----------
func _on_enemy_hp_changed(_new_hp,enemy,negativo):
	if negativo: 
		heleo_visual(enemy)
	else:
		daño_visual(enemy)
	temblor(enemy)

func _on_enemy_died(enemy: Control):
	daño_visual(enemy)
	temblor(enemy)
	await get_tree().create_timer(0.5).timeout
	# Desvanecer 
	var fade_tween := enemy.create_tween()
	fade_tween.tween_property(enemy, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await fade_tween.finished
	#matar
	enemy.queue_free()
	await get_tree().create_timer(0.1).timeout
	# Chequea si quedan enemigos
	check_combat_end()

#---------TEMBLOR--------
func temblor(node: Control):
	var original_position := node.position

	var tween := node.create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var shake_strength := 4.0
	var shake_duration := 0.1

	# Secuencia de sacudidas: izquierda, derecha, centro, etc.
	tween.tween_property(node, "position", original_position + Vector2(-shake_strength, 0), shake_duration)
	tween.tween_property(node, "position", original_position + Vector2(shake_strength, 0), shake_duration)
	tween.tween_property(node, "position", original_position + Vector2(0, -shake_strength), shake_duration)
	tween.tween_property(node, "position", original_position + Vector2(0, shake_strength), shake_duration)
	tween.tween_property(node, "position", original_position, shake_duration)

#---------DAÑO VISUAL--------
func daño_visual(node:Control):
	var original_color = node.modulate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# Flash rojo rápido
	tween.tween_property(node, "modulate", Color(1, 0, 0), 0.05)
	tween.tween_property(node, "modulate", original_color, 0.15)

func heleo_visual(node:Control):
	var original_color = node.modulate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# Flash rojo rápido
	tween.tween_property(node, "modulate", Color(0, 1, 0), 0.05)
	tween.tween_property(node, "modulate", original_color, 0.15)
#---------HIGHLIGHT DE SELECCION ALIADO---------

func highlight_current_ally(active: bool) -> void:
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	
	for ally in $Party/AllyContainers.get_children():
		if ally.character_id == current_ally:
			ally.get_node("Ally").modulate = Color(1,1,0.5) if active else Color(1,1,1)


#-------------HIGHLIGHT TARGETEO ENEMIGO-------------
func highlight_enemies(active: bool, selected_idx: int = -1) -> void:
	for i in range(enemy_list.size()):
		var enemy = enemy_list[i]

		if enemy == null or not is_instance_valid(enemy):
			continue  # Salta si el nodo está liberado

		if active and i == selected_idx:
			enemy.modulate = Color(1, 0.7, 0.7)  # Enemigo seleccionado
		else:
			enemy.modulate = Color(1,1,1)        # Otros normales

#----SETEO DE ACCIONES Y TARGET---------------------
func on_enemy_target_selected(enemy_node: Control) -> void:
	if current_state != BattleState.TARGET_SELECTING:
		return

	# Refrescar la lista de enemigos vivos
	var alive = get_alive_enemies()

	# Si el nodo pasó a rip o no está en la lista, elegimos el primero vivo o null
	if enemy_node == null or enemy_node.rip or not alive.has(enemy_node):
		if alive.size() > 0:
			enemy_node = alive[0]
		else:
			enemy_node = null

	# Si no quedan enemigos vivos, avanzamos
	if enemy_node == null:
		_change_state(BattleState.PLAYER_ACTING)
		return

	# Guardar la acción para el aliado actual
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	player_actions[current_ally]["target"] = enemy_node.name

	# Limpiar resaltados
	highlight_enemies(false)
	highlight_current_ally(false)

	# Avanzar al siguiente aliado o al turno de acción
	current_ally_index += 1
	if current_ally_index >= WorldFunc.Party_BTL.size():
		current_ally_index = 0
		_change_state(BattleState.PLAYER_ACTING)
	else:
		_change_state(BattleState.PLAYER_SELECTING)


#-------- ACTIVA DESACTIVA PANEL COMANDOS--------
func set_panel_comandos(enabled: bool) -> void:
	var container = $UI/CommandPanel/CommandContainer
	for child in container.get_children():
		if child is Button:
			child.disabled = not enabled

	if not enabled:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()
	else:
		# Al habilitar, asignar foco al primer botón habilitado
		for child in container.get_children():
			if child is Button and not child.disabled:
				child.grab_focus()
				break


#------OVERRIDES ESPECIALES DE COMANDO----------
func set_command_override(command_name: String, disabled: bool):
	command_overrides[command_name] = disabled
	_apply_command_overrides()

func clear_command_overrides():
	command_overrides.clear()
	_apply_command_overrides()

func _apply_command_overrides():
	var container = $UI/CommandPanel/CommandContainer
	for button in container.get_children():
		if button is Button:
			if button.name in command_overrides:
				button.disabled = command_overrides[button.name]

#------------ ACTOS DE PARTY------------------

func perform_player_actions():
	current_action_index = 0
	perform_next_action()
	
func perform_next_action() -> void:
	# —————— 1) Saltar aliados muertos ——————
	while current_action_index < WorldFunc.Party_BTL.size():
		var actor_id = WorldFunc.Party_BTL[current_action_index]
		# Buscamos la instancia en Party/AllyContainers
		var actor_node: Control = null
		for a in $Party/AllyContainers.get_children():
			if a.character_id == actor_id:
				actor_node = a
				break
		# Si no existe o está RIP, avanzamos el índice
		if actor_node == null or actor_node.rip:
			current_action_index += 1
			continue
		# Si encontramos uno vivo, salimos del while
		break


	# 0) Si ya recorrimos todos los aliados, pasamos al turno enemigo
	if current_action_index >= WorldFunc.Party_BTL.size():
		check_combat_end()
		_change_state(BattleState.ENEMY_TURN)
		return

	# 1) Sacar actor y acción
	var actor_name = WorldFunc.Party_BTL[current_action_index]
	var action = player_actions.get(actor_name)

	# 2) Si no hay acción, avanzamos
	if action == null:
		current_action_index += 1
		perform_next_action()
		return

	# 3) Ejecutar según tipo
	match action.type:
		"ataque":
			do_attack_action(actor_name, action)
		"habilidad":
			do_skill_action(actor_name, action)
		"item":
			do_item_action(actor_name, action)
		_:
			current_action_index += 1
			perform_next_action()

func do_attack_action(actor_name: String, action: Dictionary) -> void:
	current_ally_index = current_action_index
	highlight_current_ally(true)

	# Simula animación breve
	await get_tree().create_timer(0.5).timeout

	# Elegir front/back manualmente
	var node_front = get_node_or_null("Enemies/EnemyContainersFront/" + action.target)
	var node_back  = get_node_or_null("Enemies/EnemyContainersBack/"  + action.target)
	var node = node_front
	if node == null:
		node = node_back


	# Si no existe o ya murió → mensaje de fallo en panel
	if node == null or node.rip:
		await mostrar_texto_combate("¡Ataque falló!", 1.0)
		advance_action()
		return

	# Si impacta
	await mostrar_texto_combate("%s atacó a %s." % [actor_name, node.character_id], 1.0)
	resolve_attack_action(actor_name, action)

func do_skill_action(actor_name: String, action: Dictionary):
	pass
	
func do_item_action(actor_name: String, action: Dictionary) -> void:
	current_ally_index = current_action_index
	highlight_current_ally(true)

	var item = PartyData.inventario[action.item]
	var nodo = get_node_or_null("Party/AllyContainers/" + action.target)

	# Aunque no debería fallar, lo chequeamos
	if nodo == null or nodo.rip:
		await mostrar_texto_combate("Objetivo inválido", 1.0)
		advance_action()
		return

	# Mensaje de uso
	await mostrar_texto_combate("%s usó %s en %s." %
		[actor_name, item["nombre"], nodo.character_id], 1.0)

	# Aplica curación/daño
	nodo.recibir_dano(item["daño"])
	display_damage(nodo, item["daño"], nodo.global_position, false, false, "normal")
	# Consumir ítem
	PartyData.inventario[action.item]["cantidad"] -= 1

	advance_action()

#------------ RESOLUCION DE PARTY------------------

# Helpers para cálculos y visualizaciones

func calculate_raw_attack(base_attack: int, weapon_attack: int, level: int) -> int:
	var nivel_bonus = int((level - 1) * 10)
	var nivel_mult = (100 + nivel_bonus) / 100.0
	return int((base_attack + weapon_attack) * nivel_mult)

func check_critical(crit_char: int, crit_weapon: int) -> bool:
	return randi_range(1, 100) <= (crit_char + crit_weapon)

func check_evasion(evasion: int) -> bool:
	return randi_range(1, 100) <= evasion

func get_type_relation(enemy_data: Dictionary, attack_type: String) -> Dictionary:
	var tipo_data = {
		"inmunidades": enemy_data["inmunidades"],
		"debilidades": enemy_data["debilidades"],
		"resistencias": enemy_data["resistencias"],
		"absorciones": enemy_data["absorciones"]
	}
	var mod = TypeTable.get_damage_modifier(tipo_data, attack_type)
	var relation = "normal"
	match mod:
		TypeTable.INMUNE_MULT:
			relation = "inmune"
		TypeTable.ABSORBE_MULT:
			relation = "absorbe"
		TypeTable.DEBIL_MULT:
			relation = "debil"
		TypeTable.RESIST_MULT:
			relation = "resistente"
	return {"mult": mod, "relation": relation}

func display_damage(target: Control, damage: int, local_pos: Vector2, is_miss: bool, is_crit: bool, relation: String) -> void:
	var dmg_scene = preload("res://Scenes/BTL/UI/Dmg.tscn")
	var dmg_instance = dmg_scene.instantiate()
	$Enemies.add_child(dmg_instance)
	dmg_instance.show_damage(damage, local_pos + Vector2(200, 0), is_miss, is_crit, relation)

func _next_player_action() -> void:
	current_action_index += 1
	perform_next_action()


# Refactor de resolve_attack_action()

func resolve_attack_action(actor_name: String, action: Dictionary) -> void:
	# Datos del actor
	var level = PartyData.party_level
	var base_atk = PartyData.characters[actor_name]["stats"]["ataque_fisico"]
	var weapon = PartyData.characters[actor_name]["equipo"]["arma"]
	var weapon_atk = 0
	if weapon != "":
		weapon_atk = PartyData.equipables[weapon]["stats"]["ataque_fisico"]
	var crit_char = PartyData.characters[actor_name]["stats"]["critico"]
	var crit_weapon = 0
	if weapon != "":
		crit_weapon = PartyData.equipables[weapon]["stats"]["critico"]

	# 1. Cálculo bruto
	var raw = calculate_raw_attack(base_atk, weapon_atk, level)

	# Selección de nodo enemigo
	var target_name = action.target
	var enemy_node = get_node_or_null("Enemies/EnemyContainersFront/" + target_name)
	if enemy_node == null:
		enemy_node = get_node_or_null("Enemies/EnemyContainersBack/" + target_name)
	if enemy_node == null:
		_next_player_action()
		return

	# Datos del enemigo
	var enemy_id = target_name.substr(0, target_name.length() - 1)
	var enemy_data = EnemyData.enemies[enemy_id]
	var defense = enemy_data["stats"]["defensa_fisica"]
	var evasion = enemy_data["stats"]["evasion"]

	# 2. Evasión
	if check_evasion(evasion):
		var pos = enemy_node.get_screen_position() - $Enemies.get_screen_position()
		display_damage(enemy_node, 0, pos, true, false, "normal")
		_next_player_action()
		return

	# 3. Tipo y relación
	var attack_type = ""
	if weapon != "":
		attack_type = PartyData.equipables[weapon]["tipo"]
	else:
		attack_type = PartyData.characters[actor_name]["ataque"]["basico"]["tipo"]
	var type_info = get_type_relation(enemy_data, attack_type)

	# 4. Crítico
	var is_crit = check_critical(crit_char, crit_weapon)
	var crit_mult = 1.0
	if is_crit:
		crit_mult = 1.3

	# 5. Cálculo de daño final
	var dmg = raw - defense
	if dmg < 0:
		dmg = 0
	dmg = int(dmg * type_info["mult"] * crit_mult)

	# 6. Aplicar daño y mostrar
	enemy_node.recibir_dano(dmg)
	var local_pos = enemy_node.get_screen_position() - $Enemies.get_screen_position()
	display_damage(enemy_node, dmg, local_pos, false, is_crit, type_info["relation"])
	highlight_current_ally(false)
	
	# Avanza al siguiente
	_next_player_action()

#------FUNCS TURNO ENEMIGO--------------
func prepare_enemy_actions() -> void:
	enemy_actions.clear()
	current_enemy_index = 0

	# 2.1 Recolecta instancias vivas y ordena por velocidad descendente
	var enemies = get_tree().get_nodes_in_group("instancia_enemigo")
	enemies.sort_custom(_compare_enemy_speed)

	for enemy in enemies:
		if enemy.rip:
			continue
		var action = select_enemy_action(enemy)
		if action.is_empty():
			continue
		enemy_actions.append({
			"actor":   enemy,
			"ability": action.ability,
			"target":  action.target
		})

func _compare_enemy_speed(a, b) -> int:
	var sa = EnemyData.enemies[a.character_id]["stats"]["velocidad"]
	var sb = EnemyData.enemies[b.character_id]["stats"]["velocidad"]
	return sb - sa  # b antes que a si es más rápido

func select_enemy_action(enemy: Node) -> Dictionary:
	# Datos del enemigo
	var data = EnemyData.enemies[enemy.character_id]
	var abil = data["habilidades"]

	# 1) Separar habilidades forzadas vs. siempre disponibles
	var forced := []
	var always := []
	for namex in abil.keys():
		var info = abil[namex]
		if info["scripted"] == turn:
			forced.append(namex)
		elif info["scripted"] < 0:
			always.append(namex)

	# 2) Definir el pool final: primero forzadas, si no hay, usar always
	var available := []
	if not forced.is_empty():
		available = forced
	else:
		available = always

	if available.is_empty():
		return {}

	# 3) Elegir según ai_type
	var chosen := ""
	var ai = data["ai_type"]
	match ai:
		"agresivo":
			# la de mayor poder
			chosen = available[0]
			for n in available:
				if abil[n]["poder"] > abil[chosen]["poder"]:
					chosen = n
		"random":
			chosen = available[randi_range(0, available.size() - 1)]
		"aux":
			# prioridad curación self si está dañado
			var used_heal := false
			for n in available:
				var i = abil[n]
				if i["target"] == "self" and i["poder"] < 0:
					var hp    = enemy.get_node("Vida").value
					var maxhp = data["stats"]["max_hp"]
					if hp < maxhp:
						chosen = n
						used_heal = true
						break
			if not used_heal:
				chosen = available[randi_range(0, available.size() - 1)]
		_:
			chosen = available[0]

	# 4) Resolver target igual que antes
	var target_node: Node = enemy
	var tinfo = abil[chosen]
	if tinfo["target"] == "party":
		var vivos := []
		for ally in $Party/AllyContainers.get_children():
			if not ally.rip:
				vivos.append(ally)
		if vivos.size() > 0:
			if ai == "agresivo":
				target_node = vivos[0]
				for a in vivos:
					if a.get_node("Vida").value < target_node.get_node("Vida").value:
						target_node = a
			else:
				target_node = vivos[randi_range(0, vivos.size() - 1)]

	return {
		"ability": chosen,
		"target":  target_node.name
	}
func perform_enemy_actions() -> void:
	if enemy_actions.is_empty():
		_change_state(BattleState.IDLE)
		return
	current_enemy_index = 0
	perform_next_enemy_action()

# Helper para buscar un aliado vivo por nombre
func find_alive_ally_by_name(names: String) -> Node:
	for a in $Party/AllyContainers.get_children():
		if is_instance_valid(a) and not a.rip and a.name == names:
			return a
	return null


func perform_next_enemy_action() -> void:
	if current_enemy_index >= enemy_actions.size():
		_change_state(BattleState.IDLE)
		return

	var entry        = enemy_actions[current_enemy_index]
	var enemy        = entry["actor"]
	var ability_name = entry["ability"]
	var target_name  = entry["target"]

	# Validar que el enemigo siga existiendo
	if not is_instance_valid(enemy) or enemy.rip:
		current_enemy_index += 1
		perform_next_enemy_action()
		return

	var edata = EnemyData.enemies.get(enemy.character_id)
	if edata == null:
		current_enemy_index += 1
		perform_next_enemy_action()
		return

	var tinfo = edata["habilidades"].get(ability_name)
	if tinfo == null:
		current_enemy_index += 1
		perform_next_enemy_action()
		return

	# Obtener target válido
	var target: Node = null
	if tinfo["target"] == "self":
		target = enemy
	else:
		target = find_alive_ally_by_name(target_name)
	if target == null:
		var pos_miss = enemy.get_node("Enemy").get_global_position()
		display_damage(enemy, 0, pos_miss, true, false, "normal")
		current_enemy_index += 1
		perform_next_enemy_action()
		return

	# Animación + espera
	highlight_enemies(true, current_enemy_index)
	await get_tree().create_timer(0.5).timeout
	highlight_enemies(false, current_enemy_index)
	await get_tree().create_timer(0.5).timeout

	# VALIDACIÓN FINAL antes de resolver
	if not is_instance_valid(enemy):
		current_enemy_index += 1
		perform_next_enemy_action()
		return
	await mostrar_texto_combate(enemy.character_id + " usó " + ability_name + " en " + target.character_id + ".", 1.0)
	resolve_enemy_ability_action(enemy, ability_name, target.name)
	current_enemy_index += 1
	perform_next_enemy_action()

func resolve_enemy_ability_action(enemy: Node, ability_name: String, target_name: String) -> void:
	# Datos del enemigo y la habilidad
	var edata = EnemyData.enemies[enemy.character_id]
	var abil  = edata["habilidades"][ability_name]
	var raw_power = abil["poder"]            # >0 daño, <0 curación
	var atk_fisico = edata["stats"]["ataque_fisico"]
	var atk_magico = edata["stats"]["ataque_magico"]   
	var estilo     = abil["estilo"]             # "fisico" o "magico"
	var tipo = abil["tipo"]    
	var is_heal   = raw_power < 0
	# Determinar nodo objetivo
	var target: Node = null
	if abil["target"] == "self":
		target = enemy
	else:
		target = $Party/AllyContainers.get_node(target_name)
	if target == null:
		return

	# Obtener posición para el feedback (sprite “Ally” o “Enemy”)
	var sprite: Node
	if abil["target"] == "self":
		sprite = target.get_node("Enemy")
	else:
		sprite = target.get_node("Ally")
	var pos = sprite.get_global_position()

	# Si ataca a la party, chequeamos defensa y evasión
	var defense = 0
	var evasion = 0
	if abil["target"] != "self":
		var pdata = PartyData.characters[target.character_id]
		if estilo == "fisico":
			defense = pdata["stats"]["defensa_fisica"]
			raw_power += atk_fisico
		else:
			defense = pdata["stats"]["defensa_magica"]
			raw_power += atk_magico
		evasion = pdata["stats"]["evasion"]
		
		# 1) Evasión
		if check_evasion(evasion):
			display_damage(target, 0, pos, true, false, "normal")
			return

	# 2) Modificador de tipo
	var tipo_data = {
		"inmunidades":  edata["inmunidades"],
		"debilidades":  edata["debilidades"],
		"resistencias": edata["resistencias"],
		"absorciones":  edata["absorciones"]
	}
	var mult      = TypeTable.get_damage_modifier(tipo_data, tipo)
	var relation  = "normal"
	if mult == TypeTable.INMUNE_MULT:
		relation = "inmune"
	elif mult == TypeTable.ABSORBE_MULT:
		relation = "absorbe"
	elif mult == TypeTable.DEBIL_MULT:
		relation = "debil"
	elif mult == TypeTable.RESIST_MULT:
		relation = "resistente"

	# 3) Crítico (daño y curación pueden crítico)
	var is_crit = false
	var crit_chance = edata["stats"]["critico"]
	if randi_range(1, 100) <= crit_chance:
		is_crit = true

	var crit_mult = 1.0
	if is_crit:
		crit_mult = 1.3

	# 4) Cálculo final
	var effective = raw_power
	if abil["target"] != "self" and not is_heal:
		effective = raw_power - defense
		if effective < 0:
			effective = 0

	var final_amount = int(effective * mult * crit_mult)

	# 5) Aplica daño o curación con una sola llamada
	target.recibir_dano(final_amount)

	# 6) Feedback visual
	display_damage(target, final_amount, pos, false, is_crit, relation)

#.--------------------HELPER TARGETEOS--------------------------
# Devuelve nodos vivos según el string de targets
func build_target_list(target_type: String) -> Array:
	match target_type:
		"self":
			return [ get_alive_allies()[current_ally_index] ]
		"ally", "all_ally":
			return get_alive_allies()
		"enemy", "all_enemy":
			return get_alive_enemies()
		"all":
			return get_alive_allies() + get_alive_enemies()
		_:
			return []

# Limpia y resalta nodo(s) de una lista
func highlight_target_list(list: Array, active: bool, idx: int = -1) -> void:
	# 1) Limpiar tintes
	for a in get_alive_allies():
		a.modulate = Color(1,1,1)
	for e in get_alive_enemies():
		e.modulate = Color(1,1,1)
	# 2) Resaltar sólo el seleccionado
	if active and idx >= 0 and idx < list.size():
		list[idx].modulate = Color(1, 0.7, 0.7)

# Confirmar el target elegido
func on_target_selected(node: Control) -> void:
	var actor = WorldFunc.Party_BTL[current_ally_index]
	player_actions[actor]["target"] = node.name

	# Limpiar resaltados
	highlight_target_list(target_list, false)
	highlight_current_ally(false)

	# Avanzar al siguiente aliado o al paso de ejecución
	current_ally_index += 1
	if current_ally_index >= WorldFunc.Party_BTL.size():
		current_ally_index = 0
		_change_state(BattleState.PLAYER_ACTING)
	else:
		_change_state(BattleState.PLAYER_SELECTING)

# Cancelar selección de targeteo
func cancel_targeting() -> void:
	var actor = WorldFunc.Party_BTL[current_ally_index]
	var action = player_actions.get(actor)
	# Si era ítem, devolver cantidad
	if action and action.type == "item":
		PartyData.inventario[action.item]["cantidad"] += 1

	player_actions[actor] = null
	abrir_item_menu()
	_change_state(BattleState.PLAYER_SELECTING)
	
	
#-------------------HELPER PARA MOSTRAR Q PASA------------------------
func mostrar_texto_combate(texto: String, duracion := 1.0) -> void:
	$UI/CommandPanel.visible=false
	_msg_label.text = texto
	_msg_panel.visible = true
	await get_tree().create_timer(duracion).timeout
	_msg_panel.visible = false
	$UI/CommandPanel.visible=true


#-------HELEPRS PARA QUE NO SE CHINGUE CUANDO SE MUERE ALGN----------

# Devuelve enemigos en escena que aún no murieron
func get_alive_enemies() -> Array:
	var alive := []
	for e in get_tree().get_nodes_in_group("instancia_enemigo"):
		if not e.rip and is_instance_valid(e):
			alive.append(e)
	return alive

# Devuelve aliados vivos
func get_alive_allies() -> Array:
	var alive := []
	for a in $Party/AllyContainers.get_children():
		if not a.rip and is_instance_valid(a):
			alive.append(a)
	return alive

func check_combat_end() -> void:
	var enemies_alive := get_alive_enemies().size()
	var party_alive := get_alive_allies().size()
	if enemies_alive == 0:
		if current_state != BattleState.VICTORY:
			_change_state(BattleState.VICTORY)
		return

	if party_alive == 0:
		if current_state != BattleState.DEFEAT:
			_change_state(BattleState.DEFEAT)
		return

#---------------HELPER LIMPIA HIJOS-----------------
func queue_free_children(nodo):
	for child in nodo.get_children():
		child.queue_free()
		
#-----HELPER COPILOT YA NI IDEA Q ESTOYU HACIENDO---------
func advance_action() -> void:
	highlight_current_ally(false)
	current_action_index += 1
	perform_next_action()


#--------------------------------BOTON ATACAR-------------------------
func _on_atacar_pressed() -> void:
	
	if current_state != BattleState.PLAYER_SELECTING:
		return
	
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	player_actions[current_ally] = {
		"type": "ataque",
		"subtype": "basico",
		"targets": "enemy",
		"target": null  # Esperando selección de objetivo
	}
	
	_change_state(BattleState.TARGET_SELECTING)

#------------------------BOTON OBJETOS----------
func abrir_item_menu():
	var lista_panel := $UI/ItemPanel/ItemListContainer/ItemScroll/ItemButtons
	queue_free_children(lista_panel)
	
	$UI/ItemPanel/ItemListContainer/CancelButton.focus_entered.connect(func():
		$UI/ItemDesPanel.visible=false)
	# Asegurar visibilidad antes de asignar foco
	$UI/ItemPanel.visible = true
	await get_tree().process_frame

	for nombre in PartyData.inventario.keys():
		var item_data = PartyData.inventario[nombre]
		if item_data["cantidad"] > 0 and item_data["usable"]:
			var boton = Button.new()
			boton.flat=true
			boton.focus_entered.connect(func():
				actualizar_descripcion(PartyData.inventario[nombre]["descripcion"]))
			boton.add_theme_constant_override("outline_size",35)
			boton.add_theme_stylebox_override("focus",load("res://Scenes/BTL/Styles/BTL_Button.tres"))
			boton.focus_mode=Control.FOCUS_ALL
			boton.text = str(item_data["nombre"]) + " x" + str(item_data["cantidad"])
			boton.name = nombre
			boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			boton.pressed.connect(func(): _on_item_selected(nombre))
			lista_panel.add_child(boton)
	
	# Asignar foco al primero disponible
# Asignar foco al primero disponible y guardar el último botón
	var ultimo_boton = null
	for child in lista_panel.get_children():
		if child is Button and not child.disabled:
			if ultimo_boton == null:
				child.grab_focus()  # el primero
			ultimo_boton = child  # se va actualizando hasta el último
	var boton_cancelar := $UI/ItemPanel/ItemListContainer/CancelButton
	if ultimo_boton:
		boton_cancelar.focus_mode = Control.FOCUS_ALL
		boton_cancelar.focus_neighbor_top = ultimo_boton.get_path()
	else:
		boton_cancelar.grab_focus()


func actualizar_descripcion(texto: String) -> void:
	$UI/ItemDesPanel.visible = true
	$UI/ItemDesPanel/MarginContainer/ItemDesLabel.text = texto

func _on_item_selected(item_name: String) -> void:
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	
	PartyData.inventario[item_name]["cantidad"]-=1
	
	player_actions[current_ally] = {
		"type":    "item",
		"subtype": "usar",
		"item":    item_name,
		"targets": PartyData.inventario[item_name]["targets"],  # ej. "ally", "all_enemy", "all", etc.
		"target":  null
	}
	
	$UI/ItemPanel.visible = false
	$UI/ItemDesPanel.visible = false
	_change_state(BattleState.TARGET_SELECTING)
	
func _on_objetos_pressed() -> void:
	$UI/CommandPanel.focus_mode= 0
	abrir_item_menu()
	pass # Replace with function body.


func _on_cancel_button_pressed() -> void:
	$UI/CommandPanel.visible = true
	$UI/ItemPanel.visible = false
	$UI/ItemDesPanel.visible = false
	$UI/CommandPanel.focus_mode= 2
	var container = $UI/CommandPanel/CommandContainer
	for button in container.get_children():
		if button is Button and not button.disabled:
			button.grab_focus()
			break


	pass # Replace with function body.
