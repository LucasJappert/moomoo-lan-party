class_name CombatData

extends CharacterBody2D

const EXP_MULTIPLIER: int = 1

var _my_owner: Entity = self
var shopping_helper := ShoppingHelper.new(self)
var _active_skills: Array[SkillBase] = []
var effects_helper := EffectsHelper.new()
@export var current_hp: int = 0
@export var current_mana: int = 0
@export var projectile_type: String = ProjectileBase.NONE
@export var is_stunned: bool = false
var is_silenced: bool = false
var _skills: Array[Skill] = []
var _items: Array[Item] = []

var _1_second_timer: float = 0.0

var target_view: Entity
@export var target_view_name: String:
	set(value):
		if _target_view_name == value: return
		_target_view_name = value
		target_view = GameManager.get_entity(value)
		# EventBus.emit_new_target_view_selected(_my_owner, target_view)
	get:
		return _target_view_name
var _target_view_name: String = ""

var target_to_attack: Entity
@export var target_to_attack_name: String:
	set(value):
		if _target_to_attack_name == value: return
		_target_to_attack_name = value

		if target_to_attack and _my_owner.is_my_player():
			ShadersHelper.clear_border_shader(target_to_attack, "target_to_attack")
		target_to_attack = GameManager.get_entity(value)
		
		EventBus.emit_new_target_to_attack_selected(_my_owner, target_to_attack)
		if target_to_attack == null: return
		if target_to_attack.current_hp != 0 and _my_owner.is_my_player():
			ShadersHelper.apply_border_shader(target_to_attack, "target_to_attack", true, Color(1, 0, 0, 0.7))

	get:
		return _target_to_attack_name
var _target_to_attack_name: String = ""

var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity

var last_damage_received_time: int = -1000000 # In milliseconds
var latest_attacker: Entity

var charged_skill: Skill
var keep_ground: bool = false
var enemy_spell_caster: EnemySpellCaster

func _init():
	for i in range(SlotItem.SLOTS_NUMBER):
		_items.append(null)

func ready_combat_data() -> void:
	effects_helper.subscribe_to_changes(Callable(_my_owner, "update_cache_total_stats"))

	update_cache_total_stats()

func post_ready_combat_data() -> void:
	effects_helper.set_my_owner(_my_owner)
	
	# Intentamos agregar skills aprendidos y que son pasivos
	for skill in _skills:
		if not skill: continue
		if not skill.learned_level: continue
		if skill.get_learned_skill().type != SkillType.PASSIVE: continue

		
		for registered_class in SkillBase.REGISTERED_SKILLS:
			registered_class.actions_after_skill_updated(self, skill)
		# add_active_skill(SkillBase.get_permanent_active_skill(skill.get_learned_skill()))

	if not GameManager.AM_I_HOST: return

	if current_hp == 0: current_hp = get_full_health()
	if current_mana == 0: current_mana = get_full_mana()

	# for skill_base in SkillBase.REGISTERED_SKILLS:
	# 	skill_base.actions_on_load_skills(_my_owner, _skills)

	if _my_owner is Enemy:
		enemy_spell_caster = EnemySpellCaster.new(_my_owner)

func process_combat_data(_delta: float): # Run only when it is the host
	if GameManager.main_scene.PAUSED: return
	if not _my_owner: return

	effects_helper.process(_delta)

	_process_on_server(_delta)

func _process_on_server(_delta: float):
	if not GameManager.AM_I_HOST: return

	try_physical_attack(_delta)

	_actions_after_1_second(_delta)

	if enemy_spell_caster: enemy_spell_caster._process(_delta)

	update_active_skills(_delta)

func server_execute_physical_damage(_target: Entity, _extra_projectile: bool) -> void:
	if _my_owner.multiplayer.is_server() == false: return
	if _target == null: return
	if _my_owner.is_spawning: return

	var base_damage := _my_owner.cache_total_stats.get_physical_attack_power()
	
	var critical_damage = try_critical_hit(base_damage)
	var total_damage = base_damage + critical_damage

	var _di = DamageInfo.get_instance()
	_di.is_extra_projectile = _extra_projectile
	_di.total_damage = total_damage
	_di.critical = critical_damage
	_di.projectile_type = projectile_type
	_di.damage_type = DamageType.PHYSICAL
	_di.attacker_name = _my_owner.name
	
	for active_skill in _active_skills:
		active_skill.actions_after_execute_physical_attack(_my_owner, _target, _di)
	
	for registered_item in Item.REGISTERED_ITEMS:
		registered_item.static_actions_after_execute_physical_attack(_my_owner, _target, _di)

	_target.server_receive_damage(_di, _my_owner)

