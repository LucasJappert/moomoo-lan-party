class_name CombatData

extends Node

@onready var combat_effect_node = $CombatEffectNode

var stats: CombatStats = CombatStats.new()
@export var current_hp: int = 100
@export var current_mana: int = 100
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = Projectile.TYPES.NONE
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

var last_damage_received_time: int = 0 # In milliseconds
var latest_attacker: Entity

var charged_skill: Skill
var keep_ground: bool = false

func _ready() -> void:
	stats.initialize_default_values() # TODO: Review this... Why dont use get_default_instance()?

	# Initialize items
	_items.clear()
	for i in range(SlotItem.HOTKEY_BY_SLOT.size()): _items.append(SlotItemInfo.new(null, i + 1))

	update_cache_total_stats()

	if multiplayer.is_server() == false:
		set_process(false)

	# Agregamos una señal para cuando se agrega un hijo a combat_effect_node
	combat_effect_node.connect("child_entered_tree", func(p_effect: CombatEffect):
		if !GameManager.MY_PLAYER: return

		update_cache_total_stats()

		if my_owner().is_my_player(): GameManager.my_main.gui_scene.add_effect_to_my_effects(p_effect)

		var target_entity_of_my_player = GameManager.MY_PLAYER.combat_data._target_entity
		if target_entity_of_my_player:
			if target_entity_of_my_player.name == my_owner().name:
				GameManager.my_main.gui_scene.add_effect_to_target_effects(p_effect)
	)

	%CombatEffectSpawner.spawn_function = func(effect_data: Dictionary) -> Node:
		return CombatEffect.get_instance_from_dict(effect_data)

func _post_ready() -> void:
	# At the moment, the player is the only entity that has items
	if my_owner() is Player == false: return
	
	if not GameManager.AM_I_HOST: return

	for item in _items:
		my_owner().rpc_handler.send_item_updated(item) # Send items to clients

# TODO: Improve this
func _process(_delta: float):
	if not my_owner(): return

	try_physical_attack(_delta)

	_try_to_add_effect_from_skills()

	_actions_after_1_second(_delta)

# TODO: Review
func _server_execute_physical_damage(_target: Entity) -> void:
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
	if my_owner().multiplayer.is_server() == false: return

	var total_stats = cache_total_stats
	
	if _check_evade(_di, total_stats): return # Evasion verification (only for physical damage)

	_apply_defenses(_di, total_stats)

	CombatEffect.actions_after_effective_hit(_attacker, my_owner(), _di)
	Skill.actions_after_effective_hit(_attacker, my_owner(), _di)

	my_owner().rpc_handler.receive_damage_or_heal(ObjectHelpers.to_dict(_di, true))

	update_current_hp(-_di.total_damage)

# region SETTERs

func update_current_hp(value_to_increase: int, _attacker: Entity = null) -> void:
	if value_to_increase == 0: return
	if current_hp <= 0: return
	
	var exp_by_damage = min(current_hp, abs(value_to_increase)) * 0.25
	current_hp += value_to_increase
	current_hp = clamp(current_hp, 0, get_total_hp())

	_try_to_give_experience_to_players(exp_by_damage) # Give experience when an enemy takes damage
	
	if current_hp <= 0:
		Skill.actions_before_entity_death(my_owner(), _attacker)
		current_hp = 0
		_try_to_give_experience_to_players(Enemy.get_enemy_exp_when_dead()) # Give experience when an enemy dies
		my_owner().rpc_handler.die()

	my_owner().hud.update_health_bar()

func update_current_mana(value_to_increase: int) -> void:
	if value_to_increase == 0: return
	current_mana = clamp(current_mana + value_to_increase, 0, get_total_mana())
	my_owner().hud.update_mana_bar()

func update_base_stats(new_stats: CombatStats) -> void:
	stats = new_stats
	update_cache_total_stats()

func update_item(index: int, slot_item_info: SlotItemInfo) -> void:
	_items[index] = slot_item_info
	update_cache_total_stats() # Update the cache of total stats, which includes items

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

func add_effect(p_effect: CombatEffect) -> void:
	# Should be called only on the server
	var current_stacks = 0
	var matching_effects: Array[CombatEffect] = []

	for effect in get_effects():
		if effect.effect_name == p_effect.effect_name:
			current_stacks += 1
			matching_effects.append(effect)

	if current_stacks >= p_effect.max_stacks:
		if not p_effect.stats.keep_latest_stacks: return

		matching_effects.sort_custom(func(a, b): return a._elapsed > b._elapsed)

		var effects_to_remove = current_stacks - p_effect.max_stacks + 1
		for i in range(effects_to_remove):
			matching_effects[i].delete_effect()
		update_cache_total_stats() # Update the cache of total stats, which includes effects

	%CombatEffectSpawner.spawn(ObjectHelpers.to_dict(p_effect, true))
	p_effect.queue_free()

func _try_to_give_experience_to_players(_exp: int) -> void:
	if not my_owner() is Enemy: return

	for player in GameManager.get_players():
		player.increment_current_exp(max(1, _exp))


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

# region GETTERs
func try_critical_hit(base_value: int) -> int:
	var critical_damage = 0
	var total_stats = cache_total_stats
	if GlobalsEntityHelpers.roll_chance(total_stats.crit_chance):
		critical_damage = base_value * total_stats.crit_multiplier
	return critical_damage

