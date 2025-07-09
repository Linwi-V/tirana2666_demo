extends Node3D

const dialog = preload("res://Dialogues/prueba.dialogue")
const dialog2 = preload("res://Dialogues/worlds/World1/main/d2.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pp_dialog_changer(npc: Variant) -> void:
	$Pp.set_busy()
	if npc.name == "Tortu":
		$Pp.current_dialog=dialog2
	pass # Replace with function body.
