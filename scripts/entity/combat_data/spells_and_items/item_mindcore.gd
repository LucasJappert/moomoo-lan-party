class_name ItemMindcore
extends Item

const NAME = "Mindcore"
const ICON_SLOT = Vector2(7, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_intelligence(15)
	_ITEMS[NAME].set_agility(5)
	_ITEMS[NAME].set_strength(5)
	_ITEMS[NAME].buy_price = 400
	_ITEMS[NAME].en_description = "Grants 15 points of intelligence, 5 points of agility and 5 points of strength."
	_ITEMS[NAME].es_description = "Otorga 15 puntos de inteligencia, 5 puntos de agilidad y 5 puntos de fuerza."
