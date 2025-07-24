class_name SkillStormWrath
extends SkillBase

const NAME = "Storm Wrath"
const ANIMATION_RECT_REGION := Rect2(64, 992, 64, 96)
const FRAMES = 14
const ICON_SLOT = Vector2(11, 0)

var skill_chain_to_exceute: ItemSkillBase
var interval: float
var seconds_elapsed_from_last_strike: float = INF

func _init(_learned_skill: ItemSkillBase, _shock_spear_learned_skill: ItemSkillBase) -> void:
	super._init(_learned_skill, true)
	skill_chain_to_exceute = _shock_spear_learned_skill
	interval = learned_skill.float_dict["strike_interval_in_seconds"]

func process_skill(_owner: Entity, _delta: float) -> void:
	super.process_skill(_owner, _delta)
	if not active: return

	seconds_elapsed_from_last_strike += _delta
	if seconds_elapsed_from_last_strike < interval: return

	seconds_elapsed_from_last_strike = 0
	apply_strike(_owner)

func apply_strike(_owner: Entity) -> void:
	var nearest_enemies := GlobalsEntityHelpers.get_closest_entities(_owner.global_position, _owner.get_my_enemies(), learned_skill.area_of_effect_in_tiles)
	if nearest_enemies.size() == 0: return

	var random_enemy_index := randi() % nearest_enemies.size()
	var random_enemy = nearest_enemies[random_enemy_index]

	SkillArcLightningStorm.try_to_use(_owner, skill_chain_to_exceute, random_enemy)


static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	aux_array[1] = [1, 1, 1] # strike interval
	aux_array[2] = [4, 5, 6] # duration
	aux_array[3] = [250, 400, 550] # mana cost
	aux_array[4] = [30, 28, 26] # cooldown
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].instant_use = true
		_SKILLS[NAME].item_skill_base[i].area_of_effect_in_tiles = 7
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[2][i]
		_SKILLS[NAME].item_skill_base[i].float_dict["strike_interval_in_seconds"] = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		_SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].cooldown = aux_array[4][i]
		_SKILLS[NAME].item_skill_base[i].description = (
			"Summons a fierce thunderstorm for "
			+ str(aux_array[2][i]) + " seconds, automatically casting " + SkillArcLightningStorm.NAME + " on random enemies every "
			+ str(aux_array[1][i]) + " second(s). Each cast replicates the full effects of the " + SkillArcLightningStorm.NAME + " skill."
		)

		
static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	var _skill_to_exceute := _caster.get_skill(SkillArcLightningStorm.NAME)
	if not _skill_to_exceute: return false
	if not _skill_to_exceute.get_learned_skill(): return false

	var skill := SkillStormWrath.new(_learned_skill, _skill_to_exceute.get_learned_skill())
	_caster.add_active_skill(skill)

	return true