class_name SkillMultipleStrike

extends SkillBase

const NAME = "Multiple Strike"
const ICON_SLOT = Vector2(5, 1)

var current_hits: int = 0

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

func actions_after_execute_physical_attack(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if current_hits < learned_skill.float_dict["hits_to_trigger"]:
		current_hits += 1
		return

	current_hits = 0
	var extra_targets := int(learned_skill.float_dict["targets"])
	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, _attacker.get_my_enemies(), _attacker.get_attack_range(), extra_targets, [_target])
	for extra_target in nearest_enemies:
		_attacker.execute_physical_attack(false, extra_target)

	
static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [5, 4, 3]
	aux_array[1] = [2, 3, 4]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].float_dict["hits_to_trigger"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["targets"] = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false

		SKILLS[NAME].item_skill_base[i].description = "Every " + str(aux_array[0][i]) + " attacks executes a multiple attack to " + str(aux_array[1][i]) + " extra enemies"

static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.add_active_skill(SkillMultipleStrike.new(_skill.get_learned_skill()))

	return true
