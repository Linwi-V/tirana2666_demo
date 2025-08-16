extends Node

# Personajes jugables activos (orden importa para los turnos)
var active_party := ["Mónica"] 
var party_level := 1
var dinero:int=200
# Personajes disponibles en el juego
var characters := {
	"Fortunato": {

		"textura": "res://Assets/PARTY/BTL/Fortunato/FortunatoNormal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Fortunato/FortunatoDaño.png",
		"stats": {
			"max_hp": 50,
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
			"golpe": {
				"nombre": "Golpetazo Chi",
				"desbloqueado": true,
				"costo": 4,
				"daño": 50,
				"tipo": "hielo",
				"targets": "enemy",
				"style":"fisico",
				"inflinge": "",
				"descripcion": "Golpe Tai CHi jasjajs",
			},
		}
	},
	"Mónica": {
		
		"textura": "res://Assets/PARTY/BTL/Monica/MonicaNormal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Monica/MonicaNormal.png",
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 0,
			"critico": 0,
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
	"Katari": {
		
		"textura": "res://Assets/PARTY/BTL/Katari/KatariNormal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Katari/KatariDaño.png",
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 0,
			"critico": 0,
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
				"desbloqueado": false,
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
	"Gemelo 1": {
		
		"textura": "res://Assets/PARTY/BTL/Gemelo1/Gemelo1Normal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Gemelo1/Gemelo1Daño.png",
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 0,
			"critico": 0,
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
				"desbloqueado": false,
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
	"Gemelo 2": {
		
		"textura": "res://Assets/PARTY/BTL/Gemelo2/Gemelo2Normal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Gemelo2/Gemelo2Daño.png",
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 0,
			"critico": 0,
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
				"desbloqueado": false,
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
	"Casimiro": {
		
		"textura": "res://Assets/PARTY/BTL/Casimiro/CasimiroNormal.png",
		"textura_daño": "res://Assets/PARTY/BTL/Casimiro/CasimiroNormal.png",	
		"stats": {
			"max_hp": 100,
			"ataque_fisico": 12,
			"defensa_fisica": 8,
			"ataque_magico": 12,
			"defensa_magica": 8,
			"evasion": 0,
			"critico": 0,
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
				"desbloqueado": false,
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




var inventario = {
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
	"aji en salsa": {
		"nombre": "Ají en Salsa",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Salsa picante tradicional.",
		"inflinge": "",
		"usable": false
	},
	"cilantro": {
		"nombre": "Cilantro",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Hierba aromática fresca.",
		"inflinge": "",
		"usable": false
	},
	"aji verde": {
		"nombre": "Ají Verde",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Ají verde fresco y picante.",
		"inflinge": "",
		"usable": false
	},
	"merken": {
		"nombre": "Merkén",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Condimento ahumado típico de Chile.",
		"inflinge": "",
		"usable": false
	},
	"paprika": {
		"nombre": "Paprika",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Especia roja y aromática.",
		"inflinge": "",
		"usable": false
	},
	"pimenton": {
		"nombre": "Pimentón",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Pimiento dulce y colorido.",
		"inflinge": "",
		"usable": false
	},
	"perejil": {
		"nombre": "Perejil",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Hierba verde y fresca.",
		"inflinge": "",
		"usable": false
	},
	"ciboulette": {
		"nombre": "Ciboulette",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Cebollín fino y aromático.",
		"inflinge": "",
		"usable": false
	},
	"acelga": {
		"nombre": "Acelga",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Verdura de hojas verdes.",
		"inflinge": "",
		"usable": false
	},
	"espinaca": {
		"nombre": "Espinaca",
		"textura": "",
		"cantidad": 0,
		"daño": 0,
		"targets": "",
		"tipo": "",
		"descripcion": "Rica en hierro y vitaminas.",
		"inflinge": "",
		"usable": false
	}
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
