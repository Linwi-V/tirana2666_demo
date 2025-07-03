extends Node

var hay_save = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func Selected(opt):
	if opt==0:
		$VBoxContainer/Salir.modulate=Color.WHITE
		$VBoxContainer/NuevaPartida.modulate=Color.WHITE
	if opt==1:
		$VBoxContainer/NuevaPartida.modulate=Color.hex(0x82ade7)
		$VBoxContainer/Salir.modulate=Color.WHITE
	elif opt==2:
		if hay_save:
			$VBoxContainer/Salir.modulate=Color.WHITE
			$VBoxContainer/NuevaPartida.modulate=Color.WHITE
			pass ##a pantalla de cargar
		else:
			pass
	elif opt ==3:
		$VBoxContainer/NuevaPartida.modulate=Color.WHITE
		$VBoxContainer/Salir.modulate=Color.hex(0x82ade7)
func _on_nueva_partida_pressed() -> void:
	$VBoxContainer/NuevaPartida.disabled=true
	await FadeLayer.fade_out()
	await SceneLoader.request_scene_change("res://Scenes/intro/Cinematic1.tscn")
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_nueva_partida_mouse_entered() -> void:
	Selected(1)
	pass # Replace with function body.


func _on_nueva_partida_mouse_exited() -> void:
	Selected(0)
	pass # Replace with function body.


func _on_salir_mouse_entered() -> void:
	Selected(3)
	pass # Replace with function body.


func _on_salir_mouse_exited() -> void:
	Selected(0)
	pass # Replace with function body.
