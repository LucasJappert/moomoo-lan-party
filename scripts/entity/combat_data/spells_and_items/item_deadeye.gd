class_name ItemDeadeye
extends Item

const NAME = "Deadeye"
const ICON_SLOT = Vector2(9, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_chance_to_ignore_evasion(1)
	_ITEMS[NAME].set_attack_speed_percent(1)
	_ITEMS[NAME].set_intelligence(100)
	_ITEMS[NAME].set_physical_attack_power(60)
	_ITEMS[NAME].buy_price = 8500

	var chance := StringHelpers.format_percent(_ITEMS[NAME].get_chance_to_ignore_evasion())
	var atk_spd := StringHelpers.format_percent(_ITEMS[NAME].get_attack_speed())
	var intel := str(_ITEMS[NAME].get_intelligence())
	var patk := str(_ITEMS[NAME].get_physical_attack_power())

	_ITEMS[NAME].en_description = "Grants " + chance + " chance to ignore the target's evasion. Also grants " + atk_spd + " attack speed, +" + intel + " Intelligence, and +" + patk + " Physical Attack Power."
	_ITEMS[NAME].es_description = "Otorga un " + chance + " de probabilidad de ignorar la evasión del objetivo. Además otorga " + atk_spd + " de velocidad de ataque, +" + intel + " de Inteligencia y +" + patk + " de Poder de Ataque Físico."
