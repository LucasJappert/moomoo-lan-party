class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)
const RECTS: Array[Rect2] = [Rect2(512, 864, 128, 128), Rect2(640, 864, 128, 128)]
const BODY_SCALE: float = 0.7

func _ready():
	super._ready()

# region 	GETTERs
# endregion GETTERs

static func get_instance() -> Moomoo:
	var moomoo: Moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	moomoo.name = "Moomoo"
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	moomoo.combat_stats.set_hp(10000)
	moomoo.set_current_hp_and_mana()
	
	return moomoo
