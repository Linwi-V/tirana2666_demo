extends Node

# Personajes jugables activos (orden importa para los turnos)
var active_party := ["Mónica","Mónica"] 
var party_level := 1

# Personajes disponibles en el juego
var characters := {
	"Mónica": {
		
		"textura": "res://Assets/PARTY/BTL/monica_ph.png",
		
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 12,
			"critico": 8,
			"medidor": 0,
			"puntos_habilidad_innato": 0
		},
		
		"debilidades": ["fuego"],
		
		"resistencias": ["rayo"],
		
		"habilidades": {
			"disparo": {
				"nombre": "Disparo",
				"desbloqueado": true,
				"costo": 3,
				"tipo": "rayo",
				"descripcion": "Dispara."
			},
		}
	},
}
