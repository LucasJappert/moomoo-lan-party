class_name CombatData

extends CombatStats

@onready var combat_effect_node = $CombatEffectNode

@export var base_hp: int = 100
@export var current_hp: int = 100
@export var base_mana: int = 100
@export var current_mana: int = 100
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = Projectile.TYPES.NONE
var skills: Array[Skill] = []

var _1_second_timer: float = 0.0
var _target_entity: Entity #

var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity

var my_owner: Entity

var last_damage_received_time: int = 0 # In milliseconds
var latest_attacker: Entity

func _ready() -> void:
	initialize_default_values()
	if multiplayer.is_server() == false:
		set_process(false)

func _process(_delta: float):
	_try_to_add_effect_from_skills()

	_actions_after_1_second(_delta)
	
	if my_owner.combat_data._target_entity == null:
		if my_owner.movement_helper.current_path.is_empty():
			if my_owner.combat_data.latest_attacker:
				if my_owner is Player:
					var nearest_enemy: Entity
					nearest_enemy = GlobalsEntityHelpers.get_nearest_entity(my_owner.global_position, GameManager.get_enemies(), my_owner.area_vision_shape.shape.radius)
					my_owner.combat_data.set_target(nearest_enemy)


func set_my_owner(_owner: Entity) -> void:
	my_owner = _owner
	pass

func add_effect(p_effect: CombatEffect) -> void:
	# Should be called only on the server
	var current_stacks = 0
	for effect in get_effects():
		if effect.name == p_effect.name: current_stacks += 1

	if current_stacks >= p_effect.max_stacks:
		return print("Combat effect ", p_effect.name, " reached max stacks: ", p_effect.max_stacks)

	combat_effect_node.add_child(p_effect, true)

# TODO: Improve this get by creating a dictionary to quickly obtain active effects
func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for child in combat_effect_node.get_children():
		if child is CombatEffect:
			effects.append(child as CombatEffect)
	return effects

func get_effect(effect_name: String) -> CombatEffect:
	for effect in get_effects():
		if effect.name == effect_name: return effect
	return null

# TODO: Review
func _server_calculate_physical_damage(_target: Entity) -> void:
	if my_owner.multiplayer.is_server() == false: return
	if _target == null: return

	var critical_damage = 0
	if GlobalsEntityHelpers.roll_chance(crit_chance):
		critical_damage = get_total_stats().physical_attack_power * crit_multiplier
	var total_damage = get_total_stats().physical_attack_power + critical_damage
	# print("Normal power: ", physical_attack_power, " Extra power: ", extra_power, " Total total_damage: ", total_damage)

	var _di = DamageInfo.get_instance()
	_di.total_damage_heal = total_damage
	_di.critical = critical_damage
	_di.projectile_type = projectile_type
	_di.damage_type = DamageInfo.DamageType.PHYSICAL
	_di.attacker_name = my_owner.name

	_target.combat_data._server_receive_physical_damage(_di, my_owner)

func _server_receive_physical_damage(_di: DamageInfo, _attacker: Entity) -> void:
	if my_owner.multiplayer.is_server() == false: return

	# Evasion verification
	if GlobalsEntityHelpers.roll_chance(get_total_stats().evasion):
		# TODO: Crear un helper para enviar mensajes
		var sm = ServerMessage.get_instance()
		sm.message = "Dodge"
		sm.color = Vector3(0, 0.5, 1)
		my_owner.rpc("rpc_server_message", sm.to_dict())
		return

	var damage_before_defense := _di.total_damage_heal
	var reduced_damage := int(get_total_stats().physical_defense_percent * damage_before_defense)
	_di.critical = _di.critical - int(get_total_stats().physical_defense_percent * _di.critical)
	var total_damage: int = _di.total_damage_heal - reduced_damage
	if total_damage < 0: total_damage = 0

	_di.total_damage_heal = total_damage

	CombatEffect.actions_after_effective_hit(_attacker, my_owner, _di)
	Skill.actions_after_effective_hit(_attacker, my_owner, _di)

	# print("Damage before defense: ", damage_before_defense, " reduced: ", reduced_damage, " total: ", total_damage, " critical: ", _di.critical)

	my_owner.rpc("rpc_receive_damage_or_heal", _di.to_dict())

	update_current_hp(-total_damage)

