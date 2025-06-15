class_name CombatData

extends Node

@onready var combat_effect_node = $CombatEffectNode

var stats: CombatStats = CombatStats.new()
@export var current_hp: int = 100
@export var current_mana: int = 100
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = Projectile.TYPES.NONE
var skills: Array[Skill] = []
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

func _ready() -> void:
	stats.initialize_default_values() # TODO: Review this... Why dont use get_default_instance()?
	if multiplayer.is_server() == false:
		set_process(false)

	# Agregamos una señal para cuando se agrega un hijo a combat_effect_node
	combat_effect_node.connect("child_entered_tree", func(p_effect: CombatEffect):
		if !GameManager.MY_PLAYER: return

		if my_owner().is_my_player(): GameManager.my_main.gui_scene.add_effect_to_my_effects(p_effect)

		var target_entity_of_my_player = GameManager.MY_PLAYER.combat_data._target_entity
		if target_entity_of_my_player:
			if target_entity_of_my_player.name == my_owner().name:
				GameManager.my_main.gui_scene.add_effect_to_target_effects(p_effect)
	)

	%CombatEffectSpawner.spawn_function = func(effect_data: Dictionary) -> Node:
		return CombatEffect.get_instance_from_dict(effect_data)

# TODO: Improve this
func _process(_delta: float):
	if not my_owner(): return

	try_physical_attack(_delta)

	_try_to_add_effect_from_skills()

	_actions_after_1_second(_delta)

func my_owner() -> Entity:
	if _my_owner: return _my_owner
	_my_owner = GlobalsEntityHelpers.get_owner(self)
	return _my_owner

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

		matching_effects.sort_custom(func(a, b): return a._elapsed > b._elapsed) # Sort by _elapsed in descending order (oldest first)
		var oldest_effect := matching_effects[0]
		oldest_effect.delete_effect()

	%CombatEffectSpawner.spawn(ObjectHelpers.to_dict(p_effect))
	p_effect.queue_free()

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

func try_critical_hit(base_value: int) -> int:
	var critical_damage = 0
	var total_stats = get_total_stats()
	if GlobalsEntityHelpers.roll_chance(total_stats.crit_chance):
		critical_damage = base_value * total_stats.crit_multiplier
	return critical_damage

# TODO: Review
func _server_execute_physical_damage(_target: Entity) -> void:
	if my_owner().multiplayer.is_server() == false: return
	if _target == null: return

	var total_stats = get_total_stats()
	var base_damage = total_stats.physical_attack_power
	base_damage += base_damage * total_stats.physical_attack_power_percent
	
	var critical_damage = try_critical_hit(base_damage)
	var total_damage = base_damage + critical_damage

	var _di = DamageInfo.get_instance()
	_di.total_damage_heal = total_damage
	_di.critical = critical_damage
	_di.projectile_type = projectile_type
	_di.damage_type = DamageType.PHYSICAL
	_di.attacker_name = my_owner().name

	_target.combat_data._server_receive_damage(_di, my_owner())


func _server_receive_damage(_di: DamageInfo, _attacker: Entity) -> void:
	if my_owner().multiplayer.is_server() == false: return

	var total_stats = get_total_stats()
	
	if _check_evade(_di, total_stats): return # Evasion verification (only for physical damage)

	_apply_defenses(_di, total_stats)

	CombatEffect.actions_after_effective_hit(_attacker, my_owner(), _di)
	Skill.actions_after_effective_hit(_attacker, my_owner(), _di)

	my_owner().rpc("rpc_receive_damage_or_heal", ObjectHelpers.to_dict(_di, true))

	update_current_hp(-_di.total_damage_heal)

# region SETTERs
func update_current_hp(value_to_increase: int, _attacker: Entity = null) -> void:
	if current_hp <= 0: return
	
	current_hp += value_to_increase
	current_hp = clamp(current_hp, 0, get_total_hp())
	
	if current_hp <= 0:
		Skill.actions_before_entity_death(my_owner(), _attacker)
		current_hp = 0
		if my_owner() is Enemy:
			for player in GameManager.get_players():
				player.increment_current_exp(Enemy.get_enemy_exp_when_dead())
		my_owner().rpc("rpc_die")

