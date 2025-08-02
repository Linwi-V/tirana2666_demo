extends CharacterBody3D

var talks = false
var interact = false
var veces_talks = 0
enum State { IDLE, BUSY }
var state = State.IDLE

var velocidad_mov = 4.0
var external_direction := Vector3.ZERO

var JUMP_VELOCITY = 4.5 
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteEmotes.stop()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			handle_idle_state()
		State.BUSY:
			handle_busy_state()
	velocity.y -= GRAVITY * delta
	move_and_slide()

func handle_busy_state() -> void:
	if external_direction != Vector3.ZERO:
		velocity.x = external_direction.x * velocidad_mov
		velocity.z = external_direction.z * velocidad_mov
	else:
		velocity.x = 0
		velocity.z = 0

func set_busy() -> void:
	state = State.BUSY

func release_busy() -> void:
	state = State.IDLE
	external_direction = Vector3.ZERO

func set_external_direction(dir: Vector3) -> void:
	if state == State.BUSY:
		external_direction = dir.normalized()


func handle_idle_state() -> void:
	# Por ahora sin lógica, pero podrías meter animaciones por defecto si querés
	pass



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("player", "set_current_npc", self)
		if body.can_talk and talks:
			hablas()
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("player", "clear_current_npc", self)
		if talks:
			var ani = $SpriteEmotes.animation
			$SpriteEmotes.play_backwards(ani)
	


func hablas():
	$SpriteEmotes.play("talk")

func deshablas():
	$SpriteEmotes.play_backwards("talk")
	
func exclamar():
	$SpriteEmotes.play("exclamation")
	
func desexclamar():
	$SpriteEmotes.play_backwards("exclamation")
