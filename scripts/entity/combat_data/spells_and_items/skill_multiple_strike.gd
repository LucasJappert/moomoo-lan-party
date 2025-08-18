class_name SkillMultipleStrike

extends SkillBase

const NAME = "Multiple Strike"
const ICON_SLOT = Vector2(5, 1)

var current_hits: int = 0

func _init(p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	permanent_effect = true

func actions_after_execute_physical_attack(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not _di.is_main_attack(): return

	if current_hits < learned_skill.float_dict["hits_to_trigger"]:
		current_hits += 1
		return

	current_hits = 0
	var extra_targets := int(learned_skill.float_dict["targets"])
	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, _attacker.get_my_enemies(), _attacker.cache_total_stats.get_attack_range_in_tiles(), extra_targets, [_target])
	for extra_target in nearest_enemies:
		_attacker.launch_projectile(extra_target, true)

	
static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [5, 4, 3]
	aux_array[1] = [2, 3, 4]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].float_dict["hits_to_trigger"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["targets"] = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].target_to_enemy = false
		SKILLS[NAME].item_skill_base[i].en_description = "Every " + str(aux_array[0][i]) + " attacks executes a multiple attack to " + str(aux_array[1][i]) + " extra enemies"
		SKILLS[NAME].item_skill_base[i].es_description = "Cada " + str(aux_array[0][i]) + " ataques desata un golpe múltiple que alcanza a " + str(aux_array[1][i]) + " enemigos adicionales."

static func actions_after_skill_updated(_owner: Entity, _skill: Skill) -> bool:
	if _skill.get_name() != NAME: return false
	if _skill.learned_level == 0: return false

	var skill := SkillMultipleStrike.new(_skill.get_learned_skill())
	_owner.add_active_skill(skill)

	return true

# static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
# 	if _learned_skill.my_name != NAME: return false

# 	_caster.add_active_skill(SkillMultipleStrike.new(_learned_skill))

# 	return true