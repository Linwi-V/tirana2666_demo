extends Node2D

@export var speed_caida: float  = 9
var key: String
var check_limit: float = 980
var spawn_time:float
var activa: bool = true
signal missed(nota)

const GOOD_WINDOW :float = 50.0

func _ready() -> void:
	position.y=-64
	if key =="ui_left":
		self.frame=0
		position.x=768
	elif key =="ui_down":
		self.frame=1
		position.x=768+128
	elif key =="ui_up":
		self.frame=2
		position.x=768+256
	elif key =="ui_right":
		self.frame=3
		position.x=768+192+192
		
func _process(_delta: float) -> void:
	var t := MusicManager.get_synced_time()
	var elapsed := t - spawn_time

	var START_Y := -64.0
	var TARGET_Y := 980.0
	var lead := MusicManager.lead_time
	var extra := 0.1  # ventana extra de golpe
	var velocity := (TARGET_Y - START_Y) / lead
	var FINAL_Y := TARGET_Y + velocity * extra

	if not activa:
		position.y += 3.5  # caída libre visual
		
	elif elapsed < lead:
		var progress :float = clamp(elapsed / lead, 0.0, 1.0)
		position.y = lerp(START_Y, TARGET_Y, progress)
	elif elapsed < lead + extra:
		var post := elapsed - lead
		var post_progress :float = clamp(post / extra, 0.0, 1.0)
		position.y = lerp(TARGET_Y, FINAL_Y, post_progress)

	else:
		if activa:
			activa = false
			emit_signal("missed", self)
			
	if position.y > FINAL_Y + 40.0:
		queue_free()

	


	
