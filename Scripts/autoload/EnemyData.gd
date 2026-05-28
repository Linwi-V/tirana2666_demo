extends Node

# Diccionario de enemigos disponibles
var enemies := {
	"Eterna Ancestral": {
		"nombre": "Eterna Ancestral",
		
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD1/EternaAncestral.PNG",  
		
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
		
		"debilidades": ["rayo"],
		"resistencias": ["fuego"],
		"inmunidades": [],
		"absorciones": [],
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 25,  # daño base
				"tipo": "",
				"estilo": "fisico",
				"target": "party",
				"scripted": -1
			},
			"pocion": {
				"nombre": "Poción",
				"descripcion": "Helea",
				"poder": -10,  # daño base
				"tipo": "",
				"estilo": "magico",
				"target": "self",
				"scripted": 2
			},
		},
		"ai_type": "agresivo",
		"muerte": {
				"scripted": "true",
				"exp": "100",
				"oro": "10"
			},  
	},
	"Esbirro A": {
		"nombre": "Esbirro A",
			
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD2/esbirro1.png",
			
		"stats": {
			"max_hp": 70,
			"ataque_fisico": 1,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 0,
			"evasion": 0,
			"critico": 0,
			"velocidad": 5,  # para orden de ataque de enemigos
		},
			
		"debilidades": ["rayo"],
		"resistencias": ["fuego"],
		"inmunidades": [],
		"absorciones": [],
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 25,  # daño base
				"tipo": "",
				"estilo": "fisico",
				"target": "party",
				"scripted": -1
			},
			"pocion": {
				"nombre": "Poción",
				"descripcion": "Helea",
				"poder": -10,  # daño base
				"tipo": "",
				"estilo": "magico",
				"target": "self",
				"scripted": -1
			},
		},
		"ai_type": "agresivo",
		"muerte": {
			"scripted": "true",
			"exp": "100",
			"oro": "10"
			},
	},
		"Esbirro B": {
		"nombre": "Esbirro B",
			
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD2/esbirro2.png",
			
		"stats": {
			"max_hp": 70,
			"ataque_fisico": 1,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 0,
			"evasion": 0,
			"critico": 0,
			"velocidad": 5,  # para orden de ataque de enemigos
		},
			
		"debilidades": ["rayo"],
		"resistencias": ["fuego"],
		"inmunidades": [],
		"absorciones": [],
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 25,  # daño base
				"tipo": "",
				"estilo": "fisico",
				"target": "party",
				"scripted": -1
			},
			"pocion": {
				"nombre": "Poción",
				"descripcion": "Helea",
				"poder": -10,  # daño base
				"tipo": "",
				"estilo": "magico",
				"target": "self",
				"scripted": -1
			},
		},
		"ai_type": "agresivo",
		"muerte": {
			"scripted": "true",
			"exp": "100",
			"oro": "10"
			},
	},
	"Perro": {
		"nombre": "Perro",
			
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD2/perro1.png",
			
		"stats": {
			"max_hp": 20,
			"ataque_fisico": 1,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 0,
			"evasion": 0,
			"critico": 0,
			"velocidad": 5,  # para orden de ataque de enemigos
		},
			
		"debilidades": ["rayo"],
		"resistencias": ["fuego"],
		"inmunidades": [],
		"absorciones": [],
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 15,  # daño base
				"tipo": "",
				"estilo": "fisico",
				"target": "party",
				"scripted": -1
			},
			"pocion": {
				"nombre": "Poción",
				"descripcion": "Helea",
				"poder": -10,  # daño base
				"tipo": "",
				"estilo": "magico",
				"target": "self",
				"scripted": -1
			},
		},
		"ai_type": "agresivo",
		"muerte": {
			"scripted": "true",
			"exp": "100",
			"oro": "0"
			},
	},
	"Ladrón": {
		"nombre": "Ladrón",
			
		"textura": "res://Assets/ENEMIGOS/BTL/WORLD2/ladrona.png",
			
		"stats": {
			"max_hp": 20,
			"ataque_fisico": 1,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 0,
			"evasion": 0,
			"critico": 0,
			"velocidad": 5,  # para orden de ataque de enemigos
		},
			
		"debilidades": ["rayo"],
		"resistencias": ["fuego"],
		"inmunidades": [],
		"absorciones": [],
		"habilidades": {
			"mordisco": {
				"nombre": "Mordisco",
				"descripcion": "Un ataque simple con los dientes viscosos.",
				"poder": 15,  # daño base
				"tipo": "",
				"estilo": "fisico",
				"target": "party",
				"scripted": -1
			},
			"pocion": {
				"nombre": "Poción",
				"descripcion": "Helea",
				"poder": -10,  # daño base
				"tipo": "",
				"estilo": "magico",
				"target": "self",
				"scripted": -1
			},
		},
		"ai_type": "agresivo",
		"muerte": {
			"scripted": "true",
			"exp": "100",
			"oro": "0"
			},
	},
}