func update_current_mana(value_to_increase: int) -> void:
	current_mana = clamp(current_mana + value_to_increase, 0, get_total_mana())

func register_attacker(attacker: Entity) -> void:
	latest_attacker = attacker
	last_damage_received_time = Time.get_ticks_msec()

func set_target_entity(_target: Entity) -> void: # Used only by the server
	if _target == _target_entity: return

	target_entity_name = str(_target.name) if _target != null else ""
	_target_entity = _target

func charge_skill(index: int) -> void:
	if skills[index].is_learned == false: return

	print("Charging skill: ", skills[index].skill_name)
	charged_skill = skills[index]
func uncharge_skill() -> void:
	charged_skill = null
	print("Uncharging skill")

func use_charged_skill() -> void:
	if charged_skill == null: return

	charged_skill.use(my_owner(), _target_entity)

	uncharge_skill()
# endregion

# region GETTERs
func _check_evade(_di: DamageInfo, total_stats: CombatStats) -> bool:
	if _di.damage_type != DamageType.PHYSICAL: return false # Evasion verification (only for physical damage)

	if not GlobalsEntityHelpers.roll_chance(total_stats.evasion): return false

	# TODO: Crear un helper para enviar mensajes
	var sm = ServerMessage.new("Dodge", Vector3(0, 0.5, 1))
	my_owner().rpc("rpc_server_message", ObjectHelpers.to_dict(sm, true))

	return true

func _apply_defenses(_di: DamageInfo, total_stats: CombatStats) -> void:
	var damage_before_defense := _di.total_damage_heal

	if _di.damage_type == DamageType.PHYSICAL:
		var reduced_damage := int(total_stats.physical_defense_percent * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.physical_defense_percent * _di.critical)
		var total_damage: int = _di.total_damage_heal - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage_heal = total_damage

	if _di.damage_type == DamageType.MAGIC:
		var reduced_damage := int(total_stats.magic_defense_percent * damage_before_defense)
		_di.critical = _di.critical - int(total_stats.magic_defense_percent * _di.critical)
		var total_damage: int = _di.total_damage_heal - reduced_damage
		if total_damage < 0: total_damage = 0
		_di.total_damage_heal = total_damage

func get_skill(skill_name: String) -> Skill:
	for skill in skills:
		if skill.skill_name == skill_name: return skill
	return null

func get_total_hp() -> int:
	return get_total_stats().hp

func get_total_mana() -> int:
	return get_total_stats().mana

func is_stunned() -> bool:
	for effect in get_effects():
		if effect.stats.stun_duration > 0 && not effect.is_owner_friendly: return true
	return false

func get_target_entity() -> Entity:
	return GameManager.get_entity(target_entity_name)

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
	var max_range = get_total_stats().attack_range
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

	Projectile.launch(my_owner(), _target_entity, get_total_stats().physical_attack_power)
		
func can_physical_attack() -> bool:
	if not my_owner().can_attack: return false
	if my_owner().velocity != Vector2.ZERO: return false # If moving, can't attack
	if is_stunned(): return false # If stunned, can't attack

	var now = Time.get_ticks_msec()
	var interval_ms = 1000.0 / get_total_stats().get_total_attack_speed()
	if now - last_physical_hit_time < interval_ms: return false # If enough time has passed, can attack

	if not GlobalsEntityHelpers.is_target_in_attack_range(my_owner(), _target_entity): return false

	return true
# endregion TRY PHISICAL ATTACK

# region 	SERVER METHODS
func global_receive_damage_or_heal(_di: DamageInfo):
	var melee_attack = _di.projectile_type == Projectile.TYPES.NONE
	var arrow_attack = _di.projectile_type == Projectile.TYPES.ARROW
	if _di.critical > 0:
		my_owner().hud.show_damage_heal_popup(str(- (_di.total_damage_heal - _di.critical)), Color(1, 0, 0))
		my_owner().hud.show_damage_heal_popup(str(-_di.critical), Color(1, 1, 0))
		if arrow_attack: SoundManager.play_critical_arrow_shot()
		if melee_attack: SoundManager.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage_heal > 0:
		if melee_attack: SoundManager.play_melee_hit()

	if _di.total_damage_heal < 0: # Heal
		my_owner().hud.show_damage_heal_popup(str(abs(_di.total_damage_heal)), Color(0, 1, 0))
	
	register_attacker(_di.get_attacker())

