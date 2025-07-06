class_name SkillBase

extends MyInitAuxiliary

# Array of skill classes (each must have .create_and_add_instance)
static var REGISTERED_SKILLS: Array = [
	SkillArcLightningStorm,
	SkillUnbreakable,
	SkillAbsorbAndRelease
]

const _ATLAS_START_POS = Skill._ATLAS_START_POS
const FRAME_SIZE = Skill.FRAME_SIZE
var my_name: String
var active: bool = false
var seconds_elapsed: float
var duration_in_seconds: float
var action_waiting_on_finish: bool = false

static var int_array: Array[int]; static var int_array1: Array[int]; static var float_array: Array[float]; static var float_array1: Array[float]
static var aux_array: Array = [[], [], [], []]

func _init(_name: String, _duration_in_seconds: float = 0, _active: bool = false) -> void:
	super._init()
	my_name = _name
	duration_in_seconds = _duration_in_seconds
	active = _active

func activate() -> void:
	active = true
	seconds_elapsed = 0
	action_waiting_on_finish = false
	
func process_skill(_owner: Entity, _delta: float) -> void:
	if not active: return
	seconds_elapsed += _delta
	if seconds_elapsed < duration_in_seconds: return

	active = false
	action_waiting_on_finish = true

# Must be overriden
func on_damage_received(_attacker: Entity, _damage_received: int) -> void:
	pass

# Must be overriden
static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	pass

# Must be overriden
static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	return true
