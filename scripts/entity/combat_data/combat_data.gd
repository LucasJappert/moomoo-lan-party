class_name CombatData

extends Node
const EXP_MULTIPLIER: int = 1

var effects_helper: EffectsHelper = EffectsHelper.new()
@export var current_hp: int = 0
@export var current_mana: int = 0
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = Projectile.TYPES.NONE
@export var is_stunned: bool = false
var _skills: Array[Skill] = []
var _items: Array[SlotItemInfo] = [] # We use 6 slots
var _my_owner: Entity

var _1_second_timer: float = 0.0

var _target_entity: Entity #
@export var target_entity_name: String:
	set(value):
		if _target_entity_name == value: return
		_target_entity_name = value
		_target_entity = GameManager.get_entity(value)
		
		EventBus.emit_new_target_selected(GlobalsEntityHelpers.get_owner(self), _target_entity)
		if _target_entity == null: return

	get:
		return _target_entity_name
var _target_entity_name: String = ""

var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity

var last_damage_received_time: int = -1000000 # In milliseconds
var latest_attacker: Entity

var charged_skill: Skill
var keep_ground: bool = false
var enemy_spell_caster: EnemySpellCaster

func _ready() -> void:
	effects_helper.subscribe_to_changes(Callable(self, "update_cache_total_stats"))

	if GameManager.AM_I_HOST == false:
		set_process(false)

	# Initialize items
	_items.clear()
	for i in range(SlotItem.HOTKEY_BY_SLOT.size()): _items.append(SlotItemInfo.new(null, i + 1))

	update_cache_total_stats()

func _post_ready() -> void:
	effects_helper.set_my_owner(_my_owner)

	if not GameManager.AM_I_HOST: return

	current_hp = int(get_total_hp())
	current_mana = int(get_total_mana())

	if my_owner() is Enemy:
		enemy_spell_caster = EnemySpellCaster.new(my_owner())

	for item in _items:
		my_owner().rpc_handler.send_item_updated(item) # Send items to clients

func _process(_delta: float): # Run only when it is the host
	if not my_owner(): return

	effects_helper._process(_delta)

	_process_on_server(_delta)

func _process_on_server(_delta: float):
	if not GameManager.AM_I_HOST: return

	try_physical_attack(_delta)

	_try_to_add_effect_from_skills() # TODO: Try to improve this (maybe using signals)

	_actions_after_1_second(_delta)

	if enemy_spell_caster: enemy_spell_caster._process(_delta)

func server_execute_physical_damage(_target: Entity) -> void:
	if my_owner().multiplayer.is_server() == false: return
	if _target == null: return

	var total_stats = cache_total_stats
	var base_damage = total_stats.physical_attack_power
	base_damage += base_damage * total_stats.physical_attack_power_percent
	
	var critical_damage = try_critical_hit(base_damage)
	var total_damage = base_damage + critical_damage

	var _di = DamageInfo.get_instance()
	_di.total_damage = total_damage
	_di.critical = critical_damage
	_di.projectile_type = projectile_type
	_di.damage_type = DamageType.PHYSICAL
	_di.attacker_name = my_owner().name

	_target.combat_data.server_receive_damage(_di, my_owner())

func server_receive_damage(_di: DamageInfo, _attacker: Entity) -> void:
	if _di.total_damage == 0: return
	if my_owner().multiplayer.is_server() == false: return

	var my_stats = cache_total_stats
	var attacker_stats = _attacker.combat_data.cache_total_stats
	
	var attacker_can_miss := _check_ignore_enemy_evasion(_di, attacker_stats)
	if attacker_can_miss: _di.can_be_evaded = false

	if _check_evade(_di, my_stats): return # Evasion verification (only for physical damage)

	_apply_defenses(_di, my_stats)

	if not _di.was_a_cleave_damage and not _di.was_reflected:
		CombatEffect.actions_after_effective_hit(_attacker, my_owner(), _di)
		Skill.actions_after_effective_hit(_attacker, my_owner(), _di)
		Item.actions_after_effective_hit(_attacker, my_owner(), _di)

	my_owner().rpc_handler.receive_damage_or_heal(ObjectHelpers.to_dict(_di, true))

	update_current_hp(-_di.total_damage, _attacker)

# region SETTERs
func _verify_if_am_i_stunned_after_stats_change() -> void:
	for effect in effects_helper.get_effects():
		if effect.stats.has_hostil_stun_effect():
			is_stunned = true
			return

	is_stunned = false
	AnimationsHelper.try_to_remove_obsolete_stun_animation(my_owner())

