class_name ItemBloodEdge

extends Item

const NAME = "Blood Edge"
const ICON_SLOT = Vector2(5, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_life_steal_percent(0.25)
	_ITEMS[NAME].buy_price = 2500
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_percent(0.25) + " life steal."
	_ITEMS[NAME].es_description = "Otorga un " + StringHelpers.format_percent(0.25) + " de robo de vida."
