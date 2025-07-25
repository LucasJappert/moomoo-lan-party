class_name SkillCleaveStrike
extends SkillBase

const NAME: String = "Cleave Strike"
const ICON_SLOT = Vector2(2, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.4, 0.5, 0.5]
	aux_array[1] = [1, 1, 2]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.CLEAVE_PERCENT] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict[CombatStats.CLEAVE_RANGE] = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].description = "Deals " + StringHelpers.format_percent(aux_array[0][i]) + " of the damage as a cleave effect to enemies behind the target for " + str(aux_array[1][i]) + " tiles."

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_a_cleave_damage or _di.was_reflected or _di.temporal_damage: return false
	if _di.damage_type != DamageType.PHYSICAL: return false
	var _learned_skill := _attacker.get_learned_skill(NAME)
	if not _learned_skill: return false
	
	var radius_in_tiles := _learned_skill.float_dict[CombatStats.CLEAVE_RANGE]
	CleaveEffect.show_cleave_effect_with_texture(
		GameManager.game_world.over_terrain_layer_layer_2,
		_target.global_position,
		_attacker.get_direction_according_to_target(_target),
		radius_in_tiles,
	)

	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_target.global_position, _attacker.get_my_enemies(), radius_in_tiles, 100, [_target])
	var filtered_enemies := GlobalsEntityHelpers.filter_enemies_according_to_caster_direction(_attacker.position, _target.position, nearest_enemies)

	if filtered_enemies.is_empty(): return true

	var cleave_damage: int = int(_di.total_damage * _learned_skill.float_dict[CombatStats.CLEAVE_PERCENT])
	var _cdi := DamageInfo.new(cleave_damage, _di.damage_type, _attacker.name)
	_cdi.projectile_type = ProjectileBase.NONE
	_cdi.can_be_evaded = false
	_cdi.was_a_cleave_damage = true

	for enemy in filtered_enemies: enemy.server_receive_damage(_cdi, _attacker)

	return true
