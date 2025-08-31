class_name ItemCryoBlade
extends Item

const NAME = "Cryo blade"
const ICON_SLOT = Vector2(10, 1)


const _SPEED_REDUCTION_FOR_MELEE := 0.1
const _SPEED_REDUCTION_FOR_RANGED := 0.05
const _FREEZE_DURATION := 4
static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_crit_chance(0.20, 5)
	_ITEMS[NAME].set_physical_attack_power(50)
	_ITEMS[NAME].float_dict["freeze_duration"] = _FREEZE_DURATION
	_ITEMS[NAME].float_dict["attack_speed_percent_reduction_for_melee"] = - _SPEED_REDUCTION_FOR_MELEE
	_ITEMS[NAME].float_dict["move_speed_percent_reduction_for_melee"] = - _SPEED_REDUCTION_FOR_MELEE
	_ITEMS[NAME].float_dict["attack_speed_percent_reduction_for_ranged"] = - _SPEED_REDUCTION_FOR_RANGED
	_ITEMS[NAME].float_dict["move_speed_percent_reduction_for_ranged"] = - _SPEED_REDUCTION_FOR_RANGED
	_ITEMS[NAME].duration_in_seconds = _FREEZE_DURATION
	_ITEMS[NAME].set_intelligence(30)
	_ITEMS[NAME].set_agility(30)
	_ITEMS[NAME].set_strength(30)

	_ITEMS[NAME].target_to_enemy = true
	_ITEMS[NAME].max_stacks = 5
	_ITEMS[NAME].buy_price = 15500

	_ITEMS[NAME].en_description = "Grants " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_chance()) + " Critical Strike chance. On hit, freezes the target for " + StringHelpers.format_float(_ITEMS[NAME].get_freeze_duration()) + " seconds, reducing Attack Speed and Movement Speed by " + StringHelpers.format_percent(_SPEED_REDUCTION_FOR_MELEE) + " (" + StringHelpers.format_percent(_SPEED_REDUCTION_FOR_RANGED) + " for ranged attacks). Can stack up to " + StringHelpers.format_float(_ITEMS[NAME].max_stacks) + " times."

	_ITEMS[NAME].es_description = "Otorga un " + StringHelpers.format_percent(_ITEMS[NAME].get_crit_chance()) + " de probabilidad de golpe crítico. Al golpear, congela al objetivo durante " + StringHelpers.format_float(_ITEMS[NAME].get_freeze_duration()) + " segundos, reduciendo la Velocidad de Ataque y la Velocidad de Movimiento en " + StringHelpers.format_percent(_SPEED_REDUCTION_FOR_MELEE) + " (" + StringHelpers.format_percent(_SPEED_REDUCTION_FOR_RANGED) + " para unidades a distancia). Puede acumularse hasta " + StringHelpers.format_float(_ITEMS[NAME].max_stacks) + " veces."


static func static_actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if not _di.is_main_attack(): return false
	if _di.damage_type != DamageType.PHYSICAL: return false
	if ObjectHelpers.is_null(_attacker): return false
	var items_in_target := _attacker.get_items_by_name(NAME)
	if items_in_target.is_empty(): return false

	var item := items_in_target[0]
	
	var effect_stats := CombatStats.new()
	var attack_speed_percent_reduction = _SPEED_REDUCTION_FOR_MELEE if _attacker.is_melee() else _SPEED_REDUCTION_FOR_RANGED
	effect_stats.set_attack_speed_percent(-attack_speed_percent_reduction)
	effect_stats.set_move_speed_percent(-attack_speed_percent_reduction)
	var effect = CombatEffect.get_temporal_effect(NAME, _FREEZE_DURATION, item.max_stacks, effect_stats.get_info())
	effect.set_region_rect(item.region_rect)
	_target.effects_helper.add_effect(effect)
	SoundsHelper.play_random_ice_hit()

	return true
