class_name SkillDeathBurst

extends SkillBase

const NAME = "Death Burst"
const ICON_SLOT = Vector2(12, 0)

const BODY_EXPLOSION_VOLUME := -10

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.2, 0.3] # % Total percentage of life to deal based on their total life
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].type = SkillType.PASSIVE
		SKILLS[NAME].item_skill_base[i].target_to_enemy = false
		SKILLS[NAME].item_skill_base[i].area_of_effect_in_tiles = 3
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.PURE
		SKILLS[NAME].item_skill_base[i].float_dict["percentage_of_life_to_deal"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].en_description = "Exlodes the body of the owner, dealing " + StringHelpers.format_percent(aux_array[0][i]) + " of their total life as magic damage to all enemies in the area."
		SKILLS[NAME].item_skill_base[i].es_description = "Hace explotar el cuerpo del portador, infligiendo " + StringHelpers.format_percent(aux_array[0][i]) + " de su vida total como daño mágico a todos los enemigos en el área."


static func actions_after_die(_owner: Entity, _killed_by: Entity) -> void:
	var _learned_skill = _owner.get_learned_skill(NAME)
	if not _learned_skill: return

	var total_damage: int = int(_owner.get_full_health() * _learned_skill.float_dict["percentage_of_life_to_deal"])
	if total_damage < 0: return

	var _di := DamageInfo.new(total_damage, DamageType.MAGIC, _owner.name)
	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_owner.global_position, _owner.get_my_enemies(), _learned_skill.area_of_effect_in_tiles)
	for enemy in nearest_enemies:
		enemy.server_receive_damage(_di, _owner)

	SoundsHelper.play_sfx("res://sounds/generals/body_explosion.wav", BODY_EXPLOSION_VOLUME, 3)