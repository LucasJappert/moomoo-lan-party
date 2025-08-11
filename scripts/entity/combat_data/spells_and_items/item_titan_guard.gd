class_name ItemTitanGuard
extends Item

const NAME = "Titan Guard"
const ICON_SLOT = Vector2(5, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_physical_defense_points(300)
	_ITEMS[NAME].set_magic_defense_points(300)
	_ITEMS[NAME].set_hp(2000)
	_ITEMS[NAME].buy_price = 8500
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_float(_ITEMS[NAME].get_physical_defense_points()) + " physical and magic defense points, and " + str(_ITEMS[NAME].get_hp()) + " HP."
	_ITEMS[NAME].es_description = "Otorga " + StringHelpers.format_float(_ITEMS[NAME].get_physical_defense_points()) + " puntos de defensa física y mágica y " + str(_ITEMS[NAME].get_hp()) + " puntos de vida."
