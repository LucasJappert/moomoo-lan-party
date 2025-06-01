class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)

func _ready():
	super._ready()
	name = "Moomoo"
	combat_data.max_hp = 1000000
	combat_data.current_hp = combat_data.max_hp
	global_position = MapManager.cell_to_world(SPAWN_POSITION)
	pass
