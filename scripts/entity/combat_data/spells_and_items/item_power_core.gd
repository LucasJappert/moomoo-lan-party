class_name ItemPowerCore

extends Item

const NAME = "Power Core"
const ICON_SLOT = Vector2(6, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].cast_range_in_tiles = 0
	_ITEMS[NAME].stats.intelligence = 40
	_ITEMS[NAME].stats.strength = 40
	_ITEMS[NAME].stats.agility = 40
	_ITEMS[NAME].buy_price = 2000
	_ITEMS[NAME].description = "Grants 40 points of intelligence, strength and agility."
