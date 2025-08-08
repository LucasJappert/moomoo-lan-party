class_name ItemBruteheart
extends Item

const NAME = "Bruteheart"
const ICON_SLOT = Vector2(8, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_intelligence(5)
	_ITEMS[NAME].set_agility(5)
	_ITEMS[NAME].set_strength(15)
	_ITEMS[NAME].buy_price = 400
	_ITEMS[NAME].en_description = "Grants 15 points of strength, 5 points of intelligence and 5 points of agility."
	_ITEMS[NAME].es_description = "Otorga 15 puntos de fuerza, 5 puntos de inteligencia y 5 puntos de agilidad."
