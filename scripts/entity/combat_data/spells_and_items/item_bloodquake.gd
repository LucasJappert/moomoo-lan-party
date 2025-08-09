class_name ItemBloodQuake
extends Item

const NAME = "Bloodquake"
const ICON_SLOT = Vector2(6, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(
		_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x,
		_ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y,
		FRAME_SIZE, FRAME_SIZE
	)
	_ITEMS[NAME].set_life_steal_percent(0.4)
	_ITEMS[NAME].set_stun_chance(0.2, 2)
	_ITEMS[NAME].set_physical_attack_power(200)
	_ITEMS[NAME].set_magic_attack_power(200)
	_ITEMS[NAME].buy_price = 12500
	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_percent(_ITEMS[NAME].get_life_steal_percent()) + " life steal, " + StringHelpers.format_percent(_ITEMS[NAME].get_stun_chance()) + " stun chance for " + str(_ITEMS[NAME].get_stun_duration()) + " seconds, and " + str(_ITEMS[NAME].get_physical_attack_power()) + " physical and magic attack."
	_ITEMS[NAME].es_description = "Otorga un " + StringHelpers.format_percent(_ITEMS[NAME].get_life_steal_percent()) + " de robo de vida, un " + StringHelpers.format_percent(_ITEMS[NAME].get_stun_chance()) + " de probabilidad de aturdir por " + str(_ITEMS[NAME].get_stun_duration()) + " segundos, y " + str(_ITEMS[NAME].get_physical_attack_power()) + " de ataque físico y mágico."
