extends Node

# Squad tracking
var player_squads = []
var enemy_squads = []
var defeated_enemy_ids = []

# Battle data - passed between overworld and battle
var active_player_squad = null
var active_enemy_squad = null
var active_enemy_id = -1

# Unit stats template
func make_unit(unit_name: String, hp: int, strength: int, defense: int, spd: int, mov: int) -> Dictionary:
	return {
		"name": unit_name,
		"hp": hp,
		"max_hp": hp,
		"str": strength,
		"def": defense,
		"spd": spd,
		"mov": mov
	}

# Default player unit
func default_player_unit() -> Dictionary:
	return make_unit("Soldier", 30, 8, 4, 10, 4)

# Default enemy unit
func default_enemy_unit() -> Dictionary:
	return make_unit("Enemy", 25, 6, 3, 7, 3)
