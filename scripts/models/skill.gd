class_name Skill

extends MyInitAuxiliary

const Names = {
	SHIELDED_CORE = "Shielded Core", # ✅
	BLESSING_OF_POWER = "Blessing of Power", # ✅
	LIFESTEAL = "Lifesteal", # ✅
	MIRROR_DEMISE = "Mirror Demise", # ✅
	FROZEN_TOUCH = "Frozen Touch", # ✅
	STUNNING_STRIKE = "Stunning Strike", # ✅
	STORM_STRIKE = "Storm Strike", # ✅
	BLOOD_FURY = "Blood Fury", # ✅
	CLEAVE_STRIKE = "Cleave Strike", # ✅
	TRUE_STRIKE = "True Strike", # ✅
	MANA_SCORCHER = "Mana Scorcher",
	DIVINE_SHIELD = "Divine Shield",
	ENERGY_ABSORPTION = "Energy Absorption",
	VOID_STEP = "Void Step",
	TOXIC_SPORES = "Toxic Spores",
	HELLFIRE_STORM = "Hellfire Storm",
	BONE_CAGE = "Bone Cage",
	FLAME_BURST = "Flame Burst",
	FROST_NOVA = "Frost Nova",
	SHADOW_STEP = "Shadow Step",
	STUNNING_BLOW = "Stunning Blow",
	MULTI_SHOT = "Multi Shot",
	FINAL_EXPLOSION = "Final Explosion",
	RAGE_BOOST = "Rage Boost",
	KAMIKAZE_CHARGE = "Kamikaze Charge",
	ARCANE_SHIELD = "Arcane Shield",
	PIERCING_ARROW = "Piercing Arrow",
	BURNING_WEAPON = "Burning Weapon",
	EVASIVE_DASH = "Evasive Dash",
	NECROTIC_PULSE = "Necrotic Pulse",
	GUARDIANS_PRESENCE = "Guardian's Presence",
	CURSE_OF_THORNS = "Curse of Thorns",
	STORMLASH_REFLEX = "Stormlash Reflex",
	STATIC_RETALIATION = "Static Retaliation",
	ECHOING_WRATH = "Echoing Wrath",
	REVERBERATING_PAIN = "Reverberating Pain",
	PHANTOM_REPRISAL = "Phantom Reprisal",
}

static var _SKILLS: Dictionary[String, Skill]
const FRAME_SIZE = 64
const _ATLAS_START_POS = Vector2(0, 1632)

var item_skill_base: Array[ItemSkillBase] = []
static var AVAILABLE_LEVELS: int = 3
var learned_level: int = 0

var region_rect: Rect2 = Rect2()

func _init(_name: String = "", _type: String = SkillType.PASSIVE):
	super._init()
	item_skill_base = []
	for i in range(AVAILABLE_LEVELS):
		item_skill_base.append(ItemSkillBase.new())
		item_skill_base[i].my_name = _name
		item_skill_base[i].type = _type

# region :::::::::::::::::::: GETTERs

static func get_skill(_skill_name: String, new_copy: bool = true) -> Skill:
	if _SKILLS.is_empty(): initialize_skills()
	
	if new_copy: return ObjectHelpers.deep_clone(_SKILLS[_skill_name])
	
	return _SKILLS[_skill_name]
	
static func get_new_learned_skill(_skill_name: String, skill_level: int = 1) -> Skill:
	if _SKILLS.is_empty(): initialize_skills()
	
	var result = ObjectHelpers.deep_clone(_SKILLS[_skill_name])
	result.learned_level = skill_level
	return result
	

static func get_mana_scorcher() -> Skill:
	var skill = Skill.new(Names.MANA_SCORCHER, SkillType.ACTIVE)
	skill.description = "Burns 50% of the target's mana, dealing 25% of that as physical damage."
	return skill

func get_learned_skill() -> ItemSkillBase:
	if not learned_level: return null
	return item_skill_base[learned_level - 1]

func get_safe_learned_skill() -> ItemSkillBase:
	if not learned_level: return item_skill_base[0]

	return get_learned_skill()

func get_stats() -> CombatStats:
	return get_learned_skill().stats

func get_max_targets() -> int:
	return get_learned_skill().max_targets