func _try_to_add_effect_from_skills() -> void:
	if not my_owner() is Player: return
	for skill in skills:
		if skill.type != SkillType.PASSIVE: continue
		if not skill.is_learned: continue
		if not skill.apply_to_owner: continue
		if get_effect(skill.skill_name) != null: continue # Already has this effect

		var new_effect = CombatEffect.get_permanent_effect(skill.skill_name, skill.max_stacks, skill.stats)
		new_effect.set_region_rect(skill.region_rect)
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
	var _total_stats := CombatStats.new()
	_total_stats.accumulate_combat_stats(stats.get_total_stats_including_extras_by_attributes())
	_total_stats.accumulate_combat_stats(_get_extra_stats_by_effects().get_total_stats_including_extras_by_attributes())

	return _total_stats

func _get_extra_stats_by_effects() -> CombatStats:
	var extra_stats = CombatStats.new()
	for effect in get_effects():
		if effect.stats.stun_duration > 0 && not effect.is_owner_friendly:
			continue # Do not add stun stats if it is an effect that is hostile to the owner
		extra_stats.accumulate_combat_stats(effect.stats)
	return extra_stats

func get_attack_range() -> int:
	return get_total_stats().attack_range

# endregion GETTERs

# region Front Animations
const _ANIMATED_SPRITE_STUN_NAME = "stun"
func animation_active(animated_sprite_name: String) -> bool:
	for animated_sprite in my_owner().front_animations_node.get_children():
		if animated_sprite is AnimatedSprite2D and animated_sprite.name == animated_sprite_name:
			return true
	return false
func remove_animations(animated_sprite_name: String):
	for child in my_owner().front_animations_node.get_children():
		if child is AnimatedSprite2D and child.name == animated_sprite_name:
			child.queue_free()
func try_to_remove_obsolete_stun_animation():
	var animation_stun_active = animation_active(_ANIMATED_SPRITE_STUN_NAME)
	if not animation_stun_active: return
	
	for effect in get_effects():
		if effect.stun_duration > 0: return

	remove_animations(_ANIMATED_SPRITE_STUN_NAME)

func _get_position_of_bottom_of_the_cell(sprite_size: Vector2) -> Vector2:
	return Vector2(0, -sprite_size.y * 0.5 + MapManager.TILE_SIZE.y * 0.7)

func apply_frost_hit_animation():
	const sprite_size = Vector2(32, 32)
	var frames = SpritesHelper.get_sprite_frames(Vector2(0, 576), sprite_size, 11, 30, false)
	spawn_front_fx(frames, "frost_hit")

func apply_stun_animation():
	if animation_active(_ANIMATED_SPRITE_STUN_NAME): return
	var sprite_size = CombatEffect.STUN_RECT_REGION.size
	var frames = SpritesHelper.get_sprite_frames(CombatEffect.STUN_RECT_REGION.position, sprite_size, 14, 30, true)
	var sprite_position = Vector2(0, my_owner().hud.my_health_bar.position.y + 10)
	spawn_front_fx(frames, _ANIMATED_SPRITE_STUN_NAME, sprite_position)

func apply_lightning_animation():
	var sprite_size = Vector2(64, 96)
	var frames = SpritesHelper.get_sprite_frames(Vector2(0, 640), sprite_size, 12, 25, false)
	spawn_front_fx(frames, "lightning", _get_position_of_bottom_of_the_cell(sprite_size))
	SoundManager.play_lightning_spell()

func spawn_front_fx(frames: SpriteFrames, animated_sprite_name: String, sprite_position: Vector2 = Vector2.ZERO):
	var sprite := AnimatedSprite2D.new()
	sprite.position = sprite_position
	sprite.sprite_frames = frames
	sprite.name = animated_sprite_name
	my_owner().front_animations_node.add_child(sprite, true)
	sprite.play()
	sprite.animation_finished.connect(func(): sprite.queue_free())

# endregion Front Animations
