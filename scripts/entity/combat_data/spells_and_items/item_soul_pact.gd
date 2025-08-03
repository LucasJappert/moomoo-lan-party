class_name ItemSoulPact
extends Item

const NAME = "Soul Pact"
const ICON_SLOT = Vector2(12, 0)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].damage_type = DamageType.MAGIC
	_ITEMS[NAME].float_dict["damage_per_second"] = 15
	_ITEMS[NAME].duration_in_seconds = 5
	_ITEMS[NAME].max_stacks = 10
	_ITEMS[NAME].buy_price = 1500
	_ITEMS[NAME].description = "Each physical attack invokes a forbidden pact, inflicting Burn or Poison for " + str(_ITEMS[NAME].float_dict["damage_per_second"]) + " magic damage per second over " + str(_ITEMS[NAME].duration_in_seconds) + " seconds (up to " + str(_ITEMS[NAME].max_stacks) + " stacks). No mana is consumed, but the user's soul pays the price—losing " + str(_ITEMS[NAME].float_dict["damage_per_second"]) + " HP with every strike."

# Primero restamos os 15 de hp del atacante (sin importar si el ataque sera evadido, cancelado, o lo que fuera)
static func static_actions_before_execute_physical_attack(_attacker: Entity, _target: Entity) -> void:
	if ObjectHelpers.is_null(_attacker): return
	var items_in_attacker := _attacker.get_items_by_name(NAME)
	if items_in_attacker.is_empty(): return

	for item in items_in_attacker:
		var final_current_hp: int = int(max(1, _attacker.current_hp - item.float_dict["damage_per_second"]))
		var final_damage: int = _attacker.current_hp - final_current_hp
		if final_damage <= 0: return
		_attacker.update_current_hp(-final_damage)
	

# Luego si el ataque llega al destino agregamos el efecto de quemadura (es decir, el target no lo evadió, no lo canceló, etc.)
static func static_actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if not _di.is_main_attack(): return false
	if _di.damage_type != DamageType.PHYSICAL: return false
	var items_in_attacker := _attacker.get_items_by_name(NAME)
	if items_in_attacker.is_empty(): return false

	for item in items_in_attacker:
		var temporal_effect = CombatEffect.get_effect_from_item_skill_base(item, _ITEMS[NAME].region_rect)
		temporal_effect.set_info(item.get_info())
		temporal_effect.set_interval_trigger(1).set_attacker(_attacker).set_target(_target)
		_target.effects_helper.add_effect(temporal_effect)

	return true

static func static_actions_after_interval_trigger(_effect: CombatEffect) -> bool:
	if _effect.effect_name != NAME: return false
	if ObjectHelpers.is_null(_effect.get_target()): return false

	var _di := DamageInfo.new(15, DamageType.MAGIC, _effect.get_attacker_name())
	_di.temporal_damage = true
	_effect.get_target().server_receive_damage(_di, _effect.get_attacker())

	return true
