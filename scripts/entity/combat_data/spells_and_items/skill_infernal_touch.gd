class_name SkillInfernalTouch
extends SkillBase

const NAME = "Infernal Touch"
const ICON_SLOT = Vector2(11, 1)

var my_owner: Entity
var caster: Entity
var time_accumulator := 0.0
var time_interval := 1

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.1, 0.1] # % damage interval
	aux_array[1] = [5, 6, 7] # stacks
	aux_array[3] = [3, 4, 5] # duration
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].create_effect = false
		SKILLS[NAME].item_skill_base[i].target_to_enemy = true
		SKILLS[NAME].item_skill_base[i].max_stacks = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].damage_type = DamageType.PHYSICAL
		SKILLS[NAME].item_skill_base[i].float_dict["precentage_damage_per_second"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].en_description = "After each physical attack, inflicts an additional " + StringHelpers.format_percent(aux_array[0][i]) + " of the physical damage inflicted as physical damage per second for " + str(aux_array[3][i]) + " seconds."
		SKILLS[NAME].item_skill_base[i].es_description = "Después de cada ataque físico, inflige un " + StringHelpers.format_percent(aux_array[0][i]) + " del daño físico causado como daño físico por segundo durante " + str(aux_array[3][i]) + " segundos."


func _init(_owner: Entity, _caster: Entity, p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	my_owner = _owner
	caster = _caster

func process_skill(_owner: Entity, _delta: float) -> void:
	super.process_skill(_owner, _delta)
	caster = caster if ObjectHelpers.valid_instance(caster) else null

	time_accumulator += _delta
	if time_accumulator < time_interval: return

	time_accumulator = time_accumulator - time_interval

	if ObjectHelpers.is_null(my_owner): return
	var _di = DamageInfo.new(int(learned_skill.float_dict["damage_per_second"]), learned_skill.damage_type, caster)
	_di.temporal_damage = true

	my_owner.server_receive_damage(_di, caster)

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	if ObjectHelpers.is_null(_attacker): return false
	
	var infernal_touch := _attacker.get_learned_skill(NAME)
	if not infernal_touch: return false

	var damage_per_second = roundi(_di.total_damage * infernal_touch.float_dict["precentage_damage_per_second"])
	if damage_per_second == 0: damage_per_second = 1

	infernal_touch.float_dict["damage_per_second"] = damage_per_second
	if not _target.add_active_skill(SkillInfernalTouch.new(_target, _attacker, infernal_touch)): return false

	var effect := CombatEffect.get_effect_from_item_skill_base(infernal_touch, SKILLS[NAME].region_rect)
	var _description := ""
	if LanguageManager.is_english(): _description = "Inflicting " + StringHelpers.format_float(infernal_touch.float_dict["damage_per_second"]) + " damage per second for " + str(infernal_touch.duration_in_seconds) + " seconds"
	if not LanguageManager.is_english(): _description = "Infligiendo " + StringHelpers.format_float(infernal_touch.float_dict["damage_per_second"]) + " daño por segundo durante " + str(infernal_touch.duration_in_seconds) + " segundos"
	effect.set_description(_description)
	_target.effects_helper.add_effect(effect)

	return true
