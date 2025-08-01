class_name SkillSilentAgony
extends SkillBase

const NAME = "Silent Agony"
const ICON_SLOT = Vector2(9, 1)

var my_owner: Entity
var caster: Entity
var time_accumulator := 0.0
var time_interval := 0.0


func _init(_owner: Entity, _caster: Entity, p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	my_owner = _owner
	caster = _caster
	time_interval = p_learned_skill.float_dict["interval_in_seconds"]

var total_damage := 0
func process_skill(_owner: Entity, _delta: float) -> void:
	super.process_skill(_owner, _delta)
	caster = caster if ObjectHelpers.valid_instance(caster) else null

	time_accumulator += _delta
	while time_accumulator >= time_interval:
		time_accumulator -= time_interval

		if ObjectHelpers.is_null(my_owner): return
		var _di = DamageInfo.get_instance()
		_di.total_damage = learned_skill.float_dict["damage_per_interval"]
		_di.attacker_name = str(caster.name) if caster else ""
		_di.damage_type = learned_skill.damage_type
		total_damage += _di.total_damage

		my_owner.server_receive_damage(_di, caster)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [20, 40, 60] # damage per interval
	aux_array[1] = [60, 90, 120] # mana cost
	aux_array[2] = [20, 18, 16] # cooldown
	aux_array[3] = [5, 6, 7] # duration
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].cast_range_in_tiles = 7
		SKILLS[NAME].item_skill_base[i].create_effect = true
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = true
		SKILLS[NAME].item_skill_base[i].max_stacks = 3
		SKILLS[NAME].item_skill_base[i].set_silence_duration(aux_array[3][i])
		SKILLS[NAME].item_skill_base[i].float_dict["damage_per_interval"] = aux_array[0][i]
		SKILLS[NAME].item_skill_base[i].float_dict["interval_in_seconds"] = 1
		SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		SKILLS[NAME].item_skill_base[i].description = "Silences the target for " + StringHelpers.format_float(aux_array[3][i]) + " seconds, dealing " + StringHelpers.format_float(aux_array[0][i]) + " magic damage every second."

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return false

	if not verify_range(_caster, _target, _learned_skill): return false

	return _target.add_active_skill(SkillSilentAgony.new(_target, _caster, _learned_skill))