func server_receive_damage(_di: DamageInfo, _attacker: Entity) -> void:
	if _di.total_damage == 0: return
	if _my_owner.multiplayer.is_server() == false: return
	if _my_owner.is_spawning: return

	for registered_skill in SkillBase.REGISTERED_SKILLS:
		# Cancel the damage if the skill cancels damage
		var cancel_damage = registered_skill.actions_before_receive_damage(_attacker, _my_owner, _di)
		if cancel_damage: return

	for active_skill in _active_skills:
		var cancel_damage = active_skill.instance_actions_before_receive_damage(_attacker, _di)
		if cancel_damage: return
	
	for reg in Item.REGISTERED_ITEMS:
		var cancel_damage = reg.static_actions_before_receive_damage(_attacker, _my_owner, _di)
		if cancel_damage: return

	var my_stats = cache_total_stats
	
	ItemSkillBase.roll_true_strike(_attacker, _di)

	if _check_evade(_di, my_stats): return # Evasion verification (only for physical damage)
	
	ItemSkillBase.actions_after_effective_hit(_attacker, _my_owner, _di)

	Statistics.try_register_damage(_attacker, _di)

	_apply_defenses(_di, my_stats)

	ItemSkillBase.static_actions_after_apply_defenses(_attacker, _my_owner, _di)

	if _di.total_damage == _di.critical: return # Case when all damage is critical, but all base damage was evaded by defenses

	for registered_skill in SkillBase.REGISTERED_SKILLS:
		registered_skill.actions_after_effective_hit(_attacker, _my_owner, _di)
		
	for reg in Item.REGISTERED_ITEMS:
		reg.static_actions_after_effective_hit(_attacker, _my_owner, _di)

	global_receive_damage_or_heal(_di)
	Statistics.try_register_received_damage(self, _di)

	update_current_hp(-_di.total_damage, _attacker)

	for active_skill in _active_skills:
		active_skill.on_damage_received(_attacker, _di.total_damage)

# region SETTERs
func update_current_hp(value_to_increase: int, _attacker: Entity = null) -> void:
	if value_to_increase == 0: return
	if current_hp <= 0: return

	current_hp += value_to_increase
	current_hp = clamp(current_hp, 0, get_full_health())

	_actions_after_current_hp_updated(value_to_increase, _attacker)

func update_current_mana(value_to_increase: int) -> void:
	if value_to_increase == 0: return
	current_mana = clamp(current_mana + value_to_increase, 0, cache_total_stats.get_mana())
	_my_owner.hud.update_mana_bar()

func update_active_skills(_delta: float) -> void:
	for i in range(_active_skills.size() - 1, -1, -1):
		_active_skills[i].process_skill(_my_owner, _delta)
		if not _active_skills[i].active:
			_remove_active_skill(_active_skills[i], i)

func _remove_active_skill(_skill: SkillBase, index: int) -> void:
	_active_skills.remove_at(index)

func remove_active_skill_by_name(_skill_name: String) -> void:
	for i in range(_active_skills.size() - 1, -1, -1):
		if _active_skills[i].learned_skill.my_name == _skill_name:
			_remove_active_skill(_active_skills[i], i)

func add_active_skill(_skill: SkillBase) -> bool:
	if _stacks_reached(_skill): return false

	_active_skills.append(_skill)
	_try_to_apply_effect(_skill)
	
	return true

func _stacks_reached(_skill: SkillBase) -> bool:
	var current_stacks := 0
	for active_skill in _active_skills:
		if active_skill.learned_skill.my_name == _skill.learned_skill.my_name:
			current_stacks += 1

	if current_stacks < _skill.learned_skill.max_stacks: return false

	return true
func _try_to_apply_effect(_skill: SkillBase):
	if not _skill.learned_skill.create_effect: return

	var new_effect := CombatEffect.get_effect_from_skill_base(_skill)
	effects_helper.add_effect(new_effect)

func apply_stun(_seconds: float) -> void:
	var _stats = CombatStats.new()
	_stats.set_stun_duration(_seconds)
	var effect = CombatEffect.get_temporal_effect(CombatEffect.STUN_NAME, _seconds, 1, _stats.get_info())
	effects_helper.add_effect(effect)

