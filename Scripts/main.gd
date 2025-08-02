extends Node

func _ready():
	# Llama al SceneLoader autoload para cargar menu
	
	#
	#WorldFunc.start_battle(PartyData.active_party,["Eterna Ancestral","Eterna Ancestral"])
	
	#await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_int.tscn")
	await SceneLoader.request_scene_change("res://Scenes/menu/Menu.tscn")
	
