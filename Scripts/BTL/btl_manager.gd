extends Node

#------------------INSTANCIAS-------------
@export var Enemy : PackedScene
@export var Ally : PackedScene

#-----------SCRIPT DE PELEAS OPCIONAL---------
var battle_event_controller: Node = null

#--------------ESTADOS FSM----------
enum BattleState {
	IDLE,
	DIALOGUE,
	PLAYER_SELECTING,
	TARGET_SELECTING,
	PLAYER_ACTING,
	PLAYER_RESOLVING,
	ENEMY_TURN,
	ENEMY_RESOLVING,
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

var current_action_index = 0

#-------override para comandos------

var command_overrides := {}




func _ready() -> void:
	#----------- SEÑALES DIALOGOS--------
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
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
		new_ally.name=chars+str(i)
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
	match new_state:
		BattleState.IDLE:
			handle_state(BattleState.IDLE, func() -> void:
				turn += 1
				print("TURNO: " + str(turn))
				print("IDLE")
				current_ally_index = 0
				_change_state(BattleState.PLAYER_SELECTING)
			)

		BattleState.DIALOGUE:
			handle_state(BattleState.DIALOGUE, func() -> void:
				print("DIALOGUE")
			)

		BattleState.PLAYER_SELECTING:
			handle_state(BattleState.PLAYER_SELECTING, func() -> void:
				await get_tree().process_frame
				set_panel_comandos(true)
				_apply_command_overrides()
				print("PLAYER SELECT")
			)
		BattleState.TARGET_SELECTING:
			handle_state(BattleState.TARGET_SELECTING, func() -> void:
				print("TARGET_SELECTING")
				set_panel_comandos(false)
				enemy_list = get_tree().get_nodes_in_group("instancia_enemigo")
				target_index = 0
				highlight_enemies(false) # Limpia
				highlight_enemies(true, target_index) # Resalta actual
				highlight_current_ally(true)
			)

		BattleState.PLAYER_ACTING:
			handle_state(BattleState.PLAYER_ACTING, func() -> void:
				print(player_actions)
				perform_player_actions()
				print("PLAYER ACTS")
			)

		BattleState.PLAYER_RESOLVING:
			handle_state(BattleState.PLAYER_RESOLVING, func() -> void:
				print("PLAYER_RESOLVING")
			)
			
		BattleState.ENEMY_TURN:
			handle_state(BattleState.ENEMY_TURN, func() -> void:
				set_panel_comandos(false)
				print("ENEMY TURN")

			)

		BattleState.ENEMY_RESOLVING:
			handle_state(BattleState.ENEMY_RESOLVING, func() -> void:
				print("ENEMY_RESOLVING")
			)

		BattleState.VICTORY:
			handle_state(BattleState.VICTORY, func() -> void:
				print("GANASTE")
			)

