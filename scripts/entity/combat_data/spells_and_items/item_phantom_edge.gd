class_name ItemPhantomEdge
extends Item

const NAME = "Phantom Edge"
const ICON_SLOT = Vector2(11, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME, SkillType.PASSIVE)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_crit_chance(0.25, 1.5)
	_ITEMS[NAME].set_agility(20)
	_ITEMS[NAME].buy_price = 1900
	_ITEMS[NAME].description = "Grants a " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_chance()) + " chance to crit for " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_multiplier()) + " damage and grants 20 points of agility."