func set_current_hp_and_mana() -> void:
	update_cache_total_stats()
	current_hp = cache_total_stats.get_hp()
	current_mana = cache_total_stats.get_mana()

func _verify_combat_states_after_stats_change() -> void:
	is_stunned = false
	is_silenced = false

	for effect in effects_helper.get_effects():
		if effect.hostile_stun():
			is_stunned = true
		if effect.hostile_silence():
			is_silenced = true

	if not is_stunned:
		StunEffect.remove_all_from(_my_owner.front_animations_node)

func set_current_hp(value: int) -> void:
	current_hp = value
	_actions_after_current_hp_updated()

func _actions_after_current_hp_updated(value_to_increase: int = 0, _attacker: Entity = null) -> void:
	for registered_skill in SkillBase.REGISTERED_SKILLS:
		registered_skill.actions_after_current_hp_updated(value_to_increase, _my_owner)
	for active_skill in _active_skills:
		active_skill.instance_actions_after_current_hp_updated(value_to_increase, self)

	_my_owner.hud.update_health_bar()
	
	_server_verify_death(_attacker)

	if ObjectHelpers.is_null(_attacker): return

	var percent_hp_lost = abs(value_to_increase) / float(get_full_health())
	var exp_by_damage = Enemy.get_enemy_exp_when_dead() * percent_hp_lost
	if _attacker: _try_to_give_experience_to_players(exp_by_damage) # Give experience when an enemy takes damage

func _server_verify_death(_killed_by: Entity) -> void:
	if current_hp > 0: return

	current_hp = 0

	if ObjectHelpers.valid_instance(_killed_by) and _killed_by.target_to_attack_name == _my_owner.name:
		_killed_by.reset_target_to_attack_from_nearest_enemy()

	_try_to_give_experience_to_players(Enemy.get_enemy_exp_when_dead()) # Give experience when an enemy dies
	_my_owner.global_die(_killed_by)
	_try_to_add_gold_to_players_on_enemy_die(_killed_by)


func _try_to_give_experience_to_players(_exp: int) -> void:
	_exp *= EXP_MULTIPLIER
	if not _my_owner is Enemy: return

	for player in GameManager.get_players():
		player.increment_current_exp(max(1, _exp))

func _try_to_add_gold_to_players_on_enemy_die(_attacker: Entity) -> void:
	if _attacker is Player == false: return
	
	var base_earned := EnemiesWavesController.get_gold_earned_by_enemy() * (_my_owner._boss_level + 1)
	var earned_gold := randi_range(int(base_earned * 0.8), int(base_earned * 1.2))
	for player in GameManager.get_players():
		player.increment_current_gold(earned_gold)

func update_base_stats(new_info: Dictionary[String, float]) -> void:
	_my_owner.combat_stats.set_info(new_info)
	update_cache_total_stats()

func update_item(item: Item, index: int) -> bool:
	if index >= _items.size(): printerr("Index out of range: ", index)

	if item and item.quantity <= 0: item = null
	_items[index] = item

	EventBus.emit_item_updated(_my_owner, item, index + 1)

	update_cache_total_stats()
	return true
		
func add_item(item: Item, index: int = -1) -> bool:
	if index >= 0:
		return update_item(item, index)

	for i in range(SlotItem.SLOTS_NUMBER):
		if _items[i] == null:
			return update_item(item, i)

	return false

func use_item(_slot_number: int) -> void: # Called from _on_key_pressed
	if MainScene.PAUSED or current_hp == 0: return
	if _items[_slot_number - 1] == null: return

	_items[_slot_number - 1].use_item(_slot_number, _my_owner, null)

func remove_effect_by_name(effect_name: String) -> void:
	effects_helper.remove_effect_by_name(effect_name)

func register_attacker(attacker: Entity) -> void:
	latest_attacker = attacker
	last_damage_received_time = Time.get_ticks_msec()
	if attacker and ObjectHelpers.is_my_player(self): attacker.hud.set_last_damage_to_my_player()

func set_target_to_attack(_target: Entity) -> void: # Used only by the server
	if _target == target_to_attack: return

	target_to_attack_name = str(_target.name) if _target else ""

func reset_target_to_attack_from_nearest_enemy() -> void:
	set_target_to_attack(_get_nearest_target_in_range_attack())

