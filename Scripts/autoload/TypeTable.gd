extends Node

# Multiplicadores estándar
const DEBIL_MULT := 1.25
const RESIST_MULT := 0.75
const NORMAL_MULT := 1.0
const INMUNE_MULT := 0.0
const ABSORBE_MULT := -1.0

# type_data es una lista: [{ "debilidades": [...], "resistencias": [...], "inmunidades": [...], "absorciones": [...] }]
func get_damage_modifier(type_data: Array, attack_type: String) -> float:
	for table in type_data:
		if "inmunidades" in table and attack_type in table["inmunidades"]:
			return INMUNE_MULT
		if "absorciones" in table and attack_type in table["absorciones"]:
			return ABSORBE_MULT
		if "debilidades" in table and attack_type in table["debilidades"]:
			return DEBIL_MULT
		if "resistencias" in table and attack_type in table["resistencias"]:
			return RESIST_MULT
	
	return NORMAL_MULT
