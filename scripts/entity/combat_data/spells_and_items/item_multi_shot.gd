class_name ItemMultiShot
extends Item

const NAME = "Multi Shot"
const ICON_SLOT = Vector2(10, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME, SkillType.PASSIVE)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_attack_range(50)
	_ITEMS[NAME].add_debuff(CombatStats.DEBUFF_KEY_MELEE_UNITS, CombatStats.ATTACK_RANGE, -50)
	_ITEMS[NAME].set_extra_projectiles(2, 0.5)
	_ITEMS[NAME].add_debuff(CombatStats.DEBUFF_KEY_MELEE_UNITS, CombatStats.EXTRA_PROJECTILES, -2)
	_ITEMS[NAME].buy_price = 3200
	_ITEMS[NAME].description = "Increases attack range and fires 2 extra projectiles. \n (Only applies to ranged units)"
