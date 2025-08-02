class_name CombatEffect

extends CombatStats

var effect_name: String
var id: int
var is_permanent: bool = false
var duration_in_seconds: float # In seconds
var _elapsed: float = 0.0
var _region_rect: Rect2
var max_stacks: int = 1
var unique_id: int = UniqueIdGenerator.get_id()
var is_cooldown_finished: bool = false
var _description: String = ""

const STUN_RECT_REGION := Rect2(416, 256, 32, 32)
const STUN_NAME = "Stun"
const SILENCE_NAME = "Silence"

func _process(delta: float) -> void:
	if is_permanent: return

	_elapsed += delta
	if _elapsed <= duration_in_seconds: return

	_elapsed = duration_in_seconds
	is_cooldown_finished = true
	# EventBus.emit_effect_removed(GlobalsEntityHelpers.get_owner(self), self)

func get_description() -> String:
	var description = ""

	if _description != "": description += _description + "\n"

	if duration_in_seconds > 0.0:
		description += str("- Duration: ", StringHelpers.format_float_compact(duration_in_seconds), "s\n")

	description += super.get_new_description()

	if max_stacks > 1: description += str("- Max stacks: ", max_stacks, "\n")

	return description

# region 	SETTERs
func set_description(description: String) -> void:
	_description = description

func set_region_rect(rect: Rect2) -> void:
	_region_rect = rect
# endregion SETTERs


# region 	GETTERs

# endregion GETTERs


static func get_instance_from_dict(dict: Dictionary) -> CombatEffect:
	var combat_effect = CombatEffect.new()
	ObjectHelpers.from_dict(combat_effect, dict)
	return combat_effect

static func _get_instance(p_name: String, _duration_in_seconds: float, p_is_permanent: bool, _max_stacks: int, p_info: Dictionary[String, float]) -> CombatEffect:
	var combat_effect = CombatEffect.new()
	combat_effect.max_stacks = _max_stacks
	combat_effect.accumulate_info(p_info)
	combat_effect.duration_in_seconds = _duration_in_seconds
	combat_effect.is_permanent = p_is_permanent
	combat_effect.id = UniqueIdGenerator.get_id()
	combat_effect.effect_name = p_name
	return combat_effect

static func get_permanent_effect(p_name: String, p_region_rect: Rect2, _max_stacks: int, p_info: Dictionary[String, float]) -> CombatEffect:
	var result = _get_instance(p_name, 0.0, true, _max_stacks, p_info)
	result.set_region_rect(p_region_rect)
	return result

static func get_effect_from_skill_base(skill: SkillBase) -> CombatEffect:
	var learned_skill := skill.learned_skill
	var result = _get_instance(learned_skill.my_name, learned_skill.duration_in_seconds, skill.permanent_effect, learned_skill.max_stacks, learned_skill.get_info())
	result.set_description(learned_skill.description)
	result.set_region_rect(SkillBase.SKILLS[learned_skill.my_name].region_rect)
	return result

static func get_effect_from_item_skill_base(skill: ItemSkillBase) -> CombatEffect:
	var _is_permanent = skill.duration_in_seconds <= 0
	var result = _get_instance(skill.my_name, skill.duration_in_seconds, _is_permanent, skill.max_stacks, skill.get_info())
	result.set_description(skill.description)
	result.set_region_rect(SkillBase.SKILLS[skill.my_name].region_rect)
	return result
	
static func get_permanent_effect_from_skill(skill: Skill) -> CombatEffect:
	var learned_skill = skill.get_learned_skill()
	return get_permanent_effect(learned_skill.my_name, skill.region_rect, learned_skill.max_stacks, learned_skill.get_info())

static func get_temporal_effect(p_name: String, _duration_in_seconds: float, _max_stacks: int, p_info: Dictionary[String, float]) -> CombatEffect:
	var result = _get_instance(p_name, _duration_in_seconds, false, _max_stacks, p_info)
	if p_name == STUN_NAME: result.set_region_rect(CombatEffect.STUN_RECT_REGION)
	return result