func get_description() -> String:
	var result = get_safe_learned_skill().get_description()

	return result

func can_use(my_owner: Entity) -> bool:
	if not learned_level: return false

	return item_skill_base[learned_level - 1].can_use(my_owner)

func get_remaining_cooldown() -> float:
	if not learned_level: return 0
	return get_learned_skill().get_remaining_cooldown()
# endregion ................. GETTERs


# region :::::::::::::::::::: SETTERs

static func initialize_skills() -> void:
	var aux_skill_name = ""
	var aux_text: String; var aux_text1: String; var aux_text2: String
	var _skill: Skill
	var int_array: Array[int]; var float_array: Array[float]

	# region SKILL TRUE_STRIKE
	aux_skill_name = Names.TRUE_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 3, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	
	float_array = [0.4, 0.7, 1]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.ignore_enemy_evasion_chance = float_array[i]
		_skill.item_skill_base[i].description = "Grants " + StringHelpers.format_percent(_skill.item_skill_base[i].stats.ignore_enemy_evasion_chance) + " chance to ignore the target's evasion."

	# region SKILL SHIELDED_CORE
	aux_skill_name = Names.SHIELDED_CORE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(0 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	
	float_array = [0.2, 0.25, 0.3]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.magic_defense_percent = float_array[i]
		_skill.item_skill_base[i].stats.physical_defense_percent = float_array[i]
		_skill.item_skill_base[i].max_stacks = 1
		_skill.item_skill_base[i].apply_to_owner = true
		_skill.item_skill_base[i].create_effect = true
		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.magic_defense_percent)
		_skill.item_skill_base[i].description = "Reduces magic and physical defense by " + aux_text

	# endregion

	# region SKILL BLESSING_OF_POWER
	aux_skill_name = Names.BLESSING_OF_POWER
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(1 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.2, 0.25, 0.3]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.physical_attack_power_percent = float_array[i]
		_skill.item_skill_base[i].stats.magic_attack_power_percent = float_array[i]
		_skill.item_skill_base[i].max_stacks = 1
		_skill.item_skill_base[i].apply_to_owner = true
		_skill.item_skill_base[i].create_effect = true
		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.physical_attack_power_percent)
		_skill.item_skill_base[i].description = "Increases physical and magic attack power by " + aux_text
	
	# endregion

	# region SKILL MIRROR_DEMISE
	aux_skill_name = Names.MIRROR_DEMISE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(2 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	for i in range(AVAILABLE_LEVELS):
		_skill.item_skill_base[i].description = "Upon death, splits into " + str((i + 1) * 2) + " copies with half the original HP."
	# endregion

	# region SKILL FROZEN_TOUCH
	aux_skill_name = Names.FROZEN_TOUCH
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(3 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)

	int_array = [3, 4, 5]
	for i in int_array.size():
		_skill.item_skill_base[i].stats.attack_speed_percent = -0.1
		_skill.item_skill_base[i].stats.move_speed_percent = -0.1
		_skill.item_skill_base[i].stats.freeze_duration = 4
		_skill.item_skill_base[i].max_stacks = int_array[i]
		_skill.item_skill_base[i].apply_to_owner = false
		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.attack_speed_percent)
		aux_text1 = StringHelpers.format_float_compact(_skill.item_skill_base[i].stats.freeze_duration)
		_skill.item_skill_base[i].description = "The attacker's icy touch partially freezes the target, reducing their movement and attack speed by " + aux_text + " for " + aux_text1 + " seconds."
	# endregion

	# region SKILL STUNNING_STRIKE
	aux_skill_name = Names.STUNNING_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(4 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.1, 0.15, 0.2]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.stun_chance = float_array[i]
		_skill.item_skill_base[i].stats.stun_duration = 2
		_skill.item_skill_base[i].apply_to_owner = true
		_skill.item_skill_base[i].max_stacks = 1
		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.stun_chance)
		aux_text1 = StringHelpers.format_float_compact(_skill.item_skill_base[i].stats.stun_duration)
		_skill.item_skill_base[i].description = "Has a " + aux_text + " chance to stun the target for " + aux_text1 + " seconds."
	
	# endregion

	# region SKILL LIFESTEAL
	aux_skill_name = Names.LIFESTEAL
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(5 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	
	float_array = [0.15, 0.175, 0.2]
	for i in float_array.size():
		_skill.item_skill_base[i].apply_to_owner = false
		_skill.item_skill_base[i].create_effect = true
		_skill.item_skill_base[i].stats.life_steal_percent = float_array[i]

		aux_text = StringHelpers.format_percent(float_array[i])
		_skill.item_skill_base[i].description = "Steals " + aux_text + " of dealt damage as life."
	# endregion

	# region SKILL STORM_STRIKE
	aux_skill_name = Names.STORM_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.ACTIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	int_array = [80, 130, 200]
	for i in int_array.size():
		_skill.item_skill_base[i].mana_cost = int_array[i]
	int_array = [8, 5, 2]
	for i in int_array.size():
		_skill.item_skill_base[i].cooldown = int_array[i]
	int_array = [5, 6, 7]
	for i in int_array.size():
		_skill.item_skill_base[i].max_targets = int_array[i]
	int_array = [20, 50, 100]
	for i in int_array.size():
		_skill.item_skill_base[i].stats.custom_damage_heal.base_damage_heal = int_array[i]
	float_array = [0.2, 0.3, 0.4]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.custom_damage_heal.extra_value_by_intelligence = float_array[i]
	for i in range(AVAILABLE_LEVELS):
		_skill.item_skill_base[i].apply_to_owner = false
		_skill.item_skill_base[i].damage_type = DamageType.MAGIC

		aux_text = StringHelpers.format_float_compact(_skill.item_skill_base[i].stats.custom_damage_heal.base_damage_heal)
		aux_text1 = StringHelpers.format_percent(_skill.item_skill_base[i].stats.custom_damage_heal.extra_value_by_intelligence)
		_skill.item_skill_base[i].description = "Calls down a bolt of arcane lightning, dealing " + aux_text + " base magic damage, plus an additional " + aux_text1 + " of the caster's total Intelligence to multiple targets."
	
	# endregion

	# region BLOOD FURY
	aux_skill_name = Names.BLOOD_FURY
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.1, 0.15, 0.2]
	for i in int_array.size():
		_skill.item_skill_base[i].stats.physical_attack_power_percent = float_array[i]
		_skill.item_skill_base[i].stats.attack_speed_percent = float_array[i]
		_skill.item_skill_base[i].stats.hp_regeneration_points_percent = float_array[i]

		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.physical_attack_power_percent)
		aux_text1 = StringHelpers.format_percent(_skill.item_skill_base[i].stats.attack_speed_percent)
		aux_text2 = StringHelpers.format_percent(_skill.item_skill_base[i].stats.hp_regeneration_points_percent)
		_skill.item_skill_base[i].description = "Gives " + aux_text + " extra physical attack power, " + aux_text1 + " extra attack speed and " + aux_text2 + " extra hp regeneration per each 10% of lost hp."
	# endregion

	# region CLEAVE STRIKE
	aux_skill_name = Names.CLEAVE_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.2, 0.3, 0.4]
	int_array = [1, 1, 2]
	for i in int_array.size():
		_skill.item_skill_base[i].stats.cleave_effect = CleaveEffect.new(float_array[i], int_array[i])
		_skill.item_skill_base[i].description = "Deals " + StringHelpers.format_percent(float_array[i]) + " of the damage as a cleave effect to enemies around " + str(int_array[i]) + " tiles."
	# endregion

