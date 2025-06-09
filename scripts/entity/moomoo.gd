class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)

func _ready():
	super._ready()
	GameManager.moomoo = self

# region 	GETTERs
static func get_instance_from_dict(dict: Dictionary) -> Moomoo:
	var instance = get_instance()
	ObjectHelpers.from_dict(instance, dict)
	return instance
# endregion GETTERs

static func get_instance() -> Moomoo:
	var moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	moomoo.name = "Moomoo"
	moomoo.combat_data.base_hp = 1000000
	moomoo.combat_data.current_hp = moomoo.combat_data.get_total_hp()
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	return moomoo