func verify_freed_target_to_attack(entity_name: String) -> void:
	if target_to_attack_name == entity_name:
		set_target_to_attack(null)

func set_target_view(_target: Entity) -> void:
	# Not used at the moment
	if _target == target_view: return

	target_view = _target
	target_view_name = str(_target.name) if _target else ""
func verify_freed_target_view(entity_name: String) -> void:
	if target_view_name == entity_name:
		print("Freed target view: ", entity_name)
		set_target_view(null)

func charge_skill(index: int) -> void:
	if MainScene.PAUSED or current_hp == 0: return
	if index >= _skills.size(): return
	if is_silenced: return
	if not _skills[index].learned_level: return
	if _skills[index].get_learned_skill().type == SkillType.PASSIVE: return
	if not _skills[index].can_use(_my_owner): return

	if charged_skill and charged_skill.get_name() == _skills[index].get_name():
		return use_charged_skill(_my_owner)

	charged_skill = _skills[index]
	
	if not charged_skill.get_learned_skill().instant_use: return

	charged_skill.use(_my_owner, _my_owner)

func uncharge_skill() -> bool:
	charged_skill = null
	return true

func upgrade_skill(slot_number: int) -> void:
	_skills[slot_number - 1].try_to_upgrade(_my_owner, slot_number)
	
	var learned_skill := _skills[slot_number - 1].get_learned_skill()
	if learned_skill.type == SkillType.PASSIVE:
		add_active_skill(SkillBase.get_permanent_active_skill(learned_skill))

	update_cache_total_stats()

func use_charged_skill(_target: Entity) -> void:
	if MainScene.PAUSED or current_hp == 0: return
	if not charged_skill: return
	if is_silenced: return uncharge_skill()
	if ObjectHelpers.is_null(_target): return uncharge_skill()
	
	var learned_skill = charged_skill.get_learned_skill()

	# Do not allow the use of damaging skills on oneself
	if learned_skill.apply_to_enemy and _target.name == _my_owner.name: return uncharge_skill()

	# Update the target to attack if the skill is not friendly
	# if not learned_skill.is_owner_friendly1: set_target_to_attack(_target)

	charged_skill.use(_my_owner, _target)

	uncharge_skill()

func toogle_keep_ground() -> void:
	keep_ground = not keep_ground
# endregion SETTERs

# region 	PRIVATE GETTERs
func _get_total_stats(include_effects := true) -> Dictionary[String, float]:
	if not _my_owner: return {}
	# This function returns the total of all combat_stats, including extras from effects and extras from attributes
	var _result: Dictionary[String, float] = _my_owner.combat_stats.get_total_info_including_extras_by_attributes()
	# CombatStats.aux_accumulate(_result, _my_owner.combat_stats.get_total_info_including_extras_by_attributes())

	if include_effects: CombatStats.aux_accumulate(_result, _get_combat_info_by_effects())
	CombatStats.aux_accumulate(_result, _get_combat_info_by_skills())
	CombatStats.aux_accumulate(_result, _get_combat_info_by_items())

	return _result

