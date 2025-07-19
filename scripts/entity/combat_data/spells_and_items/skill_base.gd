class_name SkillBase
extends MyInitAuxiliary

# Array of skill classes (each must have .create_and_add_instance)
static var REGISTERED_SKILLS: Array = [
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

const _ATLAS_START_POS = Skill._ATLAS_START_POS
const FRAME_SIZE = Skill.FRAME_SIZE
var my_name: String
var active: bool = false
var seconds_elapsed: float
var duration_in_seconds: float
var permanent_effect: bool = false
var learned_skill: ItemSkillBase

static var int_array: Array[int]; static var int_array1: Array[int]; static var float_array: Array[float]; static var float_array1: Array[float]
static var aux_array: Array = [[], [], [], [], [], [], [], [], [], [], [], []]

func _init(_learned_skill: ItemSkillBase, _active: bool = false) -> void:
	super._init()
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

static func actions_after_cast_skill(_owner: Entity, _skill_used: ItemSkillBase) -> void:
	# At the moment, Implemented in Static Discharge skill
	pass

# Must be overriden
func on_damage_received(_attacker: Entity, _damage_received: int) -> void:
	pass

# Must be overriden
static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	pass

# Must be overriden
static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if not _verify_range(_caster, _target, _learned_skill):
		return false

	return true

static func _verify_range(_caster: Entity, _target: Entity, _learned_skill: ItemSkillBase) -> bool:
	if _learned_skill.cast_range_in_tiles == 0: return true
	if not _caster or not _target: return true

	return _caster.is_in_range(_target.movement_helper.current_cell, _learned_skill.cast_range_in_tiles)

# Must be overriden
static func try_add_effect_from_skill(_owner: Entity, _skill: Skill) -> bool:
	return false

# Must be overriden
static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	return false