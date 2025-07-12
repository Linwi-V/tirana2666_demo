extends Node

@export var Enemy : PackedScene
@export var Ally : PackedScene

enum BattleState {
	IDLE,
	DIALOGUE,
	PLAYER_SELECTING,
	PLAYER_ACTING,
	ENEMY_TURN,
	RESOLVING,
	VICTORY,
	DEFEAT
}

var current_state: BattleState = BattleState.IDLE

func _ready() -> void:
	
	#FOndo
	$Background.texture = load(WorldFunc.BTL_BG)
	
	#crea aliados
	for i in WorldFunc.Party_BTL.size():
		#vars
		var chars = WorldFunc.Party_BTL[i]
		var new_ally = Ally.instantiate()
		var retrato = new_ally.get_node("Ally")
		#cambio nombre
		new_ally.name=chars+str(i)
		#entrega id y textura
		new_ally.character_id=chars
		retrato.texture = load(PartyData.characters[chars]["textura"])
		#señales
		new_ally.hp_changed.connect(_on_ally_hp_changed)
		new_ally.died.connect(_on_ally_died)
		#añade a escena
		get_node("UI/AllyContainers").add_child(new_ally)
	
	
	#crea enemigos
	for i in WorldFunc.Enemy_BTL.size():
		#vars
		var chars = WorldFunc.Enemy_BTL[i]
		var new_enemy = Enemy.instantiate()
		var retrato = new_enemy.get_node("Enemy")
		#cambio nombre
		new_enemy.name=chars+str(i)
		#entrega id y textura
		new_enemy.character_id=chars
		retrato.texture = load(EnemyData.enemies[chars]["textura"])
		#señales
		new_enemy.hp_changed.connect(_on_enemy_hp_changed)
		new_enemy.died.connect(_on_enemy_died)
		#orden en pantalla
		if i <3:
			get_node("Enemies/EnemyContainersFront").add_child(new_enemy)
		else:
			get_node("Enemies/EnemyContainersBack").add_child(new_enemy)
			if WorldFunc.Enemy_BTL.size() ==4:
				var dummy = Control.new()
				get_node("Enemies/EnemyContainersBack").add_child(dummy)
		
	#Setea Idle
	_change_state(BattleState.IDLE)

#-------------FSM LOGICA AQUI----------------

func _change_state(new_state: BattleState) -> void:
	current_state = new_state
	match current_state:
		BattleState.IDLE:
			print("Estado: IDLE")
			# Aquí podrías revisar si hay algo pendiente antes de que empiece el turno
			
		BattleState.DIALOGUE:
			print("Estado: DIALOGUE")
			_handle_dialogue()

		BattleState.PLAYER_SELECTING:
			print("Estado: PLAYER_SELECTING")
			# Código para mostrar menú y esperar input del jugador

		BattleState.PLAYER_ACTING:
			print("Estado: PLAYER_ACTING")
			# Ejecutar la acción seleccionada

		BattleState.ENEMY_TURN:
			print("Estado: ENEMY_TURN")
			# Turno de enemigos

		BattleState.RESOLVING:
			print("Estado: RESOLVING")
			# Resolviendo efectos y estado final

		BattleState.VICTORY:
			print("Estado: VICTORY")
			# Batalla ganada

		BattleState.DEFEAT:
			print("Estado: DEFEAT")
			# Batalla perdida

#-------------LLAMADA DE DIALOGOS----------
func _handle_dialogue() -> void:
	pass
	
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
	for allies in $UI/AllyContainers.get_children():
		if not allies.rip:
			return
			
	_change_state(BattleState.DEFEAT)  ###aqui trans a gameover
	
#-------------SEÑALES ENEMIGOS----------
func _on_enemy_hp_changed(_new_hp,enemy):
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
