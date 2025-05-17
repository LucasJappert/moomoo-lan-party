class_name Moomoo

extends Entity

func _ready():
	super._ready()
	name = "Moomoo"
	global_position = AStarGridManager.cell_to_world(Vector2i(20, 11))
	pass