		BattleState.DEFEAT:
			handle_state(BattleState.DEFEAT, func() -> void:
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

# TEST MANUAL SOLO POR AHORA
func _input(_event):
	
	if Input.is_action_just_pressed("ui_text_backspace"):
		if current_state == BattleState.TARGET_SELECTING:
			# Caso 1: Si estás en targeting, vuelves a seleccionar acción para el mismo aliado
			_change_state(BattleState.PLAYER_SELECTING)
			return
		elif current_state == BattleState.PLAYER_SELECTING:
			# Caso 2: Si estás en selección de acción y no es el primer aliado,
			# retrocedes a targeting del aliado anterior
			if current_ally_index > 0:
				highlight_current_ally(false)
				current_ally_index -= 1
				_change_state(BattleState.TARGET_SELECTING)
				return
	
	# --- Selección de objetivo ---
	if current_state == BattleState.TARGET_SELECTING:
		
		var enemy_count = enemy_list.size()
		
		if Input.is_action_just_pressed("ui_right"):
			target_index = (target_index + 1) % enemy_list.size()
			highlight_enemies(true, target_index)
			return
		elif Input.is_action_just_pressed("ui_left"):
			target_index = (target_index - 1 + enemy_list.size()) % enemy_list.size()
			highlight_enemies(true, target_index)
			return
		elif Input.is_action_just_pressed("ui_up"):
			if enemy_count == 4:
				if target_index >= 1:
					target_index = 0
					highlight_enemies(true, target_index)
			elif enemy_count == 5:
				if target_index >= 2:
					target_index -= 3
					if target_index < 0 :
						target_index =0
					highlight_enemies(true, target_index)
				return
			
		elif Input.is_action_just_pressed("ui_down"):
			if enemy_count == 4:
				if target_index == 0:
					target_index = 3
					highlight_enemies(true, target_index)
			elif enemy_count == 5:
				if target_index <= 1:
					target_index += 3
					highlight_enemies(true, target_index)
				return
			
		elif Input.is_action_just_pressed("ui_accept"):
			on_enemy_target_selected(enemy_list[target_index])
			return
			
	# --- Placeholder de pruebas para avanzar estados ---
	if Input.is_action_just_pressed("ui_accept"):
		match current_state:
			BattleState.PLAYER_ACTING:
				_change_state(BattleState.PLAYER_RESOLVING)
			BattleState.PLAYER_RESOLVING:
				_change_state(BattleState.ENEMY_TURN)
			BattleState.ENEMY_TURN:
				_change_state(BattleState.ENEMY_RESOLVING)
			BattleState.ENEMY_RESOLVING:
				_change_state(BattleState.IDLE)

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
func _on_ally_hp_changed(new_hp,party_member):
	var hp = party_member.get_node("Vida")
	var tween = hp.create_tween()
	daño_visual(party_member)
	temblor(party_member)
	tween.tween_property(hp, "value", new_hp, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_ally_died(party_member):
	var retrato = party_member.get_node("Ally")

	temblor(party_member)
	retrato.modulate = Color(0.2,0.2,0.2)
	party_member.rip=true
	for allies in $Party/AllyContainers.get_children():
		if not allies.rip:
			return
			
	_change_state(BattleState.DEFEAT)  ###aqui trans a gameover

#-------------SEÑALES ENEMIGOS----------
func _on_enemy_hp_changed(_new_hp,enemy,negativo):
	if negativo: 
		daño_visual(enemy)
	else:
		heleo_visual(enemy)
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
	var quedan_enemigos := get_tree().get_nodes_in_group("enemy_instance").size() > 0
	if not quedan_enemigos:
		if current_state!=BattleState.VICTORY:
			_change_state(BattleState.VICTORY) ####aqui trans a ganar o ekis

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
		if active and i == selected_idx:
			enemy.modulate = Color(1, 0.7, 0.7)  # Enemigo seleccionado
		else:
			enemy.modulate = Color(1,1,1)        # Otros normales

#----SETEO DE ACCIONES Y TARGET---------------------
func on_enemy_target_selected(enemy_node: Control) -> void:
	if current_state != BattleState.TARGET_SELECTING:
		return
	
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	player_actions[current_ally]["target"] = enemy_node.name
	
	print(current_ally + " atacará a " + enemy_node.name)
	
	highlight_enemies(false)
	highlight_current_ally(false)
	
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
	
func perform_next_action():
	# Ver si quedan acciones por hacer
	if current_action_index >= WorldFunc.Party_BTL.size():
		_change_state(BattleState.ENEMY_TURN)
		return

	var actor_name = WorldFunc.Party_BTL[current_action_index]
	var action = player_actions.get(actor_name)
	
	if action == null:
		current_action_index += 1
		perform_next_action()
		return
	
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

func do_attack_action(actor_name: String, action: Dictionary):
	print(actor_name + " ataca a " + action.target)
	current_ally_index=current_action_index
	highlight_current_ally(true)
	# Aquí puedes poner una animación, sonido, etc.
	await get_tree().create_timer(1).timeout # Simula animación
	highlight_current_ally(false)
	# Pasa a resolver el daño
	resolve_attack_action(actor_name, action)

func do_skill_action(actor_name: String, action: Dictionary):
	pass
	
func do_item_action(actor_name: String, action: Dictionary):
	pass
#------------ RESOLUCION DE PARTY------------------

func resolve_attack_action(actor_name: String, action: Dictionary):
	var nivel = PartyData.party_level
	var nivel_bonus = int((nivel - 1) * 10)
	var nivel_multiplicador = 100 + nivel_bonus

	var base_attack = PartyData.characters[actor_name]["stats"]["ataque_fisico"]
	var arma = PartyData.characters[actor_name]["equipo"]["arma"]
	var arma_attack = 0
	if arma != "":
		arma_attack = PartyData.equipables[arma]["stats"]["ataque_fisico"]

	var target_name = action.target
	var enemy_base_name = target_name.substr(0, target_name.length() - 1)

	var target = get_node_or_null("Enemies/EnemyContainersFront/" + target_name)
	if target == null:
		target = get_node_or_null("Enemies/EnemyContainersBack/" + target_name)

	if target != null:
		var enemy_data = EnemyData.enemies[enemy_base_name]
		var enemy_defensa = enemy_data["stats"]["defensa_fisica"]

		var raw_attack = (base_attack + arma_attack) * nivel_multiplicador / 100
		var calculated_attack = int(raw_attack - enemy_defensa)
		if calculated_attack < 0:
			calculated_attack = 0

		# Tipo (debilidades / resistencias / inmunidades / absorción)
		var tipo = ""
		if arma != "":
			tipo = PartyData.equipables[arma]["tipo"]
		else:
			tipo = PartyData.characters[actor_name]["ataque"]["basico"]["tipo"]

		var tipo_data = [enemy_data["debilidades"], enemy_data["resistencias"]]
		var mod_tipo = TypeTable.get_damage_modifier(tipo_data, tipo)

		# Crítico
		var crit_char = PartyData.characters[actor_name]["stats"]["critico"]
		var crit_arma = 0
		if arma != "":
			crit_arma = PartyData.equipables[arma]["stats"]["critico"]

		var crit_chance = crit_char + crit_arma
		var is_crit = randi_range(1, 100) <= crit_chance

		var crit_mult = 1.3 if is_crit else 1.0

		# Instancia daño flotante
		var dmg_scene = preload("res://Scenes/BTL/UI/Dmg.tscn")
		var dmg_instance = dmg_scene.instantiate()
		$Enemies.add_child(dmg_instance)
		var local_pos = target.get_screen_position() - $Enemies.get_screen_position()

		# Evasión
		var evasion = enemy_data["stats"]["evasion"]
		if randi_range(1, 100) <= evasion:
			dmg_instance.show_damage(0, local_pos + Vector2(200, 0), true, false, "normal")
			current_action_index += 1
			perform_next_action()
			return

		# Aplica multiplicadores tipo + crítico
		var tipo_relacion = "normal"
		if mod_tipo == TypeTable.INMUNE_MULT:
			calculated_attack = 0
			tipo_relacion = "inmune"
		elif mod_tipo == TypeTable.ABSORBE_MULT:
			calculated_attack = -calculated_attack
			tipo_relacion = "absorbe"
		elif mod_tipo == TypeTable.DEBIL_MULT:
			calculated_attack = int(calculated_attack * mod_tipo * crit_mult)
			tipo_relacion = "debil"
		elif mod_tipo == TypeTable.RESIST_MULT:
			calculated_attack = int(calculated_attack * mod_tipo * crit_mult)
			tipo_relacion = "resistente"
		else:
			calculated_attack = int(calculated_attack * crit_mult)

		# Aplica daño
		target.recibir_dano(calculated_attack)

		# Mostrar daño flotante
		dmg_instance.show_damage(calculated_attack, local_pos + Vector2(300, -10), false, is_crit, tipo_relacion)

	current_action_index += 1
	perform_next_action()





func _on_atacar_pressed() -> void:
	if current_state != BattleState.PLAYER_SELECTING:
		return
	
	var current_ally = WorldFunc.Party_BTL[current_ally_index]
	player_actions[current_ally] = {
		"type": "ataque",
		"subtype": "basico",
		"target": null  # Esperando selección de objetivo
	}
	
	_change_state(BattleState.TARGET_SELECTING)