# region SETTERs
func update_current_hp(value_to_increase: int, _attacker: Entity = null) -> void:
	if current_hp <= 0: return
	
	current_hp += value_to_increase
	current_hp = clamp(current_hp, 0, get_total_hp())
	
	if current_hp <= 0:
		Skill.actions_before_entity_death(my_owner, _attacker)
		current_hp = 0
		if my_owner is Enemy:
			for player in GameManager.get_players():
				player.increment_current_exp(Enemy.get_enemy_exp_when_dead())
		my_owner.rpc("rpc_die")

func update_current_mana(value_to_increase: int) -> void:
	current_mana = clamp(current_mana + value_to_increase, 0, get_total_mana())

func register_attacker(attacker: Entity) -> void:
	latest_attacker = attacker
	last_damage_received_time = Time.get_ticks_msec()

func set_target(_target: Entity) -> void:
	_target_entity = _target
	my_owner.movement_helper.update_path_to_entity(_target)
# endregion

# region GETTERs
func get_skill(skill_name: String) -> Skill:
	for skill in skills:
		if skill.name == skill_name: return skill
	return null

func get_total_hp() -> int:
	return base_hp + get_total_stats().hp

func get_total_mana() -> int:
	return base_mana + get_total_stats().mana

func is_stunned() -> bool:
	for effect in get_effects():
		if effect.stun_duration > 0 && not effect.is_owner_friendly: return true
	return false
# endregion

# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float) -> bool:
	if not my_owner.multiplayer.is_server(): return false

	if my_owner.velocity != Vector2.ZERO: return false

	# Priorize players over moomoo (only for enemies)
	if _target_entity == GameManager.moomoo: _target_entity = _get_nearest_target_in_range_attack()

	if not GlobalsEntityHelpers.is_target_in_attack_area(my_owner, _target_entity):
		_target_entity = _get_nearest_target_in_range_attack()

	if _target_entity == null: return false

	if not can_physical_attack(): return false

	_execute_physical_attack()
	last_physical_hit_time = Time.get_ticks_msec()

	return true

func _get_nearest_target_in_range_attack():
	var max_range = get_total_stats().attack_range
	var start_pos = my_owner.global_position
	if my_owner is Player:
		return GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_enemies(), max_range)

	if my_owner is Enemy:
		# First we check if there is a player nearby, then if the moomoo is in attack range
		var nearest_player = GlobalsEntityHelpers.get_nearest_entity(start_pos, GameManager.get_players(), max_range)
		if nearest_player: return nearest_player

		if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, GameManager.moomoo): return GameManager.moomoo

	return null

func _execute_physical_attack():
	match attack_type:
		AttackTypes.RANGED:
			Projectile.launch(my_owner, _target_entity, get_total_stats().physical_attack_power)

		AttackTypes.MELEE:
			_server_calculate_physical_damage(_target_entity)
	
func can_physical_attack() -> bool:
	if my_owner.velocity != Vector2.ZERO: return false # If moving, can't attack
	if is_stunned(): return false # If stunned, can't attack

	var now = Time.get_ticks_msec()
	var interval_ms = 1000.0 / get_total_stats().attack_speed
	return now - last_physical_hit_time >= interval_ms # If enough time has passed, can attack
# endregion

