# res://Scripts/DNC_Manager.gd
extends Control

@export var spawn_scene: PackedScene
@export var beatmap_file: String = "res://Scripts/DNC/JsonMaps/beatmap_ph.json"


const PERFECT_WINDOW := 0.045  # ±45 ms
const GREAT_WINDOW   := 0.085  # ±85 ms
const GOOD_WINDOW    := 0.13   # ±130 ms


var beatmap: Array     = []
var next_index: int    = 0
var active_notes       = {
	"ui_left":  [], 
	"ui_down":  [], 
	"ui_up":    [], 
	"ui_right": []
}

var INPUT_OFFSET : float = 0

#------PUNTAJES----------
var score: int = 0
var combo: int = 0
var max_combo: int = 0
var total_notes: int = 0

var perfect_count: int = 0
var great_count: int = 0
var good_count: int = 0
var miss_count: int = 0

#--------------END----------------
var end_delay: float = 1.5
var element_delay: float = 0.25
var tween_duration: float = 0.5
var pausado=false
var showing_end=false
var _ended := false
var _end_timer := 0.0
@onready var end_ui := $End_UI
@onready var end_score := end_ui.get_node("End_score")

signal acabado
signal cerrar


func _ready() -> void:
	_load_beatmap()
	update_score_display(score)