func use(my_owner: Entity, target_entity: Entity) -> void:
	if not can_use(my_owner): return print("Cannot use skill: ", get_learned_skill())

	if get_learned_skill().my_name == Names.STORM_STRIKE:
		if not _apply_storm_strike(my_owner, target_entity): return

	get_learned_skill().set_last_used_time()

	my_owner.combat_data.update_current_mana(-get_learned_skill().mana_cost)

func try_to_upgrade(my_owner: Entity) -> void:
	if learned_level >= AVAILABLE_LEVELS: return

	learned_level += 1
	my_owner.increment_skill_points_to_assign(-1)

	EventBus.emit_skill_upgraded(my_owner)

# endregion ................. SETTERs

# region :::::::::::::::::::: SKILLS LOGICS
static func verify_blood_fury(my_owner: Entity) -> void:
	var learned_skill = my_owner.combat_data.get_learned_skill(Names.BLOOD_FURY)
	if not learned_skill: return

	var current_hp = my_owner.combat_data.current_hp
	var total_hp: float = my_owner.combat_data.get_total_hp()
	var percent_lost_hp: float = floor((1 - current_hp / total_hp) * 10.0) / 10.0
	if percent_lost_hp <= 0: return

	var effect_stats = CombatStats.new()
	effect_stats.physical_attack_power = my_owner.combat_data.cache_total_stats_no_effects.physical_attack_power * percent_lost_hp
	effect_stats.attack_speed = my_owner.combat_data.cache_total_stats_no_effects.attack_speed * percent_lost_hp
	effect_stats.level = percent_lost_hp * 10 # Should be 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

	var existing_effect = my_owner.combat_data.get_effect(Names.BLOOD_FURY)
	if existing_effect:
		if existing_effect.stats.level == effect_stats.level: return

	my_owner.combat_data.remove_effect_by_name(Names.BLOOD_FURY)

	var new_effect = CombatEffect.get_permanent_effect(Names.BLOOD_FURY, learned_skill.max_stacks, effect_stats)
	new_effect.set_region_rect(_SKILLS[Names.BLOOD_FURY].region_rect)
	my_owner.combat_data.effects_helper.add_effect(new_effect)

