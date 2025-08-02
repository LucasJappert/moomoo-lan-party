class_name ItemGhostplume
extends Item

const NAME = "Ghostplume"
const ICON_SLOT = Vector2(9, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_intelligence(5)
	_ITEMS[NAME].set_agility(15)
	_ITEMS[NAME].set_strength(5)
	_ITEMS[NAME].buy_price = 600
	_ITEMS[NAME].description = "Grants 15 points of agility, 5 points of intelligence and 5 points of strength."