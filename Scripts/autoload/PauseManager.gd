extends Node

var pause_menu_scene := preload("res://Scenes/ui/PauseMenu.tscn")
var pause_menu: Control

func _enter_tree():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready():
	pause_menu = pause_menu_scene.instantiate()
	pause_menu.visible = false
	get_tree().root.add_child.call_deferred(pause_menu)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = get_tree().paused
	pause_menu.visible = get_tree().paused