func update_current_hp(value_to_increase: int, _attacker: Entity = null) -> void:
	if value_to_increase == 0: return
	if current_hp <= 0: return

	
	var exp_by_damage = min(current_hp, abs(value_to_increase)) * 0.1
	current_hp += value_to_increase
	current_hp = clamp(current_hp, 0, get_total_hp())
	Skill.verify_blood_fury(my_owner())

	if _attacker: _try_to_give_experience_to_players(exp_by_damage) # Give experience when an enemy takes damage
	
	_server_verify_death(_attacker)

	my_owner().hud.update_health_bar()

func _server_verify_death(_attacker: Entity) -> void:
	if current_hp > 0: return

	Skill.actions_before_entity_death(my_owner(), _attacker)
	current_hp = 0
	_try_to_give_experience_to_players(Enemy.get_enemy_exp_when_dead()) # Give experience when an enemy dies
	my_owner().rpc_handler.die()
	_try_to_add_gold_to_players(_attacker)

func _try_to_give_experience_to_players(_exp: int) -> void:
	_exp *= EXP_MULTIPLIER
	if not my_owner() is Enemy: return

	for player in GameManager.get_players():
		player.increment_current_exp(max(1, _exp))

func _try_to_add_gold_to_players(_attacker: Entity) -> void:
	if _attacker is Player == false: return
	
	var base_earned := Player.INITIAL_GOLD * 0.05 * (my_owner()._boss_level + 1)
	var earned_gold := randi_range(int(base_earned * 0.8), int(base_earned * 1.2))
	for player in GameManager.get_players():
		player.increment_current_gold(earned_gold)

func update_current_mana(value_to_increase: int) -> void:
	if value_to_increase == 0: return
	current_mana = clamp(current_mana + value_to_increase, 0, get_total_mana())
	my_owner().hud.update_mana_bar()

func update_base_stats(new_stats: CombatStats) -> void:
	my_owner().combat_stats = new_stats
	update_cache_total_stats()

func update_item(index: int, slot_item_info: SlotItemInfo) -> void:
	_items[index] = slot_item_info
	update_cache_total_stats() # Update the cache of total combat_stats, which includes items

func add_item(_slot_item_info: SlotItemInfo) -> bool:
	if _slot_item_info.position > 0:
		update_item(_slot_item_info.position - 1, _slot_item_info)
		return true

	for i in range(_items.size()):
		if _items[i].item == null:
			_slot_item_info.position = i + 1
			update_item(i, _slot_item_info)
			return true

	return false

func use_item(position: int) -> void: # Called from _on_key_pressed
	if _items[position - 1] == null: return print("No item in slot: ", position)

	_items[position - 1].use_item(my_owner(), null)

func item_updated_by_rpc(slot_item_info: SlotItemInfo) -> void:
	update_item(slot_item_info.position - 1, slot_item_info)
	EventBus.emit_item_updated(my_owner(), slot_item_info, null)

func set_attack_type_according_to_projectile_type() -> void:
	attack_type = AttackTypes.MELEE
	if projectile_type != Projectile.TYPES.NONE:
		attack_type = AttackTypes.RANGED

func remove_effect_by_name(effect_name: String) -> void:
	effects_helper.remove_effect_by_name(effect_name)

func register_attacker(attacker: Entity) -> void:
	latest_attacker = attacker
	last_damage_received_time = Time.get_ticks_msec()

func set_target_entity(_target: Entity) -> void: # Used only by the server
	if _target == _target_entity: return

	target_entity_name = str(_target.name) if _target != null else ""
	_target_entity = _target

func charge_skill(index: int) -> void:
	if not _skills[index].learned_level: return
	if _skills[index].get_learned_skill().type == SkillType.PASSIVE: return
	if not _skills[index].can_use(my_owner()): return

	print("Charging skill: ", _skills[index].get_learned_skill().my_name)
	charged_skill = _skills[index]
func uncharge_skill() -> void:
	charged_skill = null
	print("Uncharging skill")

func upgrade_skill(slot_number: int) -> void:
	_skills[slot_number - 1].try_to_upgrade(_my_owner)
	update_cache_total_stats()

func use_charged_skill() -> void:
	if charged_skill == null: return
	if ObjectHelpers.is_null(_target_entity): return

	charged_skill.use(my_owner(), _target_entity)

	uncharge_skill()

func toogle_keep_ground() -> void:
	keep_ground = not keep_ground
# endregion SETTERs

# region 	PRIVATE GETTERs
func _get_total_stats(include_effects := true) -> CombatStats:
	# This function returns the total of all combat_stats, including extras from effects and extras from attributes
	var _total_stats := CombatStats.new()
	_total_stats.accumulate_combat_stats(my_owner().combat_stats.get_total_stats_including_extras_by_attributes())

	if include_effects: _total_stats.accumulate_combat_stats(_get_extra_stats_by_effects().get_total_stats_including_extras_by_attributes())
	_total_stats.accumulate_combat_stats(_get_extra_stats_by_skills().get_total_stats_including_extras_by_attributes())
	_total_stats.accumulate_combat_stats(_get_extra_stats_by_items().get_total_stats_including_extras_by_attributes())

	return _total_stats

