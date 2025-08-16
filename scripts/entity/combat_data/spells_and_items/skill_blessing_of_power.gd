class_name SkillBlessingOfPower
extends SkillBase

const NAME = "Blessing of Power"
const ICON_SLOT = Vector2(1, 0)

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	
	aux_array[0] = [0.3, 0.4, 0.5]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].set_physical_attack_power_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].set_magic_attack_power_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].max_stacks = 1
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].en_description = "Increases physical and magic attack power by " + StringHelpers.format_percent(aux_array[0][i])
		SKILLS[NAME].item_skill_base[i].es_description = "Aumenta el poder de ataque físico y mágico en un " + StringHelpers.format_percent(aux_array[0][i])

static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if _skill.learned_level == 0: return false

	var skill := SkillBlessingOfPower.new(_skill.get_learned_skill())
	_owner.add_active_skill(skill)

	return true