var cache_total_stats: CombatStats = CombatStats.new()
func update_cache_total_stats() -> void:
	cache_total_stats = _get_total_stats()
func _get_total_stats() -> CombatStats:
	# This function returns the total of all stats, including extras from effects and extras from attributes
	var _total_stats := CombatStats.new()
	_total_stats.accumulate_combat_stats(stats.get_total_stats_including_extras_by_attributes())

	_total_stats.accumulate_combat_stats(_get_extra_stats_by_effects().get_total_stats_including_extras_by_attributes())
	_total_stats.accumulate_combat_stats(_get_extra_stats_by_skills().get_total_stats_including_extras_by_attributes())
	_total_stats.accumulate_combat_stats(_get_extra_stats_by_items().get_total_stats_including_extras_by_attributes())

	return _total_stats

func _get_extra_stats_by_effects() -> CombatStats:
	var extra_stats = CombatStats.new()
	for effect in get_effects():
		if effect.stats.apply_stun(): continue # Do not add stun stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(effect.stats)
	return extra_stats

func _get_extra_stats_by_skills() -> CombatStats:
	var extra_stats = CombatStats.new()
	for skill in _skills:
		var learned_skill = skill.get_learned_skill()
		if not learned_skill: continue
		if learned_skill.create_effect: continue
		if learned_skill.stats.apply_stun(): continue # Do not add stun stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(learned_skill.stats)
	return extra_stats

func _get_extra_stats_by_items() -> CombatStats:
	var extra_stats = CombatStats.new()
	for slot_item_info in _items:
		if slot_item_info.is_consumable: continue
		if slot_item_info.item == null: continue
		if slot_item_info.item.type == SkillType.ACTIVE: continue
		if slot_item_info.item.stats.apply_stun(): continue # Do not add stun stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(slot_item_info.item.stats)
	return extra_stats

func get_attack_range() -> int:
	return cache_total_stats.attack_range

# TODO: Improve this get by creating a dictionary to quickly obtain active effects
func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	if not combat_effect_node: return effects

	for child in combat_effect_node.get_children():
		if child is CombatEffect:
			effects.append(child as CombatEffect)
	return effects

func get_effect(effect_name: String) -> CombatEffect:
	for effect in get_effects():
		if effect.effect_name == effect_name: return effect
	return null

func get_effect_by_unique_name(unique_name: String) -> CombatEffect:
	for effect in get_effects():
		if effect.unique_name_node == unique_name: return effect
	return null

func my_owner() -> Entity:
	if _my_owner: return _my_owner
	_my_owner = GlobalsEntityHelpers.get_owner(self)
	return _my_owner

func _check_evade(_di: DamageInfo, total_stats: CombatStats) -> bool:
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

func get_skill_by_index(index: int) -> Skill:
	return _skills[index]

func get_total_hp() -> int:
	return cache_total_stats.hp

func get_total_mana() -> int:
	return cache_total_stats.mana

func is_stunned() -> bool:
	for effect in get_effects():
		if effect.stats.apply_stun(): return true
	return false

func get_target_entity() -> Entity:
	return GameManager.get_entity(target_entity_name)

func get_items() -> Array[SlotItemInfo]:
	return _items
# endregion GETTERs

# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float) -> bool:
	if not my_owner().multiplayer.is_server(): return false

	if my_owner().velocity != Vector2.ZERO: return false
	
	if _target_entity == GameManager.moomoo: set_target_entity(_get_nearest_target_in_range_attack()) # Priorize players over moomoo (only for enemies)

	if _target_entity == null: return false

	if not can_physical_attack(): return false

	_execute_physical_attack()
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

func _execute_physical_attack() -> void:
	if projectile_type == Projectile.TYPES.NONE:
		return _server_execute_physical_damage(_target_entity)

	Projectile.launch(my_owner(), _target_entity, cache_total_stats.physical_attack_power)
		
func can_physical_attack() -> bool:
	if not my_owner().can_attack: return false
	if my_owner().velocity != Vector2.ZERO: return false # If moving, can't attack
	if is_stunned(): return false # If stunned, can't attack

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
		if arrow_attack: SoundManager.play_critical_arrow_shot()
		if melee_attack: SoundManager.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage > 0:
		if melee_attack: SoundManager.play_melee_hit()

	if _di.total_damage < 0: # Heal
		my_owner().hud.show_damage_heal_popup(str(abs(_di.total_damage)), Color(0, 1, 0))
	
	register_attacker(_di.get_attacker())

func _try_to_add_effect_from_skills() -> void:
	if not my_owner() is Player: return
	for skill in _skills:
		if not skill.learned_level: continue
		var skill_base = skill.get_learned_skill()
		if skill_base.type != SkillType.PASSIVE: continue
		if not skill_base.create_effect: continue
		if not skill_base.stats.is_owner_friendly: continue
		if get_effect(skill_base.my_name): continue # Already has this effect

		var new_effect = CombatEffect.get_permanent_effect(skill_base.my_name, skill_base.max_stacks, skill_base.stats)
		new_effect.set_region_rect(skill.region_rect)
		add_effect(new_effect)

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
