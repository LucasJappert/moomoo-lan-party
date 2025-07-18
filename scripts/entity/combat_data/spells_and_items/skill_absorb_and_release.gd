class_name SkillAbsorbAndRelease

extends SkillBase

var percent_to_release: float = 0
var radius_in_tiles: float
var damage_accumulated: float

func _init(_learned_skill: ItemSkillBase, _active_on_start: bool = false, _percent_to_release: float = 0, _radius_in_tiles: float = 1):
	super._init(_learned_skill, _active_on_start)
	percent_to_release = _percent_to_release
	radius_in_tiles = _radius_in_tiles

func activate() -> void:
	super.activate()
	damage_accumulated = 0
	seconds_elapsed = 0

func process_skill(_owner: Entity, _delta: float) -> void:
	var prev_active_value := active
	super.process_skill(_owner, _delta)

	if prev_active_value == active: return

	_apply_release(_owner, _owner)

func on_damage_received(_attacker: Entity, _damage_received: int) -> void:
	if not active: return
	if _damage_received <= 0: return

	damage_accumulated += _damage_received

func _apply_release(_attacker: Entity, _target: Entity) -> void:
	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, _attacker.get_my_enemies(), radius_in_tiles)
	var total_damage_to_release := int(damage_accumulated * percent_to_release)
	for enemy in nearest_enemies:
		enemy.server_receive_damage(DamageInfo.new(total_damage_to_release, DamageType.PHYSICAL, _attacker.name), _attacker)

	var message := DamageType.PHYSICAL_EMOTI + " " + str(total_damage_to_release) + " " + DamageType.PHYSICAL_EMOTI
	_attacker.hud.show_message_popup(message.to_upper(), Color(1, 1, 1), 0.4)
	SoundsHelper.play_scream_hero_1()


static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	const _skill_name = Skill.Names.ABSORB_AND_RELEASE
	_SKILLS[_skill_name] = Skill.new(_skill_name, SkillType.ACTIVE)
	_SKILLS[_skill_name].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 7, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)

	int_array1 = [60, 120, 180]
	float_array = [0.1, 0.15, 0.2]
	int_array = [12, 10, 8]
	for i in Skill.AVAILABLE_LEVELS:
		var seconds_to_release: float = 7.0; var effect_radius: int = 3
		_SKILLS[_skill_name].item_skill_base[i].instant_use = true
		_SKILLS[_skill_name].item_skill_base[i].area_of_effect_in_tiles = effect_radius
		_SKILLS[_skill_name].item_skill_base[i].float_dict["percent_to_release"] = float_array[i]
		_SKILLS[_skill_name].item_skill_base[i].duration_in_seconds = seconds_to_release
		_SKILLS[_skill_name].item_skill_base[i].damage_type = DamageType.PHYSICAL
		_SKILLS[_skill_name].item_skill_base[i].mana_cost = int_array1[i]
		_SKILLS[_skill_name].item_skill_base[i].cooldown = int_array[i]
		_SKILLS[_skill_name].item_skill_base[i].description = "Accumulates all damage received over " + StringHelpers.format_float(seconds_to_release) + " seconds. Then releases " + StringHelpers.format_percent(float_array[i]) + " of the accumulated damage as physical damage to all enemies within " + str(effect_radius) + " tiles."

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != Skill.Names.ABSORB_AND_RELEASE: return true

	if not super.try_to_use(_caster, _learned_skill, _target): return false

	var _percent_to_release: float = _learned_skill.float_dict["percent_to_release"]
	var skill_base := SkillAbsorbAndRelease.new(_learned_skill, true, _percent_to_release, _learned_skill.area_of_effect_in_tiles)
	_target.add_active_skill(skill_base)

	return true