class_name Moomoo

extends Entity

func _ready():
	super._ready()
	name = "Moomoo"
	combat_data.max_hp = 10000
	combat_data.current_hp = combat_data.max_hp
	global_position = AStarGridManager.cell_to_world(Vector2i(20, 11))
	pass
