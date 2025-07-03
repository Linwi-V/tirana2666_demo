extends Node

func _ready():
	# Llama al SceneLoader autoload para cargar World1.tscn
	await SceneLoader.request_scene_change("res://Scenes/menu/Menu.tscn")
	
