extends Node

var Party_BTL := []
var Enemy_BTL := []
var BTL_BG

func start_battle(party_members: Array, enemy_data: Array, BG:= "res://Assets/BTL/BGs/BTL_Dummy.tres"):
	Party_BTL = party_members
	Enemy_BTL = enemy_data
	BTL_BG = BG
	await SceneLoader.request_scene_change("res://Scenes/BTL/BTL.tscn")
	