static func actions_before_entity_death(_dead_entity: Entity, _attacker: Entity) -> void:
	if not _dead_entity is Enemy: return
	if _dead_entity.replicated: return

	var mirror_skill = _dead_entity.combat_data.get_learned_skill(Names.MIRROR_DEMISE)
	if mirror_skill:
		var target_tiles = [
			Vector2(-MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y),
			Vector2(-MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y)
		]
		for i in range(4):
			# var new_enemy = EnemyFactory.get_enemy_instance(_dead_entity.enemy_type)
			# new_enemy.set_combat_data()
			var new_enemy = ObjectHelpers.deep_clone(_dead_entity) as Enemy
			new_enemy.replicated = true
			new_enemy.position = _dead_entity.position + target_tiles[i]
			# We need set combat_data props after the enemy is added to the scene
			new_enemy.combat_stats.hp = new_enemy.combat_data.get_total_hp() * 0.5
			new_enemy.combat_data.update_cache_total_stats()
			new_enemy.combat_data.current_hp = new_enemy.combat_stats.hp
			GameManager.add_enemy(new_enemy)

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	# Should be called only on the server
	# Freeze verification
	var frozen_skill = _attacker.combat_data.get_learned_skill(Names.FROZEN_TOUCH)
	if frozen_skill:
		var skill_stats = frozen_skill.stats.get_combat_stats_instance()
		var effect = CombatEffect.get_temporal_effect(Names.FROZEN_TOUCH, skill_stats.freeze_duration, frozen_skill.max_stacks, skill_stats)
		effect.stats.is_owner_friendly = false
		effect.set_region_rect(Skill.get_skill(Names.FROZEN_TOUCH, false).region_rect)
		_target.combat_data.effects_helper.add_effect(effect)

	# Cleave verification
	var cleave_skill = _attacker.combat_data.get_learned_skill(Names.CLEAVE_STRIKE)
	if cleave_skill: CleaveEffect.auxiliary_actions_after_hit(cleave_skill.stats, _attacker, _target, _di)

func _apply_storm_strike(_attacker: Entity, _target: Entity) -> bool:
	if not _target: return false

	var attacker_stats = _attacker.combat_data.cache_total_stats
	var total_damage = get_stats().custom_damage_heal.get_total_damage_heal(attacker_stats.agility, attacker_stats.strength, attacker_stats.intelligence)

	var targets = [_target]
	var my_enemies = _attacker.get_my_enemies()
	targets.append_array(GlobalsEntityHelpers.get_closest_entities(_target.global_position, get_max_targets() - 1, my_enemies, 6, [_target]))

	for target in targets:
		var _di := DamageInfo.new(total_damage, get_learned_skill().damage_type)
		var critical_damage = _attacker.combat_data.try_critical_hit(total_damage)
		var total_damage_and_crit = total_damage + critical_damage

		_di.total_damage = total_damage_and_crit
		_di.critical = critical_damage
		_di.projectile_type = Projectile.TYPES.NONE
		_di.damage_type = DamageType.MAGIC
		_di.attacker_name = _attacker.name

		target.combat_data.server_receive_damage(_di, _attacker)
		target.rpc_handler.add_animation(AnimationsHelper.ANIMATION_NAMES.LIGHTNING)
	
	return true


