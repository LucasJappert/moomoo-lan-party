class_name ItemStunningEdge
extends Item

const NAME = "Stunning Edge"
const ICON_SLOT = Vector2(3, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME, SkillType.PASSIVE)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_stun_chance(0.2, 2)
	_ITEMS[NAME].set_physical_attack_power(25)
	_ITEMS[NAME].add_debuff(CombatStats.DEBUFF_KEY_RANGED_UNITS, CombatStats.STUN_CHANCE, -0.1)
	_ITEMS[NAME].buy_price = 1400
	var changes_for_ranged = - _ITEMS[NAME].get_debuff(CombatStats.STUN_CHANCE)
	_ITEMS[NAME].en_description = "Grants a " + StringHelpers.format_percent(_ITEMS[NAME].get_stun_chance()) + " (" + StringHelpers.format_percent(changes_for_ranged) + " for ranged attacks) chance to stun the target for " + str(_ITEMS[NAME].get_stun_duration()) + " seconds."
	_ITEMS[NAME].es_description = "Otorga una probabilidad de " + StringHelpers.format_percent(_ITEMS[NAME].get_stun_chance()) + " de aturdir al objetivo por " + str(_ITEMS[NAME].get_stun_duration()) + " segundos (" + StringHelpers.format_percent(changes_for_ranged) + " para ataques a distancia)."
