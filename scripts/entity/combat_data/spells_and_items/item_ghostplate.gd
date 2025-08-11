class_name ItemGhostplate
extends Item

const NAME = "Ghostplate"
const ICON_SLOT = Vector2(3, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_magic_defense_points(80)
	_ITEMS[NAME].set_physical_defense_points(80)
	_ITEMS[NAME].set_evasion(0.2)
	_ITEMS[NAME].buy_price = 1900
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_float(_ITEMS[NAME].get_magic_defense_points()) + " magic and physical defense points, and " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " evasion."
	_ITEMS[NAME].es_description = "Otorga " + StringHelpers.format_float(_ITEMS[NAME].get_magic_defense_points()) + " puntos de defensa mágica y física, y " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " de evasión."
