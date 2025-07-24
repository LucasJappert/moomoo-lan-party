class_name SkillLifesteal
extends SkillBase

const NAME = "Lifesteal"
const ICON_SLOT = Vector2(5, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	float_array = [0.15, 0.2, 0.25]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].stats.life_steal_percent = float_array[i]
		SKILLS[NAME].item_skill_base[i].description = "Steals " + StringHelpers.format_percent(float_array[i]) + " of dealt damage as life."
	
static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if not _skill.get_learned_skill(): return false

	_owner.effects_helper.remove_effect_by_name(NAME)

	var new_effect = CombatEffect.get_permanent_effect_from_skill(_skill)
	_owner.effects_helper.add_effect(new_effect)

	return true
