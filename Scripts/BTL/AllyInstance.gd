extends Control

signal hp_changed(new_hp,node)
signal died(node)

# Identificador del personaje, para obtener datos estáticos
var character_id: String = ""

# Datos dinámicos de batalla
var current_hp: int
var max_hp: int
var estados := []  # Array de strings con estados alterados
var rip=false

var time =0
func _ready():
	if character_id == "":
		push_error("AllyInstance necesita character_id asignado antes de _ready()")
		return
	
	# Obtener stats básicos de PartyData
	var data = PartyData.characters.get(character_id, null)
	if data == null:
		push_error("Personaje no encontrado en PartyData: " + character_id)
		return
	
	max_hp = data.stats.max_hp
	current_hp = max_hp

	$Vida.value=max_hp
	$Vida.max_value=max_hp
	
	
func _physics_process(delta: float) -> void:
	$Vida/Label.text="HP:"+str(int($Vida.value))+"/"+str(max_hp)
	time +=delta
	if time >5:
		recibir_dano(10)
		time =0
		
func recibir_dano(amount: int):
	current_hp = max(current_hp - amount, 0)
	emit_signal("hp_changed", current_hp, self)
	
	if current_hp <= 0:
		emit_signal("died",self)

func curar(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("hp_changed", current_hp)

func agregar_estado(estado: String):
	if estado in estados:
		return
	estados.append(estado)
	# aquí puedes agregar lógica de efectos inmediatos

func remover_estado(estado: String):
	if estado in estados:
		estados.erase(estado)
