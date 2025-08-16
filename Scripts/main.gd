extends Node

func _ready():
	# Llama al SceneLoader autoload para cargar menu
	
	await SceneLoader.request_scene_change("res://Scenes/menu/Menu.tscn")
	#WorldFunc.start_battle(["Katari","Gemelo 2","Fortunato","Gemelo 1"],["Esbirro A","Esbirro B"])
	
	#await SceneLoader.request_scene_change("res://Scenes/worlds/WORLD1_int.tscn")
	
	
