extends Node

var Party_BTL := []
var Enemy_BTL := []
var BTL_BG
var BTL_EVENT_SCRIPT_PATH := ""
var BTL_AMBUSH

###para no romperse nada mientras cutscene
var cutscene:bool=false


#####historia
var primera_vez_w1_int : bool = true
var segunda_vez_w1_int:bool=true

var primera_vez_w2_intmain : bool = true
var segunda_vez_w2_intmain : bool = true

var primera_vez_w2_ext:bool= true



#######cinematics
var cinematic_1:bool = false
var cinematic_2:bool = false

#####quest
var quest







func start_battle(
	party_members: Array,
	enemy_data: Array,
	BG := "res://Assets/BTL/BGs/BTL_Dummy.tres",
	ambush := false,
	event_script := ""
	):
	Party_BTL = party_members
	Enemy_BTL = enemy_data
	BTL_BG = BG
	BTL_EVENT_SCRIPT_PATH = event_script
	BTL_AMBUSH = ambush
	await SceneLoader.request_scene_change("res://Scenes/BTL/BTL.tscn")
	
