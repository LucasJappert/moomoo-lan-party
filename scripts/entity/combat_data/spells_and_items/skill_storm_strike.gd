class_name SkillStormStrike
extends SkillBase

const NAME: String = "Storm Strike"
const ICON_SLOT = Vector2(0, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [80, 130, 200] # mana cost
	aux_array[1] = [8, 5, 2] # cooldown
	aux_array[2] = [5, 6, 7] # max targets
	aux_array[3] = [20, 50, 100] # base damage
	aux_array[4] = [0.2, 0.3, 0.4] # extra damage by intelligence
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].target_to_enemy = true
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].max_targets = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].float_dict["base_damage"] = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].float_dict["extra_damage_by_intelligence"] = aux_array[4][i]
		SKILLS[NAME].item_skill_base[i].en_description = "Calls down a bolt of arcane lightning, dealing " + StringHelpers.format_float(aux_array[3][i]) + " base magic damage, plus an additional " + StringHelpers.format_percent(aux_array[4][i]) + " of the caster's total Intelligence to multiple targets."
		SKILLS[NAME].item_skill_base[i].es_description = "Invoca un rayo de energía arcana que inflige " + StringHelpers.format_float(aux_array[3][i]) + " de daño mágico base, más un " + StringHelpers.format_percent(aux_array[4][i]) + " del total de Inteligencia del lanzador a múltiples objetivos."

		
static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var attacker_stats = _caster.cache_total_stats
	var total_damage := int(_learned_skill.float_dict["base_damage"] + attacker_stats.get_intelligence() * _learned_skill.float_dict["extra_damage_by_intelligence"])

	var targets := GlobalsEntityHelpers.get_closest_entities(_target.global_position, _caster.get_my_enemies(), 6, _learned_skill.max_targets - 1, [_target])

	for target in targets:
		var _di := DamageInfo.new(total_damage, _learned_skill.damage_type)
		var critical_damage = _caster.try_critical_hit(total_damage)
		var total_damage_and_crit = total_damage + critical_damage

		_di.total_damage = total_damage_and_crit
		_di.critical = critical_damage
		_di.projectile_type = ProjectileBase.NONE
		_di.damage_type = DamageType.MAGIC
		_di.attacker_name = _caster.name

		target.server_receive_damage(_di, _caster)
		AnimationsHelper.apply_animation(target, AnimationsHelper.ANIMATION_NAMES.LIGHTNING)

	return true