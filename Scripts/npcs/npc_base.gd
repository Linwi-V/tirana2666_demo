extends CharacterBody3D

var talks = false
var interact = false
var veces_talks = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteEmotes.stop()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	get_tree().call_group("player", "set_current_npc", self)
	if body.is_in_group("player") and body.can_talk and talks:
		hablas()
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and talks:
		var ani = $SpriteEmotes.animation
		$SpriteEmotes.play_backwards(ani)
	get_tree().call_group("player", "clear_current_npc", self)


func hablas():
	$SpriteEmotes.play("talk")

func deshablas():
	$SpriteEmotes.play_backwards("talk")
	
func exclamar():
	$SpriteEmotes.play("exclamation")
	
func desexclamar():
	$SpriteEmotes.play_backwards("exclamation")
