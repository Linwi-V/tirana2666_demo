extends Node

# Diccionario de enemigos disponibles
var enemies := {
	"Eterna Ancestral": {
		"nombre": "Eterna Ancestral",
		
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD1/ea_ph.png",  
		
		"stats": {
			"max_hp": 50,
			"ataque_fisico": 10,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 2,
			"evasion": 0,
			"critico": 0,
			"velocidad": 5,  # para orden de ataque de enemigos
		},
		
		"debilidades": ["hielo"],
		"resistencias": ["fuego"],
		
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 10,  # daño base
				"tipo": "fisico"
			},
		},
		"ai_type": "agresivo"  
	},
	
}
