class_name SkillEarthshatter
extends SkillBase

const NAME = "Earthshatter"
const ICON_SLOT = Vector2(6, 1)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [2, 3, 4]
	aux_array[1] = [100, 150, 200]
	aux_array[2] = [0.5, 1, 1.5]
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		SKILLS[NAME].item_skill_base[i].area_of_effect_in_tiles = 2
		SKILLS[NAME].item_skill_base[i].instant_use = true
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		SKILLS[NAME].item_skill_base[i].float_dict["stun_duration"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["strength_percent_damage"] = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].cooldown = 12
		SKILLS[NAME].item_skill_base[i].description = (
			"Stuns all enemies within " + str(SKILLS[NAME].item_skill_base[i].area_of_effect_in_tiles) + " tiles for " + str(aux_array[0][i]) +
			" seconds and deals " + StringHelpers.format_percent(aux_array[2][i]) +
			" of the hero's total strength as damage."
		)

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var target_enemies = GlobalsEntityHelpers.get_closest_entities(_caster.global_position, _caster.get_my_enemies(), _learned_skill.area_of_effect_in_tiles)

	var magic_damage: int = _caster.cache_total_stats.strength * _learned_skill.float_dict["strength_percent_damage"]
	var total_magic_damage = _caster.get_total_magic_damage(magic_damage)

	for _enemy in target_enemies:
		var _di = DamageInfo.new(total_magic_damage, _learned_skill.damage_type, _caster.name)
		_enemy.server_receive_damage(_di, _caster)
		_enemy.apply_stun(_learned_skill.float_dict["stun_duration"])

	var message := DamageType.MAGIC_EMOTI + " " + str(total_magic_damage) + " " + DamageType.MAGIC_EMOTI
	_caster.hud.show_message_popup(message.to_upper(), Color(1, 1, 1), 0.4)

	SoundsHelper.play_scream_hero_1()
	return true