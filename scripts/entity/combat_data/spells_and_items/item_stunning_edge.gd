class_name ItemStunningEdge
extends Item

const NAME = "Stunning Edge"
const ICON_SLOT = Vector2(3, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME, SkillType.PASSIVE)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_stun_chance(1, 2)
	_ITEMS[NAME].set_physical_attack_power(10)
	_ITEMS[NAME].add_debuff(CombatStats.DEBUFF_KEY_RANGED_UNITS, CombatStats.STUN_CHANCE, -0.5)
	_ITEMS[NAME].buy_price = 1400
	_ITEMS[NAME].description = "Grants a 20% (10% for ranged attacks) chance to stun the target for 2 seconds."