func _get_combat_info_by_effects() -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	for effect in effects_helper.get_effects():
		if effect.hostile_stun(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		CombatStats.aux_accumulate(result, effect.get_info())
	CombatStats.aux_accumulate(result, CombatStats.get_extra_info_by_attributes(result))
	return result

func _get_combat_info_by_skills() -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	for skill in _skills:
		if not skill: continue
		var learned_skill := skill.get_learned_skill()
		if not learned_skill: continue
		if learned_skill.create_effect: continue
		if learned_skill.hostile_stun(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		CombatStats.aux_accumulate(result, learned_skill.get_info())
	CombatStats.accumulate_extra_info_by_attributes(result)
	return result

func _get_combat_info_by_items() -> Dictionary[String, float]:
	var result: Dictionary[String, float] = {}
	for _item in _items:
		if not _item: continue
		if _item.is_consumable: continue
		if _item.type == SkillType.ACTIVE: continue
		if _item.hostile_stun(): continue # Do not add stun combat_stats if it is an effect that is hostile to the owner
		CombatStats.aux_accumulate(result, _item.get_info())
		CombatStats.aux_accumulate(result, _item.get_debuffs(_my_owner))
	CombatStats.accumulate_extra_info_by_attributes(result)
	return result

func _check_evade(_di: DamageInfo, total_stats: CombatStats) -> bool:
	if not _di.can_be_evaded: return false

	if _di.damage_type != DamageType.PHYSICAL: return false # Evasion verification (only for physical damage)

	if not GlobalsEntityHelpers.roll_chance(total_stats.get_evasion()): return false

	# TODO: Crear un helper para enviar mensajes
	# var sm = ServerMessage.new("Dodge", Vector3(0, 0.5, 1))
	# self.hud.show_popup(sm.message, sm.get_color())

	return true

func _apply_defenses(_di: DamageInfo, total_stats: CombatStats) -> void:
	if _di.was_a_cleave_damage: return
	var damage_before_defense := _di.total_damage

	if _di.damage_type == DamageType.PHYSICAL:
		var reduced_damage := int(total_stats.get_physical_defense_percent() * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.get_physical_defense_percent() * _di.critical)
		var total_damage: int = _di.total_damage - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage = total_damage

	if _di.damage_type == DamageType.MAGIC:
		var reduced_damage := int(total_stats.get_magic_defense_percent() * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.get_magic_defense_percent() * _di.critical)
		var total_damage: int = _di.total_damage - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage = total_damage
# endregion PRIVATE GETTERs

# region GETTERs
func is_dead() -> bool: return current_hp <= 0
func try_critical_hit(base_value: int) -> int:
	if GlobalsEntityHelpers.roll_chance(cache_total_stats.get_crit_chance()):
		return int(base_value * cache_total_stats.get_crit_multiplier())
	return 0

var cache_total_stats := CombatStats.new()
var cache_total_stats_no_effects := CombatStats.new()
func update_cache_total_stats() -> void:
	cache_total_stats.set_info(_get_total_stats())
	cache_total_stats_no_effects.set_info(_get_total_stats(false))

	_verify_combat_states_after_stats_change()


func get_skills() -> Array[Skill]:
	return _skills

func get_skill(p_name: String) -> Skill:
	for skill in _skills:
		if not skill.learned_level: continue
		if skill.get_learned_skill().my_name == p_name: return skill
	return null
	
func get_learned_skill(p_name: String) -> ItemSkillBase:
	for skill in _skills:
		if not skill: continue
		if not skill.learned_level: continue
		if not skill.get_learned_skill(): continue
		if skill.get_learned_skill().my_name == p_name: return skill.get_learned_skill()
	return null

func get_full_health() -> int:
	return cache_total_stats.get_hp()

func get_full_mana() -> int:
	return cache_total_stats.get_mana()

func get_target_entity() -> Entity:
	return GameManager.get_entity(target_to_attack_name)

func get_items() -> Array[Item]:
	return _items
func get_items_by_name(p_name: String) -> Array[Item]:
	var result: Array[Item] = []
	for _item in _items:
		if not _item: continue
		if _item.my_name == p_name: result.append(_item)
	return result

func is_melee() -> bool:
	return projectile_type == ProjectileBase.NONE
# endregion GETTERs

# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float) -> bool:
	if not _my_owner.multiplayer.is_server(): return false
	if _my_owner.is_dead(): return false
	if _my_owner.current_state != EntityState.States.IDLE: return false # Cant attack while moving
	if _my_owner.is_spawning: return false
	
	if target_to_attack == GameManager.moomoo: set_target_to_attack(_get_nearest_target_in_range_attack()) # Priorize players over moomoo (only for enemies)

	if target_to_attack == null: return false
	if target_to_attack.is_dead(): return false

	if not can_physical_attack(): return false

	execute_physical_attack()
	last_physical_hit_time = Time.get_ticks_msec()

	return true

func _get_nearest_target_in_range_attack():
	var max_range = cache_total_stats.get_attack_range()
	var start_pos = _my_owner.global_position
	if _my_owner is Player:
		return GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_enemies(), max_range)

	if _my_owner is Enemy:
		# First we check if there is a player nearby, then if the moomoo is in attack range
		var nearest_player = GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_players(), max_range)
		if nearest_player: return nearest_player

		if GlobalsEntityHelpers.is_target_in_attack_range(_my_owner, GameManager.moomoo): return GameManager.moomoo

	return null

func execute_physical_attack(apply_extra_actions: bool = true, _custom_target: Entity = null) -> void:
	EntityState.change_to_attack(_my_owner)

	var final_target := _custom_target if _custom_target else target_to_attack
	_my_owner.set_direction_according_to_target(final_target)

	_execute_attack_or_launch_projectile(final_target)

	if not apply_extra_actions: return

