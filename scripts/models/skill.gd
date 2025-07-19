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
	MANA_SCORCHER = "Mana Scorcher", # ✅
	MULTIPLE_STRIKE = "Multiple Strike", # ✅
	FRENZIED_SILENCE = "Frenzied Silence", # ✅
	EARTHSHATTER = "Earthshatter", # ✅
	ABSORB_AND_RELEASE = "Absorb and Release", # ✅
	UNBREAKABLE = "Unbreakable", # ✅
	ARC_LIGHTNING_STORM = "Arc Lightning Storm", # ✅
	SHOCK_SPEAR = "Shock Spear", # ✅
	STATIC_DISCHARGE = "Static Discharge", # ✅
	# PAIN_ECHO = "Pain Echo", # ✅
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
var skill_name: String = ""

func _init(_name: String = "", _type: String = SkillType.ACTIVE):
	super._init()
	item_skill_base = []
	for i in range(AVAILABLE_LEVELS):
		item_skill_base.append(ItemSkillBase.new())
		item_skill_base[i].my_name = _name
		item_skill_base[i].type = _type
	skill_name = _name


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
	
func get_name() -> String:
	if item_skill_base.size() == 0: return ""
	return item_skill_base[0].my_name

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

func get_description(include_stats_description: bool = true) -> String:
	var result = ""

	var tag_color_1 = "[color=#D3C5AC]"; var tag_color_2 = "[color=#605A4F]";
	for index in range(item_skill_base.size()):
		if index > 0: result += "\n"
		var color = tag_color_1 if index + 1 == learned_level else tag_color_2
		result += color + "⚔ [u][b]Level " + str(index + 1) + ":[/b][/u] " + item_skill_base[index].get_description(include_stats_description) + "[/color]"

	return result

