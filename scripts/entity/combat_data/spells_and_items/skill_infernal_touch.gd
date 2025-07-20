class_name SkillInfernalTouch
extends SkillBase

const NAME = "Infernal Touch"
const ICON_SLOT = Vector2(11, 1)

var my_owner: Entity
var caster: Entity
var time_accumulator := 0.0
var time_interval := 1

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [0.1, 0.1, 0.1] # % damage interval
	aux_array[1] = [5, 6, 7] # stacks
	aux_array[3] = [3, 4, 5] # duration
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 0
		_SKILLS[NAME].item_skill_base[i].create_effect = false
		_SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		_SKILLS[NAME].item_skill_base[i].max_stacks = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.PHYSICAL
		_SKILLS[NAME].item_skill_base[i].float_dict["precentage_damage_per_second"] = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].description = "After each physical attack, inflicts an additional " + StringHelpers.format_percent(aux_array[0][i]) + " of the physical damage inflicted as physical damage per second for " + str(aux_array[3][i]) + " seconds."

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
	var _di = DamageInfo.get_instance()
	_di.total_damage = learned_skill.float_dict["damage_per_second"]
	_di.attacker_name = str(caster.name) if caster else ""
	_di.damage_type = learned_skill.damage_type
	_di.temporal_damage = true

	my_owner.server_receive_damage(_di, caster)

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if _di.was_reflected or _di.was_a_cleave_damage or _di.temporal_damage: return false
	
	var infernal_touch := _attacker.get_learned_skill(NAME)
	if not infernal_touch: return false

	var damage_per_second = roundi(_di.total_damage * infernal_touch.float_dict["precentage_damage_per_second"])
	if damage_per_second == 0: return false

	infernal_touch.float_dict["damage_per_second"] = damage_per_second
	_target.add_active_skill(SkillInfernalTouch.new(_target, _attacker, infernal_touch))

	var effect := CombatEffect.get_effect_from_item_skill_base(infernal_touch)
	effect.set_description("Inflicting " + StringHelpers.format_float(infernal_touch.float_dict["damage_per_second"]) + " damage per second for " + str(infernal_touch.duration_in_seconds) + " seconds")
	_target.effects_helper.add_effect(effect)

	return true
