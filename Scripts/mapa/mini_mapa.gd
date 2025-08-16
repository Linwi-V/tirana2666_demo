extends Control

@export var player_path: NodePath
@onready var player = get_parent()
@onready var mini_map_camera = $viewport.get_node("Camera3D")
@onready var player_icon = $PlayerIcon
@onready var quest_marker = $QuestIcon
@onready var viewport = $viewport

const CAMERA_HEIGHT = 50.0
const ICON_SIZE = 64.0
const VIEWPORT_SIZE = Vector2(256, 256)
const CAMERA_SIZE = 50.0  # Esto significa que el área visible es de 100x100 unidades

func _ready():
	mini_map_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	mini_map_camera.size = CAMERA_SIZE
	mini_map_camera.rotation_degrees = Vector3(-90, 0, 0)

func _process(delta):

	if not player:
		return
	var player_pos = player.global_transform.origin
	mini_map_camera.global_transform.origin = Vector3(player_pos.x, CAMERA_HEIGHT, player_pos.z)
	var quest = WorldFunc.quest
	if quest == "":
		quest_marker.hide()
		return

	quest_marker.show()

	var quest_world_pos: Vector3
	match quest:
		"comprar_1", "comprar_2", "post_ladron", "comprar_robado":
			quest_world_pos = Vector3(-10.2, 0, 12.5)
		"fin_demo":
			quest_world_pos = Vector3(0.9, 0, 18.3)
		"ladron":
			quest_world_pos = Vector3(11.5, 0, -8)
		"casimiro":
			quest_world_pos = Vector3(-8.8, 0, -13.636)
		_:
			quest_marker.hide()
			return
	
	# Actualizar posición de la cámara del minimapa


	# Proyectar la posición 3D al espacio 2D del Viewport
	var screen_pos: Vector2 = mini_map_camera.unproject_position(quest_world_pos)

	# Ajustar para que el icono esté centrado
	screen_pos -= Vector2(ICON_SIZE * 0.5, ICON_SIZE * 0.5)

	# Clamp para mantener dentro del minimapa
	screen_pos.x = clamp(screen_pos.x, 0.0, VIEWPORT_SIZE.x)
	screen_pos.y = clamp(screen_pos.y, 0.0, VIEWPORT_SIZE.y)

	# Asignar posición final
	quest_marker.position = screen_pos
