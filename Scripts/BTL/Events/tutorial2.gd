extends Node

var current_index := 0
var finished := false
var manager := Control

const d1 = preload("res://Dialogues/worlds/World2/BTL/tutorial2.dialogue")


func trigger_turn1(btl_manager):
	DialogueManager.show_dialogue_balloon(d1,"turno1")
	btl_manager.set_command_override("Habilidades", true)
	btl_manager.set_command_override("Escapar", true)

func trigger_turn2_enemyturn(_btl_manager):
	pass

func trigger_turn2(btl_manager):
	DialogueManager.show_dialogue_balloon(d1,"turno2")
	btl_manager.set_command_override("Habilidades", false)
func trigger_turn4(btl_manager):
	pass
	# Opcionalmente puedes poner algún diálogo o lógica extra aquí

func trigger_death(btl_manager):
	await FadeLayer.fade_out(0.5)
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_int_iglesiamain.tscn")
# ---------- TRIGGERS -------------
func is_turn1(btl_manager):
	return btl_manager.turn == 1

func is_turn2_enemyturn(btl_manager):
	return btl_manager.turn == 2 and btl_manager.current_state == btl_manager.BattleState.ENEMY_TURN

func is_turn2(btl_manager):
	return btl_manager.turn == 2

func is_turn4(btl_manager):
	return btl_manager.turn == 4
	
# ---------- EVENTOS ---------------
var events := [
	{
		"trigger": Callable(self, "is_turn1"),
		"action": Callable(self, "trigger_turn1")
	},
	{
		"trigger": Callable(self, "is_turn2"),
		"action": Callable(self, "trigger_turn2")
	}
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