func can_use(my_owner: Entity) -> bool:
	if not learned_level: return false
	if my_owner.is_silenced: return false

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
	var int_array: Array[int]; var int_array1: Array[int]; var float_array: Array[float]; var float_array1: Array[float]

	for skill_class in SkillBase.REGISTERED_SKILLS: skill_class.create_and_add_instance(_SKILLS)

	# region EARTHSHATTER
	aux_skill_name = Names.EARTHSHATTER
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.ACTIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 6, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	int_array = [2, 3, 4]
	int_array1 = [100, 150, 200]
	float_array = [0.5, 1, 1.5]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].apply_to_enemy = true
		_skill.item_skill_base[i].area_of_effect_in_tiles = 2
		_skill.item_skill_base[i].instant_use = true
		_skill.item_skill_base[i].damage_type = DamageType.MAGIC
		_skill.item_skill_base[i].stats.stun_duration = int_array[i]
		_skill.item_skill_base[i].auxiliary_float = float_array[i] # Strenght percent damage
		_skill.item_skill_base[i].mana_cost = int_array1[i]
		_skill.item_skill_base[i].cooldown = 12
		_skill.item_skill_base[i].description = (
			"Stuns all enemies within " + str(_skill.item_skill_base[i].area_of_effect_in_tiles) + " tiles for " + str(int_array[i]) +
			" seconds and deals " + StringHelpers.format_percent(float_array[i]) +
			" of the hero's total strength as damage."
		)

	# endregion

	# region FRENZIED_SILENCE
	aux_skill_name = Names.FRENZIED_SILENCE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.ACTIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 6, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.2, 0.3, 0.4]
	int_array = [80, 110, 140]
	float_array1 = [10, 8, 6]
	int_array1 = [6, 6, 6]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].stats.attack_speed_percent = float_array[i]
		_skill.item_skill_base[i].stats.silence_duration = int_array1[i]
		_skill.item_skill_base[i].create_effect = true
		_skill.item_skill_base[i].apply_to_enemy = false
		_skill.item_skill_base[i].mana_cost = int_array[i]
		_skill.item_skill_base[i].cooldown = float_array1[i]
		_skill.item_skill_base[i].duration_in_seconds = int_array1[i]

		_skill.item_skill_base[i].description = (
			"Grants " + StringHelpers.format_percent(float_array[i]) +
			" bonus attack speed for " + str(int_array1[i]) +
			" seconds. Silences the hero during this time."
		)
	# endregion

	# region MULTIPLE_STRIKE
	aux_skill_name = Names.MULTIPLE_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 5, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	int_array = [2, 3, 4]
	int_array1 = [5, 4, 3]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].stats.multiple_strike = MultipleStrike.new(int_array[i], int_array1[i])
		_skill.item_skill_base[i].description = "Every " + str(int_array1[i]) + " attacks executes a multiple attack to " + str(int_array[i]) + " extra enemies"
	# endregion

	# region SKILL MANA_SCORCHER
	aux_skill_name = Names.MANA_SCORCHER
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 4, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	
	float_array = [0.5, 0.75, 1] # Percentage of mana to burn regarding physical damage dealt
	float_array1 = [0.5, 0.75, 1] # Percentage of physical damage dealt
	for i in float_array.size():
		_skill.item_skill_base[i].stats.mana_burn = ManaBurn.new(float_array[i], float_array1[i], true)
		_skill.item_skill_base[i].description = "Burns mana from the target equal to " + StringHelpers.format_percent(float_array[i]) + " of the physical damage dealt, then deals additional physical damage equal to " + StringHelpers.format_percent(float_array1[i]) + " of the mana burned."


	# endregion

	# region SKILL TRUE_STRIKE
	aux_skill_name = Names.TRUE_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 3, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	
	float_array = [0.4, 0.7, 1]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.ignore_enemy_evasion_chance = float_array[i]
		_skill.item_skill_base[i].description = "Grants " + StringHelpers.format_percent(_skill.item_skill_base[i].stats.ignore_enemy_evasion_chance) + " chance to ignore the target's evasion."

	# endregion

	# region SKILL MIRROR_DEMISE
	aux_skill_name = Names.MIRROR_DEMISE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(2 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	for i in range(AVAILABLE_LEVELS):
		_skill.item_skill_base[i].apply_to_enemy = false
		_skill.item_skill_base[i].description = "Upon death, splits into " + str((i + 1) * 2) + " copies with half the original HP."
	# endregion

	# region SKILL FROZEN_TOUCH
	aux_skill_name = Names.FROZEN_TOUCH
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.PASSIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(3 * FRAME_SIZE + _ATLAS_START_POS.x, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)

	int_array = [3, 4, 5]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].apply_to_enemy = true
		_skill.item_skill_base[i].stats.attack_speed_percent = -0.1
		_skill.item_skill_base[i].stats.move_speed_percent = -0.1
		_skill.item_skill_base[i].stats.freeze_duration = 4
		_skill.item_skill_base[i].max_stacks = int_array[i]
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
		_skill.item_skill_base[i].apply_to_enemy = false
		_skill.item_skill_base[i].max_stacks = 1
		aux_text = StringHelpers.format_percent(_skill.item_skill_base[i].stats.stun_chance)
		aux_text1 = StringHelpers.format_float_compact(_skill.item_skill_base[i].stats.stun_duration)
		_skill.item_skill_base[i].description = "Has a " + aux_text + " chance to stun the target for " + aux_text1 + " seconds."
	
	# endregion

	# region SKILL STORM_STRIKE
	aux_skill_name = Names.STORM_STRIKE
	_SKILLS[aux_skill_name] = Skill.new(aux_skill_name, SkillType.ACTIVE)
	_skill = _SKILLS[aux_skill_name]
	_skill.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	int_array = [80, 130, 200]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].mana_cost = int_array[i]
	int_array = [8, 5, 2]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].cooldown = int_array[i]
	int_array = [5, 6, 7]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].max_targets = int_array[i]
	int_array = [20, 50, 100]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].stats.custom_damage_heal.base_damage_heal = int_array[i]
	float_array = [0.2, 0.3, 0.4]
	for i in float_array.size():
		_skill.item_skill_base[i].stats.custom_damage_heal.extra_value_by_intelligence = float_array[i]
	for i in range(AVAILABLE_LEVELS):
		_skill.item_skill_base[i].apply_to_enemy = true
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
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].apply_to_enemy = false
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

	float_array = [0.4, 0.5, 0.5]
	int_array = [1, 1, 2]
	for i in AVAILABLE_LEVELS:
		_skill.item_skill_base[i].apply_to_enemy = false
		_skill.item_skill_base[i].stats.cleave_effect = CleaveEffect.new(float_array[i], int_array[i])
		_skill.item_skill_base[i].description = "Deals " + StringHelpers.format_percent(float_array[i]) + " of the damage as a cleave effect to enemies around " + str(int_array[i]) + " tiles."
	# endregion