func _load_beatmap() -> void:
	var file := FileAccess.open(beatmap_file, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir beatmap: " + beatmap_file)
		return

	var text := file.get_as_text()
	var data :Array= JSON.parse_string(text)
	if typeof(data) != TYPE_ARRAY:
		push_error("Formato de beatmap inválido; se esperaba un Array.")
		return

	beatmap = data  # asumes que ya viene ordenado por time
	total_notes = beatmap.size()
	
func _process(delta: float) -> void:
	if showing_end:
		if Input.is_action_just_pressed("ui_accept"):
			showing_end=false
			emit_signal("cerrar")
		return
	if not pausado:
		# Acumulamos el tiempo previo al inicio de la música
		if not MusicManager.has_started:
			MusicManager.pre_lead_time += delta

		# Obtenemos el tiempo sincronizado: usa pre_lead_time si aún no arrancó el audio,
		# o playback_time + pre_lead_time si ya comenzó
		var synced_time :float = MusicManager.get_synced_time()
		#print("t=" + str(synced_time))
		# Spawneamos todas las notas cuya hora sea menor al tiempo actual
		while next_index < beatmap.size() and beatmap[next_index].time <= synced_time:
			var entry: Dictionary = beatmap[next_index]
			_spawn_note(entry.key, entry.time)
			next_index += 1

		# Si aún no comenzó la música y ya pasamos el tiempo de lead, la iniciamos
		if not MusicManager.has_started and MusicManager.pre_lead_time > MusicManager.lead_time:
			INPUT_OFFSET = MusicManager.lead_time - MusicManager.pre_lead_time
			print(INPUT_OFFSET)
			MusicManager.play_music(load("res://0_pruebas/ph_music.ogg"), 0)
			
		if not _ended and next_index >= beatmap.size() and _all_notes_cleared():
			_ended = true
			_end_timer = 0.0
			
		if _ended:
			_end_timer += delta
			if _end_timer >= end_delay:
				_ended = false  # evitar reinicio
				pausado = true
				$Score_UI.queue_free()
				$Combo_UI.queue_free()
				$NotasLimits.queue_free()
				emit_signal("acabado")
				_show_end_results()

func _all_notes_cleared() -> bool:
	for lst in active_notes.values():
		if lst.size() > 0:
			return false
	return true
	
func _show_end_results() -> void:
	end_ui.visible = true
	MusicManager.stop_music()

	# Lista de tuplas: nodo path y valor final
	var results = [
		["Perfecto","[wave amp=60 freq=5][rainbow freq=1 sat=-8 val=0.65 speed=0.5]PERFECTO![/rainbow][/wave]:",perfect_count],
		["Genial","[wave amp=30 freq=4][color=orange]Genial![/color][/wave]:", great_count],
		["Bien","[wave amp=20 freq=3][color=yellow]Bien![/color][/wave]:", good_count],
		["Error","[wave amp=15 freq=2][color=red]Error![/color][/wave]:", miss_count],
		["MaxCombo","MAX COMBO:", max_combo],
		["Score","Puntaje Final", score*max_combo],  # si también quieres el total final
		]
	
	for i in range(results.size()):
		var path = results[i][0]
		var final_value = results[i][2]
		var label = results[i][1]
		var score_label = end_score.get_node(path).get_node(path+"Label")
		var nums = end_score.get_node(path).get_node(path+"Number")
		# Reseteo antes
		nums.text = "0"
		nums.visible = false
		nums.scale = Vector2(1, 1)
		score_label.text=str(label)
		score_label.visible=false
		score_label.scale = Vector2(1, 1)
		var t = get_tree().create_tween()
		var t2 =get_tree().create_tween()
		# 1) Delay escalonado
		t.tween_interval(i * element_delay)
		t2.tween_interval(i * element_delay)
		# 2) Mostrar label
		t.tween_callback(score_label.show)
		t2.tween_callback(nums.show)
		t.bind_node(score_label)
		t2.bind_node(nums)
		# 3) Tween numérico incremental desde 0 hasta final_value

		# 4) Pulso de escala
		t.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.tween_property(score_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		t2.tween_method(
			func(v): nums.text = str(int(v)),
			0, final_value,
			tween_duration
		)
		# 4) Pulso de escala
		t2.tween_property(nums, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t2.tween_property(nums, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await t2.finished
	showing_end=true
		
func _spawn_note(key: String, spawn_time: float) -> void:
	var note := spawn_scene.instantiate()
	note.position.y=-64
	note.scale=Vector2(2,2)
	note.key = key
	note.spawn_time = spawn_time
	note.connect("missed",_on_miss)
	add_child(note)
	active_notes[key].append(note)

func _input(event) -> void:
	for key in active_notes.keys():
		if event.is_action_pressed(key):
			_try_hit(key)

func _try_hit(key: String) -> void:
	var notes_list  = active_notes[key]
	if notes_list.is_empty():
		return

	var best_note = null
	var best_diff := INF
	var current_time := MusicManager.get_synced_time() + INPUT_OFFSET
	
	for note in notes_list:
		
		if !is_instance_valid(note):
			continue

		var diff :float = abs(current_time - note.spawn_time - MusicManager.pre_lead_time)

		if abs(diff) > 0.25:
			continue
		if diff < best_diff:
			best_diff = diff
			best_note = note
	
	if best_note == null:
		return

	if best_diff <= PERFECT_WINDOW:
		_on_hit(best_note, "Perfect")
	elif best_diff <= GREAT_WINDOW:
		_on_hit(best_note, "Great")
	elif best_diff <= GOOD_WINDOW:
		_on_hit(best_note, "Good")
	else:
		_on_miss(best_note)


func _on_hit(note, rating: String) -> void:
	note.activa = false
	active_notes[note.key].erase(note)
	var hit = note.get_node("NotasHit")
	var m := get_multiplier(combo)
	var gained := 0

	match rating:
		"Perfect":
			note.frame += 8
			hit.frame = 30
			gained = m * m * 300
			perfect_count += 1
			show_reaction("Perfecto!")

		"Great":
			note.frame += 4
			hit.frame = 29
			gained = m * m * 200
			great_count += 1
			show_reaction("Genial!")
		"Good":
			note.frame += 4
			hit.frame = 29
			gained = m * 100
			good_count += 1
			show_reaction("Bien!")

	# Combo sube siempre salvo por Miss (que está fuera de esta función)
	combo += 1
	if combo > max_combo:
		max_combo = combo
	
	score += gained
	update_score_display(score)
	update_combo_display(combo)
	
	note.get_node("AnimationPlayer").play("pop")
	print("Hit:", rating, "→ +" + str(gained), " Score:", score, " Combo:", combo)

func _on_miss(note) -> void:
	show_reaction("Error!")

	print("spawn:"+str(note.spawn_time )+ "y el current" + str(MusicManager.get_synced_time()- MusicManager.lead_time))
	note.activa = false
	active_notes[note.key].erase(note)
	var hit = note.get_node("NotasHit")
	note.frame += 12
	hit.frame = 31
	miss_count += 1
	combo = 0
	animate_combo_lost()
	update_score_display(score)
	update_combo_display(combo)
	note.get_node("AnimationPlayer").play("pop")
	print("Miss → Combo reset")
	
func get_multiplier(combo_count: int) -> int:
	return max(combo_count / 4, 1)

func update_combo_display(combow: int) -> void:
	var root := $Combo_UI
	var label_top := root.get_node("Combo_label")
	var label_number := root.get_node("COMBO_x_number")

	var base_rot := 18.0
	var threshold := 1  # mínimo combo visible
	var shows := combow >= threshold

	# Mostrar u ocultar Combo_UI
	root.visible = shows
	if not shows:
		return

	#Actualizar texto y color
	label_number.text = "x " + str(combow)

	var intensity :float = float(combow) / max(total_notes, 1)
	var color := Color(1, 1, 1)  # blanco por defecto

	if intensity > 0.8:
		color = Color(1.0, 0.3, 0.3)  # rojo intenso
	elif intensity > 0.6:
		color = Color(1.0, 0.6, 0.2)  # naranja
	elif intensity > 0.4:
		color = Color(1.0, 1.0, 0.2)  # amarillo
	elif intensity > 0.2:
		color = Color(0.4, 1.0, 0.4)  # verde

	label_top.modulate = color
	label_number.modulate = color

	# Animación de impacto
	label_number.scale = Vector2(1, 1)
	root.rotation_degrees = base_rot

	var t := create_tween()

	# Pulso visual del número
	t.tween_property(label_number, "scale", Vector2(1.2, 1.2), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(label_number, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Pulso de inclinación del grupo
	t.tween_property(root, "rotation_degrees", base_rot + 10.0, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(root, "rotation_degrees", base_rot, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Animación de respiración constante mientras esté activo
	var breathe := get_tree().create_tween().set_loops()
	breathe.tween_property(root, "scale", Vector2(1.05, 1.05), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(root, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.bind_node($Combo_UI)
func animate_combo_lost() -> void:
	var root := $Combo_UI
	if not root.visible:
		return

	var t := create_tween()

	# Color actual con alpha 1
	var current_color = root.modulate
	var fade_color := Color(current_color.r, current_color.g, current_color.b, 0.0)

	t.tween_property(root, "modulate", fade_color, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(root, "scale", Vector2(0.1, 0.1), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	t.finished.connect(func():
		root.visible = false
		root.modulate = Color(current_color.r, current_color.g, current_color.b, 1.0)
		root.scale = Vector2(1.0, 1.0)
	)

		
func update_score_display(new_score: int) -> void:
	var label := $Score_UI/Score_Panel/Score_Label
	var old_score := int(label.text)

	# Tween para animar número
	var tweenex := create_tween()
	tweenex.tween_method(
		func(v): label.text = str(v),
		old_score,
		new_score,
		0.5
	)

	# Tween para escala: pulso suave
	label.scale = Vector2(1, 1)  # aseguramos que parta en escala normal

	tweenex.tween_property(label, "scale", Vector2(1.25, 1.25), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tweenex.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func show_reaction(text: String) -> void:
	var label := $React_label
	label.visible = true
	label.scale = Vector2(1.0, 1.0)
	label.modulate = Color.WHITE
	label.text = ""  # limpio antes de asignar nuevo contenido
	label.bbcode_enabled = true

	# Estilos dinámicos por tipo
	match text:
		"Perfecto!":
			label.bbcode_text = "[wave amp=60 freq=5][rainbow freq=1 sat=-8 val=0.65 speed=0.5]PERFECTO![/rainbow][/wave]"
		"Genial!":
			label.bbcode_text = "[wave amp=30 freq=4][color=orange]Genial![/color][/wave]"
		"Bien!":
			label.bbcode_text = "[wave amp=20 freq=3][color=yellow]Bien![/color][/wave]"
		"Error!":
			label.bbcode_text = "[wave amp=15 freq=2][color=red]Error![/color][/wave]"

	# Tween de animación (escala + fade-out)
	var t := get_tree().create_tween()
	t.tween_property(label, "scale", Vector2(1.25, 1.25), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.6)
	t.tween_property(label, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.finished.connect(func():
		label.visible = false
		label.scale = Vector2(1.0, 1.0)
		label.modulate = Color(1, 1, 1, 1)
	)
