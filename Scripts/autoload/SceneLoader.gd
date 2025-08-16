extends Node

enum State {
	IDLE,
	TRANSITION_IN,
	LOADING,
	TRANSITION_OUT
}

var current_state = State.IDLE
var next_scene_path := ""
var current_scene: Node = null
var loading_screen: Node = null

func _ready():
	# Opcional: precargar la pantalla de carga si tienes una
	var loading_scene := preload("res://Scenes/ui/LoadingScreen.tscn")
	loading_screen = loading_scene.instantiate()
	add_child(loading_screen)
	loading_screen.visible = false

func request_scene_change(path: String):
	if path == "res://Scenes/worlds/WORLD1_int.tscn":
		MusicManager.play_music(load("res://0_pruebas/oasis.mp3"),2)
		
	if path == "res://Scenes/worlds/WORLD1_ext.tscn":
		MusicManager.play_music(load("res://musicas/World1/limboV3.ogg"),2)
		
	if path == 	"res://Scenes/BTL/BTL.tscn":
		MusicManager.play_music(load("res://musicas/BTL/musica pueblo.ogg"),0.5)
		
		
	if path == "res://Scenes/worlds/WORLD2_ext.tscn":
		MusicManager.play_music(load("res://musicas/World2/musica casa prota.ogg"),2)
		
	if path == "res://Scenes/worlds/WORLD2_int_iglesia1.tscn":
		MusicManager.play_music(load("res://musicas/World2/Iglesia.ogg"),2)
		
	if path == "res://Scenes/worlds/WORLD2_int_iglesia1.tscn":
		MusicManager.play_music(load("res://musicas/World2/Iglesia.ogg"),2)
	if current_state != State.IDLE:
		push_warning("SceneLoader ocupado. Esperando a terminar el cambio anterior.")
		return
	next_scene_path = path
	_change_state(State.TRANSITION_IN)

func _change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.TRANSITION_IN:
			# Aquí podrías mostrar una animación de fade-in si quieres
			if current_scene:
				current_scene.queue_free()
			_show_loading_screen()
			await FadeLayer.fade_in()
			await get_tree().create_timer(.5).timeout
			_change_state(State.LOADING)

		State.LOADING:
			await _load_scene_async(next_scene_path)

		State.TRANSITION_OUT:
			
			await get_tree().create_timer(.5).timeout
			_hide_loading_screen()
			FadeLayer.fade_in()
			_change_state(State.IDLE)
			

		State.IDLE:
			# Nada que hacer
			pass


func _show_loading_screen():
	if loading_screen:
		loading_screen.visible = true

func _hide_loading_screen():
	if loading_screen:
		loading_screen.visible = false

func _load_scene_async(path: String) -> void:
	var result := ResourceLoader.load_threaded_request(path)
	if result == null:
		push_error("Error: No se pudo iniciar carga de escena.")
		_change_state(State.TRANSITION_OUT)
		return

	while true:
		var status := ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			await FadeLayer.fade_out()
			var packed_scene := ResourceLoader.load_threaded_get(path)
			current_scene = packed_scene.instantiate()
			get_tree().root.add_child(current_scene)
			break

		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Error: Falló la carga de la escena.")
			break

		await get_tree().process_frame

	_change_state(State.TRANSITION_OUT)