func use(my_owner: Entity, target_entity: Entity) -> bool:
	var learned_skill := get_learned_skill()
	if not learned_skill: return false

	if not can_use(my_owner):
		print("Cannot use skill: ", learned_skill)
		return false

	# New way to use skills
	for skill_class in SkillBase.REGISTERED_SKILLS:
		if not skill_class.try_to_use(my_owner, learned_skill, target_entity): return false
		# Actions after cast
		skill_class.actions_after_cast_skill(my_owner, learned_skill)

	# TODO: Old way to use skills
	if learned_skill.my_name == Names.EARTHSHATTER:
		if not _apply_earthshatter(my_owner): return false
	if learned_skill.my_name == Names.STORM_STRIKE:
		if not _apply_storm_strike(my_owner, target_entity): return false
	if learned_skill.my_name == Names.FRENZIED_SILENCE:
		if not _apply_frenzied_silence(my_owner, target_entity): return false

	learned_skill.reset_last_used_time()

	my_owner.update_current_mana(-learned_skill.mana_cost)

	return my_owner.uncharge_skill()

func try_to_upgrade(my_owner: Entity, p_slot_number: int) -> void:
	if learned_level >= AVAILABLE_LEVELS: return

	# Keep the last used time
	item_skill_base[learned_level].set_last_used_time(item_skill_base[learned_level - 1].get_last_used_time())

	learned_level += 1
	my_owner.increment_skill_points_to_assign(-1)

	EventBus.emit_skill_upgraded(my_owner, self, p_slot_number)

# endregion ................. SETTERs

# region :::::::::::::::::::: SKILLS LOGICS
func _apply_earthshatter(_attacker: Entity) -> bool:
	if not _attacker: return false

	var learned_skill = get_learned_skill()
	if not learned_skill: return false

	var target_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, _attacker.get_my_enemies(), learned_skill.area_of_effect_in_tiles)

	var magic_damage: int = _attacker.cache_total_stats.strength * learned_skill.auxiliary_float
	var total_magic_damage = _attacker.get_total_magic_damage(magic_damage)

	for _enemy in target_enemies:
		var _di = DamageInfo.new(total_magic_damage, learned_skill.damage_type, _attacker.name)
		_enemy.server_receive_damage(_di, _attacker)
		_enemy.apply_stun(learned_skill.stats.stun_duration)

	var message := DamageType.MAGIC_EMOTI + " " + str(total_magic_damage) + " " + DamageType.MAGIC_EMOTI
	_attacker.hud.show_message_popup(message.to_upper(), Color(1, 1, 1), 0.4)

	SoundsHelper.play_scream_hero_1()
	return true

func _apply_frenzied_silence(_attacker: Entity, _target: Entity) -> bool:
	var learned_skill = get_learned_skill()
	if not _target or not learned_skill: return false

	var effect_stats = learned_skill.stats.get_combat_stats_instance()
	var new_effect = CombatEffect.get_temporal_effect(Names.FRENZIED_SILENCE, learned_skill.duration_in_seconds, learned_skill.max_stacks, effect_stats)
	new_effect.set_region_rect(_SKILLS[Names.FRENZIED_SILENCE].region_rect)
	_target.effects_helper.add_effect(new_effect)

	return true

func _apply_storm_strike(_attacker: Entity, _target: Entity) -> bool:
	if not _target: return false

	var attacker_stats = _attacker.cache_total_stats
	var total_damage = get_stats().custom_damage_heal.get_total_damage_heal(attacker_stats.agility, attacker_stats.strength, attacker_stats.intelligence)
	var total_magic_damage = _attacker.get_total_magic_damage(total_damage)

	var targets = [_target]
	var my_enemies = _attacker.get_my_enemies()
	targets.append_array(GlobalsEntityHelpers.get_closest_entities(_target.global_position, my_enemies, 6, get_max_targets() - 1, [_target]))

	for target in targets:
		var _di := DamageInfo.new(total_magic_damage, get_learned_skill().damage_type)
		var critical_damage = _attacker.try_critical_hit(total_magic_damage)
		var total_damage_and_crit = total_magic_damage + critical_damage

		_di.total_damage = total_damage_and_crit
		_di.critical = critical_damage
		_di.projectile_type = ProjectileBase.NONE
		_di.damage_type = DamageType.MAGIC
		_di.attacker_name = _attacker.name

		target.server_receive_damage(_di, _attacker)
		target.rpc_handler.add_animation(AnimationsHelper.ANIMATION_NAMES.LIGHTNING)
	
	return true

