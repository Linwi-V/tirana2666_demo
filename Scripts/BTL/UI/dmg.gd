extends Label

func show_damage(amount: int, start_pos: Vector2, evaded := false, crit := false, tipo_relacion := "normal") -> void:
	position = start_pos
	scale = Vector2(1,1)

	if evaded:
		text = "¡Fallo!"
		modulate = Color(0.5, 0.5, 0.5, 1)
	elif tipo_relacion == "inmune":
		text = "Inmune"
		modulate = Color(1, 1, 1, 1)
	elif tipo_relacion == "absorbe":
		text = "¡Absorbe!"
		modulate = Color(0, 1, 1, 1)
	elif amount > 0:
		text = "-"+str(amount)

		if crit and tipo_relacion == "debil":
			scale = Vector2(1.2,1.2)
			modulate = Color(1, 0.3, 0, 1) # Naranja fuerte
			text += "\n¡Crítico Débil!"
		elif crit:
			scale = Vector2(1.1,1.1)
			modulate = Color(1, 0, 0, 1)
			text += "\n¡Crítico!"
		elif tipo_relacion == "debil":
			scale = Vector2(1.1,1.1)
			modulate = Color(1, 0.5, 0.2, 1)
			text += "\nDébil"
		elif tipo_relacion == "resistente":
			modulate = Color(1,1,1,1)
	elif amount < 0:
		text = "+"+str(abs(amount))
		modulate = Color(0, 1, 0, 1)
		if crit:
			scale = Vector2(1.1,1.1)
			text += "\n¡Crítico!"
	else:
		text = " 0"
		modulate = Color(0.5, 0.5, 0.5, 1)

	# Tween animación
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 30, 0.7)
	tween.tween_property(self, "modulate:a", 0, 0.7)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished() -> void:
	queue_free()
