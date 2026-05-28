extends CharacterBody3D

var talks = false
var interact = false
var veces_talks = 0
enum State { IDLE, BUSY,FOLLOW }
var state = State.IDLE

var velocidad_mov = 4.0
var external_direction := Vector3.ZERO
var external_look := Vector3.ZERO

var JUMP_VELOCITY = 4.5 
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

# Spritesheet

@export var walk_texture: Texture2D
@export var idle_texture: Texture2D
var idle = load("res://Sprites/Chars/ph/64X128_Idle_Free.png")
var walk
# Animación
var tiempo = 0.0
var lag_frame = 0.1
# para follow
var follow_target: Node3D
var follow_distance :float= 1.0
var yaw = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteEmotes.stop()
	walk = load("res://Sprites/Chars/katari/prota_sprt.png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	yaw=rotation.y
	
	match state:
		State.IDLE:
			handle_idle_state()
		State.BUSY:
			handle_busy_state()
		State.FOLLOW:
			handle_follow_state()

	velocity.y -= GRAVITY * delta
	
	move_and_slide()
	
	update_animation(delta)

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

func set_external_point(target_position: Vector3):
	if state == State.BUSY:
		var current_position = global_transform.origin
		var direction = (target_position - current_position).normalized()
		external_direction = direction
		
		
func handle_idle_state() -> void:
	# Por ahora sin lógica, pero podrías meter animaciones por defecto si querés
	pass

func handle_follow_state() -> void:
	if follow_target == null:
		return
	
	yaw = follow_target.yaw

	# Dirección de movimiento real del personaje al que seguimos
	var move_dir = follow_target.velocity
	move_dir.y = 0

	var forward := Vector3.ZERO
	if move_dir.length() > 0.01:
		# Si se mueve, usamos su dirección de movimiento
		forward = move_dir.normalized()
	else:
		# Si está quieto, usamos una dirección cualquiera para calcular posición deseada (aquí no es crucial)
		forward = Vector3.FORWARD

	# Posición deseada: detrás del target si se mueve, o su posición exacta si está quieto
	var desired_pos: Vector3
	if move_dir.length() > 0.01:
		desired_pos = follow_target.global_position - forward * follow_distance
	else:
		desired_pos = follow_target.global_position

	# Distancia actual al target
	var distance := global_position.distance_to(follow_target.global_position)

	# Si está fuera del rango radial, moverse hacia la posición deseada
	if distance > follow_distance:
		var dir := (desired_pos - global_position).normalized()
		external_direction = dir
		velocity.x = dir.x * velocidad_mov*0.98
		velocity.z = dir.z * velocidad_mov*0.98
	else:
		# Ya está dentro del rango, detenerse
		velocity = Vector3.ZERO

	# Mirar hacia el target para animación
	var dir_to_target := follow_target.global_position - global_position
	dir_to_target.y = 0
	external_look = dir_to_target.normalized()




		
func set_follow(t: Node3D) -> void:
	state = State.FOLLOW
	follow_target = t
	
func stop_follow() -> void:
	release_busy() # vuelve a IDLE
	follow_target = null
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if state==State.FOLLOW:
		return
	if body.is_in_group("player"):
		get_tree().call_group("player", "set_current_npc", self)
		if body.can_talk and talks:
			hablas()
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if state==State.FOLLOW:
		return
	if body.is_in_group("player"):
		get_tree().call_group("player", "clear_current_npc", self)
		if talks:
			deshablas()
	


func hablas():
	if not WorldFunc.cutscene:
		$SpriteEmotes.play("talk")

func deshablas():
	if not WorldFunc.cutscene:
		
		$SpriteEmotes.play_backwards("talk")
	
func exclamar():
	$SpriteEmotes.play("exclamation")
	
func desexclamar():
	$SpriteEmotes.play_backwards("exclamation")

func mini_saltar():
	velocity.y+=2








func update_animation(delta):
	var sprite = $Sprite3D
	var mat = $Sprite3D.material_override.duplicate()
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
		sprite.texture = idle
		mat.albedo_texture = idle
		
	if sprite.texture == walk:
		tiempo += delta
		if tiempo > lag_frame:
			sprite.frame_coords.x = (sprite.frame_coords.x + 1) % 8
			tiempo = 0
	else:

		sprite.texture = walk   ###aun no hay idle
		mat.albedo_texture = walk
		sprite.frame_coords.x=2
		if external_look!=Vector3.ZERO and state!=State.FOLLOW:
			if external_look==Vector3.FORWARD:
				sprite.frame_coords.y = 3
			elif external_look==Vector3.RIGHT:
				sprite.frame_coords.y = 2
			elif external_look==Vector3.LEFT:
				sprite.frame_coords.y = 1
			else:
				sprite.frame_coords.y = 0
		#else:
		#	if follow_target!=null:
		#		sprite.frame_coords.y =follow_target.get_node("Sprite3D").frame_coords.y
	
	sprite.material_override=mat

func get_direction_from_yaw(yaw: float) -> int:
	var angle = wrapf(yaw, -PI, PI)
	if angle >= -PI/4 and angle < PI/4:
		return 2  # derecha
	elif angle >= PI/4 and angle < 3*PI/4:
		return 0  # arriba
	elif angle <= -PI/4 and angle > -3*PI/4:
		return 3  # abajo
	else:
		return 1  # izquierda
