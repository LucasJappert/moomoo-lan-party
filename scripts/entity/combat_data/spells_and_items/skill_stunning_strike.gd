class_name SkillStunningStrike

extends SkillBase

const NAME = "Stunning Strike"
const ICON_SLOT = Vector2(4, 0)

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.15, 0.2]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.STUN_CHANCE] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.STUN_DURATION] = 2
		SKILLS[NAME].item_skill_base[i].description = "Has a " + StringHelpers.format_percent(aux_array[0][i]) + " chance to stun the target for 2 seconds."
	
static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.add_active_skill(SkillStunningStrike.new(_skill.get_learned_skill()))

	return true
