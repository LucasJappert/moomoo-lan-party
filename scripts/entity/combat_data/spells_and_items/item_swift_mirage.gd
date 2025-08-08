class_name ItemSwiftMirage
extends Item

const NAME = "Swift Mirage"
const ICON_SLOT = Vector2(13, 0)


static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_evasion(0.15)
	_ITEMS[NAME].set_attack_speed(0.15)
	_ITEMS[NAME].set_agility(10)
	_ITEMS[NAME].set_strength(10)
	_ITEMS[NAME].set_intelligence(10)
	_ITEMS[NAME].buy_price = 1600
	_ITEMS[NAME].en_description = "Grants 10 points of strength, agility and intelligence, and " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " evasion and " + StringHelpers.format_percent(_ITEMS[NAME].get_attack_speed()) + " attack speed."
	_ITEMS[NAME].es_description = "Otorga 10 puntos de fuerza, agilidad e inteligencia, y " + StringHelpers.format_percent(_ITEMS[NAME].get_evasion()) + " de evasión y " + StringHelpers.format_percent(_ITEMS[NAME].get_attack_speed()) + " de velocidad de ataque."
