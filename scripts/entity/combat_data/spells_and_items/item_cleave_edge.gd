class_name ItemCleaveEdge

extends Item

const NAME = "Cleave Edge"
const ICON_SLOT = Vector2(4, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = ItemCleaveEdge.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].max_stacks = 6
	_ITEMS[NAME].set_cleave_percent(0.3)
	_ITEMS[NAME].set_cleave_range(2)
	_ITEMS[NAME].buy_price = 3300
	_ITEMS[NAME].description = "Grants a " + StringHelpers.format_percent(_ITEMS[NAME].get_cleave_percent()) + " extra damage to enemies around " + str(_ITEMS[NAME].get_cleave_range()) + " tiles."
