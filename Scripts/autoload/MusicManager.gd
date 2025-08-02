# res://Scripts/MusicManager.gd
extends Node

@export var bpm: float = 120
@export var lead_time: float = 1.5 #1.9333 #1.779

var music_player: AudioStreamPlayer
var sample_rate: int
var start_sample_offset: int = 0
var beat_duration: float

var has_started:bool=false
var pre_lead_time:float=0

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Música"
	add_child(music_player)

	sample_rate = AudioServer.get_mix_rate()
	beat_duration = 60.0 / bpm

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	music_player.stream = stream
	music_player.play()
	has_started=true
	# Esperamos un frame para que el playback interno se cree
	await get_tree().process_frame
	# Ahora ya podemos capturar las muestras iniciales
	start_sample_offset = _get_current_sample_position()
	
		# (Opcional) fade-in
	music_player.volume_db = -80.0
	_tween_volume_to(-9.0, fade_time)

func stop_music(fade_time: float = 1.0) -> void:
	if not has_started:
		return
	has_started = false

	var tw = get_tree().create_tween()
	tw.tween_property(music_player, "volume_db", -80.0, fade_time)
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.connect("finished", Callable(self, "_on_fade_out_finished"))

func _on_fade_out_finished() -> void:
	if music_player.playing:
		music_player.stop()
		
func _get_current_sample_position() -> int:
	var playback = music_player.get_stream_playback()
	if playback != null and playback.has_method("get_position"):
		# Formatos como OGG/MP3 usan get_position()
		return int(playback.call("get_position"))
	# En WAV u otros casos donde no exista get_position()
	# usamos get_playback_position() * sample_rate
	return int(music_player.get_playback_position() * sample_rate)

func get_playback_time() -> float:
	var elapsed = _get_current_sample_position() - start_sample_offset
	return float(elapsed) / sample_rate

func get_current_beat() -> float:
	return get_playback_time() / beat_duration

func _tween_volume_to(target_db: float, duration: float) -> void:
	var tw = get_tree().create_tween()
	tw.tween_property(music_player, "volume_db", target_db, duration)
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func get_synced_time() -> float:
	if has_started:
		return get_playback_time() + pre_lead_time
	return pre_lead_time
