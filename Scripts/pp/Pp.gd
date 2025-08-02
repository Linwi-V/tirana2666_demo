extends CharacterBody3D

enum State { IDLE, MOVE, JUMP, BUSY }
var state = State.JUMP

var velocidad_mov = 4.0
var JUMP_VELOCITY = 4.5 
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

# Animación
var tiempo = 0.0
var lag_frame = 0.1

# Spritesheet
var idle = load("res://Sprites/Chars/ph/64X128_Idle_Free.png")
var walk = load("res://Sprites/Chars/katari/prota_sprt.png")

#safe  space si se cae
var last_safe_place = position

# Dirección forzada para estado BUSY
var external_direction := Vector3.ZERO

#utilidad para cuando puedas interactuar
var current_npc: Node = null

#var dinamica para dialogos
var current_dialog
var talking=false

# var movs cam
var moving_cam
var pivot_og
var cam_final
var can_talk := true
var fov_og

# señales 
signal dialog_changer(npc)

#var mov camara boton
var cam_rotation_speed = 1.5 # Velocidad de rotación en radianes por segundo
var yaw: float = 0.0

func _ready() -> void:
	fov_og = $Pivot/SpringArm3D/Camera3D.fov
	DialogueManager.dialogue_started.connect(d_started)
	DialogueManager.dialogue_ended.connect(d_ended)

#FSM AKI
func _physics_process(delta):

	
	if moving_cam and not $Pivot.active:
		$Pivot.global_position=$Pivot.global_position.lerp(cam_final, 5 * delta)
		if $Pivot.global_position.distance_to(cam_final) < 0.05:
			$Pivot.global_position=cam_final
			moving_cam = false
	
	elif not moving_cam and not talking and state==State.BUSY and not WorldFunc.cutscene:
		release_busy()#dialogeo
	
	elif is_on_floor() and can_talk and current_npc!= null and Input.is_action_just_pressed("ui_accept") and state != State.BUSY:
		emit_signal("dialog_changer",current_npc)
		DialogueManager.show_dialogue_balloon(current_dialog)
	
		# Rotación de cámara con ui_q y ui_e
	if state != State.BUSY:
			
		if Input.is_action_pressed("ui_q"):
			yaw -= cam_rotation_speed * delta
		elif Input.is_action_pressed("ui_e"):
			yaw += cam_rotation_speed * delta

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
	yaw = wrapf(yaw, -PI, PI)
	$Pivot.rotation.y = yaw
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
		
	var rotation_nueva = Basis(Vector3.UP, yaw)   ###aqui la rotacion actualizada
	
	dir= rotation_nueva * dir
	
	velocity.x = dir.x * velocidad_mov
	velocity.z = dir.z * velocidad_mov
	move_and_slide()

func handle_jump_state():
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var rotation_nueva = Basis(Vector3.UP, yaw)
	dir= rotation_nueva * dir
	velocity.x = dir.x * velocidad_mov
	velocity.z = dir.z * velocidad_mov
	
	move_and_slide()
	
	if is_on_floor():
		if dir != Vector3.ZERO:
			state = State.MOVE
		else:
			state= State.IDLE
	
func handle_busy_state():
	
	#movs
	if external_direction != Vector3.ZERO:
		velocity.x = external_direction.x * velocidad_mov
		velocity.z = external_direction.z * velocidad_mov
		
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func update_animation(delta):
	var sprite = $Sprite3D
	var mat = $Sprite3D.material_override
	var dir_mov = Vector2(velocity.x, velocity.z)
	var dir = dir_mov.rotated(yaw).normalized()
	if dir.length() > 0.1:
		sprite.texture = walk
		mat.albedo_texture = walk
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
		pass
		sprite.texture = idle
		mat.albedo_texture = idle
		
	if sprite.texture == walk:
		tiempo += delta
		if tiempo > lag_frame:
			sprite.frame_coords.x = (sprite.frame_coords.x + 1) % 8
			tiempo = 0
	else:
		sprite.texture = walk
		mat.albedo_texture = walk
		sprite.frame_coords.x=2
		#aqui textura idle si es q
		#sprite.frame_coords.x = 0

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

# señales funcion dialogos
func d_started(_d):
	if current_npc:
		var dir = current_npc.global_position - global_position
		dir.y = 0
		# Convertimos a Vector2 y compensamos la rotación del Pivot
		var dir_2d = Vector2(dir.x, dir.z).rotated(yaw).normalized()
		var angle = dir_2d.angle()

		if angle >= -PI/4 and angle < PI/4:
			$Sprite3D.frame_coords.y = 2 # derecha
		elif angle >= PI/4 and angle < 3*PI/4:
			$Sprite3D.frame_coords.y = 0 # arriba
		elif angle <= -PI/4 and angle > -3*PI/4:
			$Sprite3D.frame_coords.y = 3 # abajo
		else:
			$Sprite3D.frame_coords.y = 1 # izquierda
		
		#zoom
		var tween = create_tween()
		tween.tween_property($Pivot/SpringArm3D/Camera3D, "fov", 55, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


		talking=true
		can_talk=false
		$Pivot.active=false
		
		pivot_og = $Pivot.global_position
		cam_final = (self.global_position+current_npc.global_position)/2 +Vector3(0,-0.6,0)
		moving_cam = true
	
	
func d_ended(_d):
	#zoom
	var tween = create_tween()
	tween.tween_property($Pivot/SpringArm3D/Camera3D, "fov", fov_og, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if current_npc != null:
		current_npc.deshablas()
	cam_final = pivot_og
	moving_cam = true
	talking=false
	$Timer.start()

# esto pa q no puedas hablarle altiro dsps de salir sin querer
func _on_timer_timeout() -> void:
	if $Pivot.exterior:
		$Pivot.active=true
	if current_npc != null:
		current_npc.hablas()
		print($Pivot.exterior)
		print($Pivot.active)
	can_talk = true
