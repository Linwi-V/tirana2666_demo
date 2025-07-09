extends Node3D

enum State { FLOATING, PRESSED }

@export var amplitude := 0.1
@export var speed := 0.5

var current_state := State.FLOATING
var time_offset := 0.0

var base_y
var sync =true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_y = $StaticBody3D.position.y
	time_offset = randf_range(0.0, TAU)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if current_state == State.FLOATING:
		var t = Time.get_ticks_msec() / 1000.0
		var offset = sin((t + time_offset) * speed) * amplitude
		if sync:
			$StaticBody3D.position.y = base_y + offset
		else:
			if $StaticBody3D.position.y < -base_y + offset:
				$StaticBody3D.position.y+=0.002
			else:
				$tierritas.emitting =true
				sync=true
		
	elif current_state == State.PRESSED:
		sync=false
		if $StaticBody3D.position.y > -1.1*amplitude:
			$StaticBody3D.position.y -= 0.002
		

func _on_safe_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$tierritas.emitting = true
		current_state = State.PRESSED
		get_tree().call_group("player", "safe_place", self)

	pass # Replace with function body.


func _on_safe_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		current_state= State.FLOATING
	pass # Replace with function body.
	