# region 	SERVER METHODS
func global_receive_damage_or_heal(_di: DamageInfo):
	var melee_attack = _di.projectile_type == Projectile.TYPES.NONE
	var arrow_attack = _di.projectile_type == Projectile.TYPES.ARROW
	if _di.critical > 0:
		my_owner.hud.show_damage_heal_popup(str(- (_di.total_damage_heal - _di.critical)), Color(1, 0, 0))
		my_owner.hud.show_damage_heal_popup(str(-_di.critical), Color(1, 1, 0))
		if arrow_attack: SoundManager.play_critical_arrow_shot()
		if melee_attack: SoundManager.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage_heal > 0:
		if melee_attack: SoundManager.play_melee_hit()

	if _di.total_damage_heal < 0: # Heal
		my_owner.hud.show_damage_heal_popup(str(abs(_di.total_damage_heal)), Color(0, 1, 0))
	
	register_attacker(_di.get_attacker())

func _try_to_add_effect_from_skills() -> void:
	if not my_owner is Player: return
	for skill in skills:
		if skill.type != Skill.Type.PASSIVE: continue
		if not skill.is_learned: continue
		if not skill.apply_to_owner: continue
		if get_effect(skill.name) != null: continue # Already has this effect

		var new_effect = CombatEffect.get_permanent_effect(skill.name, skill.get_combat_stats_instance())
		add_effect(new_effect)

func _actions_after_1_second(_delta: float) -> void:
	_1_second_timer += _delta
	if _1_second_timer < 1.0: return

	_1_second_timer = 0.0

	var my_owner_stats: CombatStats = get_total_stats()
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


# region 	GETTERs

func get_total_stats() -> CombatStats:
	# This function returns the total of all stats, including extras from effects and extras from attributes
	var base_stats = get_total_stats_including_extras_by_attributes()
	var stats_by_effects = _get_extra_stats_by_effects().get_total_stats_including_extras_by_attributes()

	var total_stats = base_stats.accumulate_combat_stats(stats_by_effects)
	return total_stats

func _get_extra_stats_by_effects() -> CombatStats:
	var extra_stats = CombatStats.new()
	for effect in get_effects():
		if effect.stun_duration > 0 && not effect.is_owner_friendly:
			continue # Do not add stun stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(effect.get_combat_stats_instance())
	return extra_stats


# endregion GETTERs

# region Front Animations
const _ANIMATED_SPRITE_STUN_NAME = "stun"
func animation_active(animated_sprite_name: String) -> bool:
	for animated_sprite in my_owner.front_animations_node.get_children():
		if animated_sprite is AnimatedSprite2D and animated_sprite.name == animated_sprite_name:
			return true
	return false
func remove_animations(animated_sprite_name: String):
	for child in my_owner.front_animations_node.get_children():
		if child is AnimatedSprite2D and child.name == animated_sprite_name:
			child.queue_free()
func try_to_remove_obsolete_stun_animation():
	var animation_stun_active = animation_active(_ANIMATED_SPRITE_STUN_NAME)
	if not animation_stun_active: return
	
	for effect in get_effects():
		if effect.stun_duration > 0: return

	remove_animations(_ANIMATED_SPRITE_STUN_NAME)

func apply_frost_hit_animation():
	const sprite_size = Vector2(32, 32)
	var frames = SpritesAnimationHelper.get_sprite_frames(Vector2(0, 576), sprite_size, 11, 30, false)
	spawn_front_fx(frames, "frost_hit")

func apply_stun_animation():
	if animation_active(_ANIMATED_SPRITE_STUN_NAME): return
	const sprite_size = Vector2(32, 17)
	var sprite_position = Vector2(0, my_owner.hud.my_health_bar.position.y + 10)
	var frames = SpritesAnimationHelper.get_sprite_frames(Vector2(0, 608), sprite_size, 14, 30, true)
	spawn_front_fx(frames, _ANIMATED_SPRITE_STUN_NAME, sprite_position)

func spawn_front_fx(frames: SpriteFrames, animated_sprite_name: String, sprite_position: Vector2 = Vector2.ZERO):
	var sprite := AnimatedSprite2D.new()
	sprite.position = sprite_position
	sprite.sprite_frames = frames
	sprite.name = animated_sprite_name
	my_owner.front_animations_node.add_child(sprite, true)
	sprite.play()
	sprite.animation_finished.connect(func(): sprite.queue_free())

# endregion Front Animations