static func verify_blood_fury(my_owner: Entity) -> void:
	var learned_skill = my_owner.get_learned_skill(Names.BLOOD_FURY)
	if not learned_skill: return

	var current_hp = my_owner.current_hp
	var total_hp: float = my_owner.get_total_hp()
	var percent_lost_hp: float = floor((1 - current_hp / total_hp) * 10.0) / 10.0
	if percent_lost_hp <= 0: return

	var effect_stats = CombatStats.new()
	effect_stats.physical_attack_power = my_owner.cache_total_stats_no_effects.physical_attack_power * percent_lost_hp
	effect_stats.attack_speed = my_owner.cache_total_stats_no_effects.attack_speed * percent_lost_hp
	effect_stats.level = percent_lost_hp * 10 # Should be 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

	var existing_effect = my_owner.effects_helper.get_effect_by_name(Names.BLOOD_FURY)
	if existing_effect:
		if existing_effect.stats.level == effect_stats.level: return

	my_owner.remove_effect_by_name(Names.BLOOD_FURY)

	var new_effect = CombatEffect.get_permanent_effect(Names.BLOOD_FURY, _SKILLS[Names.BLOOD_FURY].region_rect, learned_skill.max_stacks, effect_stats)
	my_owner.effects_helper.add_effect(new_effect)

static func actions_before_entity_death(_dead_entity: Entity, _attacker: Entity) -> void:
	if not _dead_entity is Enemy: return
	if _dead_entity.replicated: return

	var mirror_skill = _dead_entity.get_learned_skill(Names.MIRROR_DEMISE)
	if mirror_skill:
		var target_tiles = [
			Vector2(-MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y),
			Vector2(-MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y)
		]
		for i in range(4):
			var new_enemy = ObjectHelpers.deep_clone(_dead_entity) as Enemy
			new_enemy.replicated = true
			new_enemy.position = _dead_entity.position + target_tiles[i]
			# We need set combat_data props after the enemy is added to the scene
			new_enemy.combat_stats.hp = new_enemy.get_total_hp() * 0.5
			new_enemy.set_current_hp_and_mana()
			GameManager.spawn_enemy(new_enemy)

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not ObjectHelpers.valid_instance(_attacker): return
	
	# Freeze verification
	var frozen_skill = _attacker.get_learned_skill(Names.FROZEN_TOUCH)
	if frozen_skill:
		var skill_stats = frozen_skill.stats.get_combat_stats_instance()
		var effect = CombatEffect.get_temporal_effect(Names.FROZEN_TOUCH, skill_stats.freeze_duration, frozen_skill.max_stacks, skill_stats)
		effect.set_region_rect(Skill.get_skill(Names.FROZEN_TOUCH, false).region_rect)
		_target.effects_helper.add_effect(effect)
		SoundsHelper.play_random_ice_hit()

	# Cleave verification
	var cleave_skill = _attacker.get_learned_skill(Names.CLEAVE_STRIKE)
	if cleave_skill: CleaveEffect.auxiliary_actions_after_hit(cleave_skill.stats, _attacker, _target, _di)

	# MANA_SCORCHER verification
	var mana_scorcher_skill = _attacker.get_learned_skill(Names.MANA_SCORCHER)
	if mana_scorcher_skill: ManaBurn.auxiliary_actions_after_hit(mana_scorcher_skill.stats, _attacker, _target, _di)

static func actions_after_execute_physical_attack(_attacker: Entity, _target: Entity):
	var multiple_strike_skill = _attacker.get_learned_skill(Names.MULTIPLE_STRIKE)
	if multiple_strike_skill:
		# TODO: get this logic to MultipleStrike class
		if multiple_strike_skill.stats.multiple_strike.increment_hits():
			var extra_targets = multiple_strike_skill.stats.multiple_strike.extra_targets
			var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, _attacker.get_my_enemies(), _attacker.get_attack_range(), extra_targets, [_target])
			for extra_target in nearest_enemies:
				_attacker.execute_physical_attack(false, extra_target)

static func actions_before_receive_damage(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	for active_skill in _target._active_skills:
		if active_skill.my_name == Names.UNBREAKABLE: return false
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
