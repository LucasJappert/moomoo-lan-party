class_name ItemTrinityBoost
extends Item

const NAME = "Trinity Boost"
const ICON_SLOT = Vector2(4, 1)

static func create_and_add_instance() -> void:
	const STATS := 50
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_attack_speed(0.3)
	_ITEMS[NAME].set_move_speed_percent(0.3)
	_ITEMS[NAME].set_intelligence(STATS)
	_ITEMS[NAME].set_agility(STATS)
	_ITEMS[NAME].set_strength(STATS)
	_ITEMS[NAME].buy_price = 9000
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_percent(_ITEMS[NAME].get_attack_speed()) + " attack speed, " + StringHelpers.format_percent(_ITEMS[NAME].get_move_speed_percent()) + " movement speed, and " + str(STATS) + " points of strength, agility, and intelligence."
	_ITEMS[NAME].es_description = "Otorga un " + StringHelpers.format_percent(_ITEMS[NAME].get_attack_speed()) + " de velocidad de ataque, un " + StringHelpers.format_percent(_ITEMS[NAME].get_move_speed_percent()) + " de velocidad de movimiento y " + str(STATS) + " puntos de fuerza, agilidad e inteligencia."