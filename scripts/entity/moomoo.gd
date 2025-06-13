class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)

func _ready():
	print("🐮 Moomoo ready")
	super._ready()
	combat_data.stats.hp = 1000000
	combat_data.current_hp = combat_data.get_total_hp()
	# GameManager.moomoo = self

# region 	GETTERs
static func get_instance_from_dict(_dict: Dictionary) -> Moomoo:
	var instance = get_instance()
	# ObjectHelpers.from_dict(instance, dict)
	return instance
# endregion GETTERs

static func get_instance() -> Moomoo:
	var moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	# var moomoo = MyMain.MOOMOO_SCENE.instantiate()
	moomoo.name = "Moomoo"
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	return moomoo
