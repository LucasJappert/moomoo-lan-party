class_name ItemCryoBlade
extends Item

const NAME = "Cryo blade"
const ICON_SLOT = Vector2(10, 1)


static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_crit_chance(0.20, 5)
	_ITEMS[NAME].set_physical_attack_power(100)
	_ITEMS[NAME].set_freeze_duration(4)
	_ITEMS[NAME].duration_in_seconds = 4
	_ITEMS[NAME].set_attack_speed_percent(-0.1)
	_ITEMS[NAME].set_move_speed_percent(-0.1)
	_ITEMS[NAME].set_intelligence(50)
	_ITEMS[NAME].set_agility(50)
	_ITEMS[NAME].set_strength(50)

	_ITEMS[NAME].target_to_enemy = true
	_ITEMS[NAME].max_stacks = 5
	_ITEMS[NAME].buy_price = 15500

	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_chance()) + " Critical Strike chance. On hit, freezes the target for " + StringHelpers.format_float(_ITEMS[NAME].get_freeze_duration()) + "seconds and can stack up to " + StringHelpers.format_float(_ITEMS[NAME].max_stacks) + " times."
	_ITEMS[NAME].es_description = "Otorga un " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_chance()) + " de probabilidad de golpe crítico. Al golpear, congela al objetivo durante " + StringHelpers.format_float(_ITEMS[NAME].get_freeze_duration()) + " segundos y puede acumularse hasta " + StringHelpers.format_float(_ITEMS[NAME].max_stacks) + " veces."

static func static_actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if not _di.is_main_attack(): return false
	if _di.damage_type != DamageType.PHYSICAL: return false
	if ObjectHelpers.is_null(_attacker): return false
	var items_in_target := _attacker.get_items_by_name(NAME)
	if items_in_target.is_empty(): return false

	var item := items_in_target[0]
	
	var effect = CombatEffect.get_effect_from_item_skill_base(item, item.region_rect)
	_target.effects_helper.add_effect(effect)
	SoundsHelper.play_random_ice_hit()

	return true
