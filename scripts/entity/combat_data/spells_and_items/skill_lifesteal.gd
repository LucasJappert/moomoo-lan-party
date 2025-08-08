class_name SkillLifesteal
extends SkillBase

const NAME = "Lifesteal"
const ICON_SLOT = Vector2(5, 0)

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.15, 0.2, 0.25]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].set_life_steal_percent(float_array[i])
		SKILLS[NAME].item_skill_base[i].en_description = "Steals " + StringHelpers.format_percent(float_array[i]) + " of dealt damage as life."
		SKILLS[NAME].item_skill_base[i].es_description = "Roba un " + StringHelpers.format_percent(float_array[i]) + " del daño infligido como vida."
	
static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.add_active_skill(SkillLifesteal.new(_skill.get_learned_skill()))

	return true
