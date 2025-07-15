class_name SkillBase
extends MyInitAuxiliary

# Array of skill classes (each must have .create_and_add_instance)
static var REGISTERED_SKILLS: Array = [
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
static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	return true

# Must be overriden
static func try_add_effect_from_skill(_owner: Entity, _skill: Skill) -> bool:
	return false