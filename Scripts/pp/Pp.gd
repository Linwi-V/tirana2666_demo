extends CharacterBody3D

enum State { IDLE, MOVE, JUMP, BUSY }
var state = State.JUMP

const SPEED = 4.0
const JUMP_VELOCITY = 4.5 
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

# Animación
var tiempo = 0.0
var lag_frame = 0.2

# Spritesheet
var idle = load("res://Sprites/Chars/ph/64X128_Idle_Free.png")
var walk = load("res://Sprites/Chars/ph/64X128_Runing_Free.png")

#safe  space si se cae
var last_safe_place = position

# Dirección forzada para estado BUSY
var external_direction := Vector3.ZERO

#utilidad para cuando puedas interactuar
var current_npc: Node = null


func _physics_process(delta):
	
	if current_npc!= null and Input.is_action_just_pressed("ui_accept") and state != State.BUSY:
		print("dialogo")
		set_busy()
		
	match state:
		State.IDLE:
			handle_idle_state()
		State.MOVE:
			handle_move_state()
		State.JUMP:
			handle_jump_state()
		State.BUSY:
			handle_busy_state()
	velocity.y -= GRAVITY * delta
	update_animation(delta)
	

func handle_idle_state():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		state = State.MOVE
	elif Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state = State.JUMP
	move_and_slide()
	
func handle_move_state():
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if dir == Vector3.ZERO:
		state = State.IDLE
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		state = State.JUMP
		
	var rotation_nueva = Basis(Vector3.UP, $Pivot.yaw)   ###aqui la rotacion actualizada
	
	dir= rotation_nueva * dir
	
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	move_and_slide()

func handle_jump_state():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var rotation_nueva = Basis(Vector3.UP, $Pivot.yaw)
	dir= rotation_nueva * dir
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	
	move_and_slide()
	
	if is_on_floor():
		if dir != Vector3.ZERO:
			state = State.MOVE
		else:
			state= State.IDLE
	
func handle_busy_state():
	if external_direction != Vector3.ZERO:
		velocity.x = external_direction.x * SPEED
		velocity.z = external_direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func update_animation(delta):
	var sprite = $Sprite3D
	var dir_mov = Vector2(velocity.x, velocity.z)
	var dir = dir_mov.rotated($Pivot.yaw).normalized()
	if dir.length() > 0.1:
		sprite.texture = walk
		var angle = dir.angle()
		if angle >= -PI/4 and angle < PI/4:
			sprite.frame_coords.y = 2 # derecha
		elif angle >= PI/4 and angle < 3*PI/4:
			sprite.frame_coords.y = 0 # arriba
		elif angle <= -PI/4 and angle > -3*PI/4:
			sprite.frame_coords.y = 3 # abajo
		else:
			sprite.frame_coords.y = 1 # izquierda
	else:
		sprite.texture = idle

	if sprite.texture == walk:
		tiempo += delta
		if tiempo > lag_frame:
			sprite.frame_coords.x = (sprite.frame_coords.x + 1) % 8
			tiempo = 0
	else:
		sprite.frame_coords.x = 0

# Funciones públicas para cinemáticas o NPCs
func set_busy():
	state = State.BUSY

func release_busy():
	state = State.IDLE
	external_direction = Vector3.ZERO

func set_external_direction(dir: Vector3):
	if state == State.BUSY:
		external_direction = dir.normalized()


#Funciones para NPCs

func set_current_npc(npc: Node):
	current_npc = npc

func clear_current_npc(npc: Node):
	if current_npc == npc:
		current_npc = null
		
#funcion para respawn
func safe_place(pos: Node3D):
	last_safe_place= pos.global_transform.origin
	last_safe_place.y +=2.5