func _get_extra_stats_by_effects() -> CombatStats:
	var extra_stats = CombatStats.new()
	for effect in effects_helper.get_effects():
		if effect.stats.has_hostil_stun_effect(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(effect.stats)
	return extra_stats

func _get_extra_stats_by_skills() -> CombatStats:
	var extra_stats = CombatStats.new()
	for skill in _skills:
		var learned_skill = skill.get_learned_skill()
		if not learned_skill: continue
		if learned_skill.create_effect: continue
		if learned_skill.stats.has_hostil_stun_effect(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(learned_skill.stats)
	return extra_stats

func _get_extra_stats_by_items() -> CombatStats:
	var extra_stats = CombatStats.new()
	for slot_item_info in _items:
		if slot_item_info.is_consumable: continue
		if slot_item_info.item == null: continue
		if slot_item_info.item.type == SkillType.ACTIVE: continue
		if slot_item_info.item.stats.has_hostil_stun_effect(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(slot_item_info.item.stats)
	return extra_stats

func _check_ignore_enemy_evasion(_di: DamageInfo, total_stats: CombatStats) -> bool:
	if _di.damage_type != DamageType.PHYSICAL: return false # Ignore enemy evasion only for physical damage

	return GlobalsEntityHelpers.roll_chance(total_stats.ignore_enemy_evasion_chance)

func _check_evade(_di: DamageInfo, total_stats: CombatStats) -> bool:
	if not _di.can_be_evaded: return false

	if _di.damage_type != DamageType.PHYSICAL: return false # Evasion verification (only for physical damage)

	if not GlobalsEntityHelpers.roll_chance(total_stats.evasion): return false

	# TODO: Crear un helper para enviar mensajes
	var sm = ServerMessage.new("Dodge", Vector3(0, 0.5, 1))
	my_owner().rpc_handler.server_message(ObjectHelpers.to_dict(sm, true))

	return true

func _apply_defenses(_di: DamageInfo, total_stats: CombatStats) -> void:
	var damage_before_defense := _di.total_damage

	if _di.damage_type == DamageType.PHYSICAL:
		var reduced_damage := int(total_stats.physical_defense_percent * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.physical_defense_percent * _di.critical)
		var total_damage: int = _di.total_damage - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage = total_damage

	if _di.damage_type == DamageType.MAGIC:
		var reduced_damage := int(total_stats.magic_defense_percent * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.magic_defense_percent * _di.critical)
		var total_damage: int = _di.total_damage - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage = total_damage
# endregion PRIVATE GETTERs

# region GETTERs
func try_critical_hit(base_value: int) -> int:
	var critical_damage = 0
	var total_stats = cache_total_stats
	if GlobalsEntityHelpers.roll_chance(total_stats.crit_chance):
		critical_damage = base_value * total_stats.crit_multiplier
	return critical_damage

var cache_total_stats: CombatStats = CombatStats.new()
var cache_total_stats_no_effects: CombatStats = CombatStats.new()
func update_cache_total_stats() -> void:
	cache_total_stats = _get_total_stats()
	cache_total_stats_no_effects = _get_total_stats(false)

	_verify_if_am_i_stunned_after_stats_change()

func get_attack_range() -> int:
	return cache_total_stats.attack_range

func my_owner() -> Entity:
	if _my_owner: return _my_owner
	_my_owner = GlobalsEntityHelpers.get_owner(self)
	return _my_owner

func get_skills() -> Array[Skill]:
	return _skills

func get_skill(p_name: String) -> Skill:
	for skill in _skills:
		if not skill.learned_level: continue
		if skill.get_learned_skill().my_name == p_name: return skill
	return null
	
func get_learned_skill(p_name: String) -> ItemSkillBase:
	for skill in _skills:
		if not skill.learned_level: continue
		if not skill.get_learned_skill(): continue
		if skill.get_learned_skill().my_name == p_name: return skill.get_learned_skill()
	return null

func get_total_hp() -> int:
	return cache_total_stats.hp

func get_total_mana() -> int:
	return cache_total_stats.mana

func get_target_entity() -> Entity:
	return GameManager.get_entity(target_entity_name)

func get_items() -> Array[SlotItemInfo]:
	return _items
func get_items_by_name(p_name: String) -> Array[SlotItemInfo]:
	var result: Array[SlotItemInfo] = []
	for slot_item in _items:
		if not slot_item.item: continue
		if slot_item.item.my_name == p_name: result.append(slot_item)
	return result
# endregion GETTERs

# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float) -> bool:
	if not my_owner().multiplayer.is_server(): return false

	if my_owner().current_state != EntityState.StateEnum.IDLE: return false # Cant attack while moving
	
	if _target_entity == GameManager.moomoo: set_target_entity(_get_nearest_target_in_range_attack()) # Priorize players over moomoo (only for enemies)

	if _target_entity == null: return false

	if not can_physical_attack(): return false

	execute_physical_attack()
	last_physical_hit_time = Time.get_ticks_msec()

	return true

func _get_nearest_target_in_range_attack():
	var max_range = cache_total_stats.attack_range
	var start_pos = my_owner().global_position
	if my_owner() is Player:
		return GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_enemies(), max_range)

	if my_owner() is Enemy:
		# First we check if there is a player nearby, then if the moomoo is in attack range
		var nearest_player = GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_players(), max_range)
		if nearest_player: return nearest_player

		if GlobalsEntityHelpers.is_target_in_attack_range(my_owner(), GameManager.moomoo): return GameManager.moomoo

	return null

func execute_physical_attack(apply_extra_actions: bool = true, _custom_target: Entity = null) -> void:
	EntityState.change_to_attack(my_owner())

	var final_target = _custom_target if _custom_target else _target_entity
	if projectile_type == Projectile.TYPES.NONE: server_execute_physical_damage(final_target)
	else: Projectile.launch(my_owner(), final_target, cache_total_stats.physical_attack_power)

	if not apply_extra_actions: return

	Skill.actions_after_execute_physical_attack(my_owner(), _target_entity)
		
func can_physical_attack() -> bool:
	if not my_owner().can_attack: return false
	if my_owner().velocity != Vector2.ZERO: return false # If moving, can't attack
	if is_stunned: return false # If stunned, can't attack

	var now = Time.get_ticks_msec()
	var interval_ms = 1000.0 / cache_total_stats.get_total_attack_speed()
	if now - last_physical_hit_time < interval_ms: return false # If enough time has passed, can attack

	if not GlobalsEntityHelpers.is_target_in_attack_range(my_owner(), _target_entity): return false

	return true
# endregion TRY PHISICAL ATTACK

# region 	SERVER METHODS
func global_receive_damage_or_heal(_di: DamageInfo):
	var melee_attack = _di.projectile_type == Projectile.TYPES.NONE && _di.damage_type == DamageType.PHYSICAL
	var arrow_attack = _di.projectile_type == Projectile.TYPES.ARROW && _di.damage_type == DamageType.PHYSICAL
	if _di.critical > 0:
		my_owner().hud.show_damage_heal_popup(str(- (_di.total_damage - _di.critical)), Color(1, 0, 0))
		my_owner().hud.show_damage_heal_popup(str(-_di.critical), Color(1, 1, 0))
		if arrow_attack: SoundsHelper.play_critical_arrow_shot()
		if melee_attack: SoundsHelper.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage > 0:
		if melee_attack: SoundsHelper.play_melee_hit()

	if _di.total_damage < 0: # Heal
		my_owner().hud.show_damage_heal_popup(str(abs(_di.total_damage)), Color(0, 1, 0))
	
	register_attacker(_di.get_attacker())

func _try_to_add_effect_from_skills() -> void:
	for skill in _skills:
		if not skill.learned_level: continue
		var skill_base = skill.get_learned_skill()
		if skill_base.type != SkillType.PASSIVE: continue
		if not skill_base.create_effect: continue
		if not skill_base.stats.is_owner_friendly: continue
		if effects_helper.get_effect_by_name(skill_base.my_name): continue # Already has this effect

		var new_effect = CombatEffect.get_permanent_effect(skill_base.my_name, skill_base.max_stacks, skill_base.stats)
		new_effect.set_region_rect(skill.region_rect)
		effects_helper.add_effect(new_effect)

func _actions_after_1_second(_delta: float) -> void:
	_1_second_timer += _delta
	if _1_second_timer < 1.0: return

	_1_second_timer = 0.0

	var my_owner_stats: CombatStats = cache_total_stats
	# HP and mana regen
	_apply_hp_regen(my_owner_stats)
	_apply_mana_regen(my_owner_stats)

	# if current_mana < get_total_mana():
	# 	update_current_mana_for_damage(-my_owner_stats.mana_regeneration_points)

func _apply_hp_regen(_stats: CombatStats) -> void:
	if _stats.hp_regeneration_points == 0: return
	if current_hp >= get_total_hp(): return
	
	update_current_hp(_stats.hp_regeneration_points)

func _apply_mana_regen(_stats: CombatStats) -> void:
	if _stats.mana_regeneration_points == 0: return
	if current_mana >= get_total_mana(): return

	update_current_mana(_stats.mana_regeneration_points)
# endregion SERVER METHODS
