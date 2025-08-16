extends Node

var current_index := 0
var finished := false
var manager := Control

const d1 = preload("res://Dialogues/worlds/World2/EXT/quests/ladron_pelea.dialogue")


func trigger_turn1(btl_manager):
	btl_manager.set_command_override("Habilidades", true)
	btl_manager.set_command_override("Escapar", true)

func trigger_death(btl_manager):
	DialogueManager.show_dialogue_balloon(d1)
	await get_tree().create_timer(3.0).timeout
	MusicManager.stop_music(1.0)
	await FadeLayer.fade_out(1.0)
	await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD2_ext.tscn")
# ---------- TRIGGERS -------------
func is_turn1(btl_manager):
	return btl_manager.turn == 1
	
# ---------- EVENTOS ---------------
var events := [
	{
		"trigger": Callable(self, "is_turn1"),
		"action": Callable(self, "trigger_turn1")
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
