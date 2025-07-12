extends Node

@export var Enemy : PackedScene
@export var Ally : PackedScene


func _ready() -> void:
	$Background.texture = load(WorldFunc.BTL_BG)
	
	for chars in WorldFunc.Party_BTL:#crea aliados
		var new_ally = Ally.instantiate()
		var retrato = new_ally.get_node("Ally")
		retrato.texture = load(PartyData.characters[chars]["textura"])
		get_node("UI/AllyContainers").add_child(new_ally)
		
	for i in WorldFunc.Enemy_BTL.size():#crea enemigos
		var chars = WorldFunc.Enemy_BTL[i]
		var new_enemy = Enemy.instantiate()
		var retrato = new_enemy.get_node("Enemy")
		retrato.texture = load(EnemyData.enemies[chars]["textura"])
		if i <3:
			get_node("Enemies/EnemyContainersFront").add_child(new_enemy)
		else:
			get_node("Enemies/EnemyContainersBack").add_child(new_enemy)
			if WorldFunc.Enemy_BTL.size() ==4:
				var dummy = Control.new()
				get_node("Enemies/EnemyContainersBack").add_child(dummy)
	
	