func _execute_attack_or_launch_projectile(final_target: Entity) -> void:
	for registered_item in Item.REGISTERED_ITEMS:
		registered_item.static_actions_before_execute_physical_attack(_my_owner, final_target)

	if is_melee(): return server_execute_physical_damage(final_target, false)

	if launch_projectile(final_target, false): return

	printerr("ERROR: Projectile type not found: " + projectile_type + " 🚀") # Should never happen

func launch_projectile(final_target: Entity, _extra_projectile: bool) -> bool:
	var executed_shot := false
	var physical_attack_power := _my_owner.cache_total_stats.get_physical_attack_power()

	# First, we apply the projectile to the main target
	for reg_proj in ProjectileBase.REGISTERED_CLASSES:
		if reg_proj.try_launch(projectile_type, _my_owner, final_target, physical_attack_power, reg_proj.NAME, _extra_projectile):
			executed_shot = true
			break

	if _extra_projectile: return executed_shot

	# Then we try to launch extra projectiles if it's a direct attack (original projectile)
	var extra_targets: Array[Entity] = []
	if _my_owner.cache_total_stats.get_extra_projectiles() > 0:
		extra_targets.append_array(GlobalsEntityHelpers.get_closest_entities(_my_owner.global_position, _my_owner.get_my_enemies(), cache_total_stats.get_attack_range(), cache_total_stats.get_extra_projectiles(), [final_target]))

	var percent_damage := cache_total_stats.get_extra_projectile_percent_damage()
	var new_physical_attack_power := int(max(physical_attack_power * percent_damage, 1))
	for target in extra_targets:
		for reg_proj in ProjectileBase.REGISTERED_CLASSES:
			if reg_proj.try_launch(projectile_type, _my_owner, target, new_physical_attack_power, reg_proj.NAME, true):
				executed_shot = true
				break

	return executed_shot

func can_physical_attack() -> bool:
	if not _my_owner.can_attack: return false
	if _my_owner.velocity != Vector2.ZERO: return false # If moving, can't attack
	if is_stunned: return false # If stunned, can't attack

	var now = Time.get_ticks_msec()
	var interval_ms = 1000.0 / cache_total_stats.get_total_attack_speed()
	if now - last_physical_hit_time < interval_ms: return false # If enough time has passed, can attack

	if not GlobalsEntityHelpers.is_target_in_attack_range(_my_owner, target_to_attack): return false

	return true
# endregion TRY PHISICAL ATTACK

# region 	SERVER METHODS
func global_receive_damage_or_heal(_di: DamageInfo):
	BloodStainEffect.apply_bleeding_on_the_body(_my_owner)

	if _di.critical > 0:
		_my_owner.hud.show_message_popup(str(- (_di.total_damage - _di.critical)), Color(1, 0, 0))
		_my_owner.hud.show_message_popup(str(-_di.critical), Color(1, 1, 0))
		if _di.is_arrow_attack(): SoundsHelper.play_critical_arrow_shot()
		if _di.is_melee_attack(): SoundsHelper.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage > 0 and _di.is_melee_attack():
		SoundsHelper.play_melee_hit()

	if _di.total_damage < 0 and _my_owner.is_my_player(): # Heal
		_my_owner.hud.show_message_popup(str(abs(_di.total_damage)), Color(0, 1, 0))
	
	register_attacker(_di.get_attacker())

func _actions_after_1_second(_delta: float) -> void:
	_1_second_timer += _delta
	if _1_second_timer < 1.0: return

	_1_second_timer = 0.0

	var my_owner_stats: CombatStats = cache_total_stats
	# HP and mana regen
	_apply_hp_regen(my_owner_stats)
	_apply_mana_regen(my_owner_stats)

	# if current_mana < get_mana():
	# 	update_current_mana_for_damage(-my_owner_stats.get_mana_regeneration_points())

func _apply_hp_regen(_stats: CombatStats) -> void:
	if _stats.get_hp_regeneration_points() == 0: return
	if current_hp >= get_full_health(): return
	
	update_current_hp(_stats.get_hp_regeneration_points())

func _apply_mana_regen(_stats: CombatStats) -> void:
	if _stats.get_mana_regeneration_points() == 0: return
	if current_mana >= get_full_mana(): return

	update_current_mana(_stats.get_mana_regeneration_points())
# endregion SERVER METHODS
