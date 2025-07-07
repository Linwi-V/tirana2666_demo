extends CharacterBody3D

var talks = false
var texto = ""
var interact = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and talks:
		$SpriteEmotes.play("talk")
		get_tree().call_group("player", "set_current_npc", self)
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and talks:
		$SpriteEmotes.play_backwards("talk")
		get_tree().call_group("player", "clear_current_npc", self)


	
