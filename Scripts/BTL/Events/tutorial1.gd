extends Node

var current_index := 0
var finished := false
var manager := Control

const d1 = preload("res://Dialogues/worlds/World1/BTL/tutorial1_turno1.dialogue")
const d2 = preload("res://Dialogues/worlds/World1/BTL/tutorial1_turno2.dialogue")
const d3 = preload("res://Dialogues/worlds/World1/BTL/tutorial1_turno3.dialogue")

func trigger_turn1(btl_manager):
	DialogueManager.show_dialogue_balloon(d1)
	btl_manager.set_command_override("Habilidades", true)
	btl_manager.set_command_override("Objetos", true)
	btl_manager.set_command_override("Escapar", true)

func trigger_turn2_enemyturn(_btl_manager):
	DialogueManager.show_dialogue_balloon(d2)

func trigger_turn3(btl_manager):
	DialogueManager.show_dialogue_balloon(d3)
	btl_manager.set_command_override("Atacar", true)
	btl_manager.set_command_override("Objetos", false)

func trigger_turn4(btl_manager):
	btl_manager.set_command_override("Atacar", false)
	# Opcionalmente puedes poner algún diálogo o lógica extra aquí

# ---------- TRIGGERS -------------
func is_turn1(btl_manager):
	return btl_manager.turn == 1

func is_turn2_enemyturn(btl_manager):
	return btl_manager.turn == 2 and btl_manager.current_state == btl_manager.BattleState.ENEMY_TURN

func is_turn3(btl_manager):
	return btl_manager.turn == 3

func is_turn4(btl_manager):
	return btl_manager.turn == 4

# ---------- EVENTOS ---------------
var events := [
	{
		"trigger": Callable(self, "is_turn1"),
		"action": Callable(self, "trigger_turn1")
	},
	{
		"trigger": Callable(self, "is_turn2_enemyturn"),
		"action": Callable(self, "trigger_turn2_enemyturn")
	},
	{
		"trigger": Callable(self, "is_turn3"),
		"action": Callable(self, "trigger_turn3")
	},
	{
		"trigger": Callable(self, "is_turn4"),
		"action": Callable(self, "trigger_turn4")
	},
]

# -------- FUNCION PRINCIPAL ----------
func trigger_event(btl_manager) -> bool:
	if current_index >= events.size():
		finished = true
		return false

	var evt = events[current_index]
	
	if evt.trigger.call(btl_manager):
		await evt.action.call(btl_manager)
		current_index += 1
		return true
	
	return false
