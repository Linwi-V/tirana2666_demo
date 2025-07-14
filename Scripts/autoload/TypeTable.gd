extends Node

# Multiplicadores estándar
const DEBIL_MULT := 1.25
const RESIST_MULT := 0.75
const NORMAL_MULT := 1.0
const INMUNE_MULT := 0.0
const ABSORBE_MULT := -1.0

func get_damage_modifier(type_data: Dictionary, attack_type: String) -> float:
	if "inmunidades" in type_data and attack_type in type_data["inmunidades"]:
		return INMUNE_MULT
	if "absorciones" in type_data and attack_type in type_data["absorciones"]:
		return ABSORBE_MULT
	if "debilidades" in type_data and attack_type in type_data["debilidades"]:
		return DEBIL_MULT
	if "resistencias" in type_data and attack_type in type_data["resistencias"]:
		return RESIST_MULT
	
	return NORMAL_MULT