# endregion .................... SKILLS LOGICS


# Skill("Mana Scorcher", "Active", 40, 8, "Burns 50% of the target's mana, dealing 25% of that as physical damage."),
# Skill("Divine Shield", "Active", 60, 12, "Summons a divine shield making the caster immune to all damage for 5 seconds."),
# Skill("Energy Absorption", "Active", 50, 10, "Creates a shield that absorbs 25% of incoming damage and releases it in an area after 5 seconds."),
# Skill("Void Step", "Active", 20, 5, "Becomes intangible for 1 second, avoiding all physical damage."),
# Skill("Toxic Spores", "Passive", 0, 0, "Releases toxic spores when hit, poisoning nearby enemies."),
# Skill("Hellfire Storm", "Active", 60, 10, "Calls down a firestorm over an area for 3 seconds."),
# Skill("Bone Cage", "Active", 30, 6, "Traps a target in bone prison for 2 seconds."),
# Skill("Flame Burst", "Active", 25, 4, "A fiery explosion that deals area damage on impact."),
# Skill("Frost Nova", "Active", 30, 6, "Slows all nearby enemies for 3 seconds."),
# Skill("Shadow Step", "Active", 35, 7, "Teleports behind the target and lands a guaranteed critical hit."),
# Skill("Lifesteal Aura", "Passive", 0, 0, "Steals 20% of damage dealt as health."),
# Skill("Stunning Blow", "Passive", 0, 0, "Every 4th attack stuns the enemy for 1.5 seconds."),
# Skill("Multi Shot", "Passive", 0, 0, "Every 3rd attack fires 3 projectiles in a cone."),
# Skill("Final Explosion", "Passive", 0, 0, "Explodes upon death dealing magical area damage."),
# Skill("Rage Boost", "Passive", 0, 0, "Increases physical attack by 30% below 50% HP."),
# Skill("Kamikaze Charge", "Active", 50, 8, "Charges at the enemy and explodes on contact dealing area damage."),
# Skill("Arcane Shield", "Active", 40, 7, "Reduces magical damage taken by 40% for 5 seconds."),
# Skill("Piercing Arrow", "Passive", 0, 0, "Ignores 50% of the enemy's physical defense."),
# Skill("Burning Weapon", "Passive", 0, 0, "Applies a 3-second burn on hit."),
# Skill("Evasive Dash", "Passive", 0, 0, "Has a 20% chance to dodge incoming attacks."),
# Skill("Frozen Touch", "Passive", 0, 0, "20% chance to freeze the target for 1 second."),
# Skill("Necrotic Pulse", "Active", 30, 6, "Releases a dark pulse that reduces enemy attack."),
# Skill("Guardian's Presence", "Passive", 0, 0, "Grants an aura that increases allies' physical and magical defense by 10%."),
# Skill("Curse of Thorns", "Passive", 0, 0, "Enemies attacking the bearer have their attack speed reduced by 50% for 3 seconds."),
# Skill("Stormlash Reflex", "Passive", 0, 0, "10% chance on hit to fire 5 lightning bolts at different enemies."),
# Skill("Static Retaliation", "Passive", 0, 0, "10% chance on hit to unleash electricity on 3 enemies."),
# Skill("Echoing Wrath", "Passive", 0, 0, "10% chance on hit to stun all enemies within 3 tiles."),
# Skill("Reverberating Pain", "Passive", 0, 0, "Reflects 10% of total received damage to enemies within 3 tiles."),
# Skill("Phantom Reprisal", "Passive", 0, 0, "15% chance on hit to teleport to a free tile within 5 tiles and deal critical damage to adjacent enemies.")
