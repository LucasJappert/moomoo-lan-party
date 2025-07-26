class_name SkillBase
extends MyInitAuxiliary

# Array of skill classes (each must have .create_and_add_instance)
static var REGISTERED_SKILLS: Array = [
	SkillCleaveStrike,
	SkillBloodFury,
	SkillStormStrike,
	SkillStunningStrike,
	SkillFrozenTouch,
	SkillTrueStrike,
	SkillManaScorcher,
	SkillMirrorDemise,
	SkillMultipleStrike,
	SkillFrenziedSilence,
	SkillEarthshatter,
	SkillDeathBurst,
	SkillInfernalTouch,
	SkillPainEcho,
	SkillSilentAgony,
	SkillBlessingOfPower,
	SkillLifesteal,
	SkillBurningPresence,
	SkillArcLightningStorm,
	SkillUnbreakable,
	SkillAbsorbAndRelease,
	SkillShockSpear,
	SkillStaticDischarge,
	SkillStormWrath,
	SkillShieldedCore
]

static var FIRE_SKILLS: Array = [SkillBurningPresence.NAME]
static var SKILLS: Dictionary[String, Skill] = {}
static var effects_running_by_owner_name: Dictionary = {}

const ATLAS_START_POS = Vector2(0, 1632)
const FRAME_SIZE = 64
const AVAILABLE_LEVELS: int = 3
var my_name: String
var active: bool = false
var seconds_elapsed: float
var duration_in_seconds: float
var permanent_effect: bool = false
var learned_skill: ItemSkillBase

static var int_array: Array[int]; static var int_array1: Array[int]; static var float_array: Array[float]; static var float_array1: Array[float]
static var aux_array: Array = [[], [], [], [], [], [], [], [], [], [], [], []]

func _init(_learned_skill: ItemSkillBase = null, _active: bool = false) -> void:
	super._init()
	if not _learned_skill: return
	learned_skill = _learned_skill
	my_name = learned_skill.my_name
	duration_in_seconds = _learned_skill.duration_in_seconds
	active = _active

func activate() -> void:
	active = true
	seconds_elapsed = 0
	
func process_skill(_owner: Entity, _delta: float) -> void:
	if not active or permanent_effect: return
	seconds_elapsed += _delta
	if seconds_elapsed < duration_in_seconds: return

	active = false

func has_fire() -> bool: return my_name in FIRE_SKILLS

static func _initialize_skills() -> void:
	for skill_class in REGISTERED_SKILLS: skill_class.create_and_add_instance()

static func get_skill(_skill_name: String, new_copy: bool = true) -> Skill:
	if SKILLS.is_empty(): _initialize_skills()
	
	if new_copy: return ObjectHelpers.deep_clone(SKILLS[_skill_name])
	
	return SKILLS[_skill_name]
	
static func get_new_learned_skill(_skill_name: String, skill_level: int = 1) -> Skill:
	if SKILLS.is_empty(): _initialize_skills()
	
	var result = ObjectHelpers.deep_clone(SkillBase.SKILLS[_skill_name])
	result.learned_level = skill_level
	return result


static func remove_effects_running_by_owner_name(_owner_name: String) -> void:
	effects_running_by_owner_name.erase(_owner_name)

static func get_permanent_active_skill(_learned_skill: ItemSkillBase) -> SkillBase:
	var skill = SkillBase.new(_learned_skill, true)
	skill.permanent_effect = true
	return skill

# Must be overriden
func on_damage_received(_attacker: Entity, _damage_received: int) -> void: pass

# Must be overriden
func actions_after_execute_physical_attack(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void: pass
# Must be overriden
func instance_actions_before_receive_damage(_attacker: Entity, _di: DamageInfo) -> bool: return false

# Must be overriden
static func create_and_add_instance() -> void: pass

# Must be overriden
static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	return false

static func verify_range(_caster: Entity, _target: Entity, _learned_skill: ItemSkillBase) -> bool:
	if _learned_skill.cast_range_in_tiles == 0: return true
	if not _caster or not _target: return true

	return _caster.is_in_range(_target.movement_helper.current_cell, _learned_skill.cast_range_in_tiles)

# Must be overriden
static func actions_after_cast_skill(_owner: Entity, _skill_used: ItemSkillBase) -> void: pass

# Must be overriden
static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool: return false

# Must be overriden
static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool: return false
	
# Must be overriden
static func on_active_skill_added(_owner: Entity, _skill: SkillBase) -> void: pass

# Must be overriden
static func on_active_skill_removed(_owner: Entity, _skill: SkillBase) -> void: pass

# Must be overriden
static func actions_after_die(_owner: Entity, _killed_by: Entity) -> void: pass

# Must be overriden
static func actions_after_current_hp_updated(_increased_value: int, _owner: Entity) -> void: pass
# Must be overriden
func instance_actions_after_current_hp_updated(_increased_value: int, _owner: Entity) -> void: pass

# Must be overriden
static func actions_before_receive_damage(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool: return false
