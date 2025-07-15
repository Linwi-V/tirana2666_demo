extends Node

func _ready():
	# Llama al SceneLoader autoload para cargar menu
	pass
	#WorldFunc.start_battle(PartyData.active_party,["Eterna Ancestral"],"res://Assets/BTL/BGs/BTL_Dummy.tres",true, "res://Scripts/BTL/Events/tutorial1.gd")
	WorldFunc.start_battle(PartyData.active_party+["Godot"],["Eterna Ancestral","Eterna Ancestral","Eterna Ancestral","Eterna Ancestral","Eterna Ancestral"])
	#await SceneLoader.request_scene_change("res://Scenes/menu/Menu.tscn")
	
