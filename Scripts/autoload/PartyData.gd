extends Node

# Personajes jugables activos (orden importa para los turnos)
var active_party := ["Mónica"] 
var party_level := 1

# Personajes disponibles en el juego
var characters := {
	"Godot": {
		
		"textura": "res://icon.svg",
		
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 50,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 12,
			"critico": 8,
			"medidor": 0,
			"puntos_habilidad_innato": 3
		},
		
		"equipo": {
			"arma":"",
			"armadura":"",
		},
		
		"debilidades": ["fuego"],
		
		"resistencias": ["rayo"],
		
		"inmunidades": [],
		
		"absorciones": [],
		
		"ataque": {
			"basico": {
				"nombre": "Ataque",
				"desbloqueado": true,
				"costo": 0,
				"daño": 0, # no se agrega daño en basicos, solo stats y equipo
				"tipo": "",
				"inflinge": "",
				"descripcion": "Golpe."
			},
		},
		
		"habilidades": {
			"disparo": {
				"nombre": "Disparo",
				"desbloqueado": true,
				"costo": 3,
				"daño": 15,
				"tipo": "rayo",
				"inflinge": "",
				"descripcion": "Dispara un disparo juajua."
			},
		}
	},
	
	"Mónica": {
		
		"textura": "res://Assets/PARTY/BTL/monica_ph.png",
		
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 12,
			"critico": 95,
			"medidor": 0,
			"puntos_habilidad_innato": 3
		},
		
		"equipo": {
			"arma":"pistola",
			"armadura":"",
		},
		
		"debilidades": ["fuego"],
		
		"resistencias": ["rayo"],
		
		"inmunidades": [],
		
		"absorciones": [],
		
		"ataque": {
			"basico": {
				"nombre": "Ataque",
				"desbloqueado": true,
				"costo": 0,
				"daño": 0, # no se agrega daño en basicos, solo stats y equipo
				"tipo": "",
				"inflinge": "",
				"descripcion": "Golpe."
			},
		},
		"habilidades": {
			"disparo": {
				"nombre": "Disparo",
				"desbloqueado": true,
				"costo": 3,
				"daño": 15,
				"tipo": "rayo",
				"targets": "enemy",
				"style":"fisico",
				"inflinge": "",
				"descripcion": "Dispara un disparo.",
			},
		}
	},
}
var inventario={
	"jugo de banana":{
		"nombre":"Jugo de Banana",
		"textura": "", #nada aun
		"cantidad": 1,
		"daño": -15, #helea
		"targets":"ally", #el target es en party solamente puede ser tambien "all", "all_enemy", "enemy" y "all_ally"
		"tipo":"", #para items q hacen daño y tienen tipo
		"descripcion":"Recupera una pequeña cantidad de HP.",
		"inflinge":"",
		"usable": true #si es q es usable en batalla y aparece ahi o no
	},
	
}
var equipables={
	"pistola":{
		"nombre":"Pistola Laser",
		"textura": "", #nada aun
		"cantidad": 1,
		"equipable_en": ["Mónica","Godot"],
		"equipo":"arma",
		"tipo":"rayo",
		"descripcion":"Pistola Laser Básica.",
		"stats": {
			"max_hp": 0,
			"ataque_fisico": 5,
			"defensa_fisica": 0,
			"ataque_magico": 5,
			"defensa_magica": 0,
			"evasion": 0,
			"critico": 2,
			"medidor": 0,
			"puntos_habilidad_innato": 0
		},
		#agregar eventualmente si inflinge estados y cosas asi
	},
	"chaleco":{
		"nombre":"Chaleco",
		"textura": "", #nada aun
		"cantidad": 0,
		"equipable_en": ["Mónica","Godot"],
		"equipo":"armadura",
		"tipo":"",
		"descripcion":"Protege algo.",
		"stats": {
			"max_hp": 10,
			"ataque_fisico": 0,
			"defensa_fisica": 5,
			"ataque_magico": 0,
			"defensa_magica": 5,
			"evasion": 5,
			"critico": 0,
			"medidor": 0,
			"puntos_habilidad_innato": 0
		},
	},
}
