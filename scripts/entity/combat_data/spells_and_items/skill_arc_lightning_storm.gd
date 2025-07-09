class_name SkillArcLightningStorm

extends SkillBase

const ANIMATION_RECT_REGION := Rect2(0, 800, 64, 64)
const FRAMES = 12
const NAME = "Arc Lightning Storm"

var interval: float = 0.1 # In seconds
var seconds_elapsed_from_last_strike: float = interval # To apply on start
var learned_skill: ItemSkillBase
var _excluded_targets: Array[Entity]
var _current_targets_count: int = 0

var _start_pos: Vector2
var _first_target_position: Vector2
var _last_target_impacted: Entity
var _last_pos_impacted: Vector2 = Vector2.ZERO

func _init(_my_owner: Entity, p_target: Entity, _learned_skill: ItemSkillBase, _activate_on_start: bool = true):
	super._init(_learned_skill.my_name, _learned_skill.duration_in_seconds, _activate_on_start)
	learned_skill = _learned_skill
	_start_pos = _my_owner.projectile_zone.global_position
	_last_pos_impacted = _my_owner.projectile_zone.global_position
	_first_target_position = p_target.projectile_zone.global_position

func process_skill(_owner: Entity, _delta: float) -> void:
	if not active: return

	if _current_targets_count >= learned_skill.max_targets:
		active = false
		return

	seconds_elapsed_from_last_strike += _delta
	if seconds_elapsed_from_last_strike < interval: return


	seconds_elapsed_from_last_strike = 0
	apply_strike(_owner)
	_current_targets_count += 1

func apply_strike(_owner: Entity) -> void:
	if _current_targets_count == 0: SoundsHelper.play_electric()

	var closest_origin = _last_target_impacted.projectile_zone.global_position if not ObjectHelpers.is_null(_last_target_impacted) else _first_target_position
	var nearest_enemies := GlobalsEntityHelpers.get_closest_entities(closest_origin, 1, _owner.get_my_enemies(), learned_skill.range_in_tiles, _excluded_targets)
	if nearest_enemies.size() == 0: return

	var next_target: Entity = nearest_enemies[0]
	_excluded_targets.append(next_target)
	
	LineEffect.spawn(GameManager.game_world.general_container, _last_pos_impacted, next_target.projectile_zone.global_position, 0.5, 0.5)
	_set_last_target_impacted(next_target)

	var total_magic_damage = _owner.get_total_magic_damage(learned_skill.float_dict["damage_per_target"])
	var _di := DamageInfo.new(total_magic_damage, learned_skill.damage_type, _owner.name)
	next_target.server_receive_damage(_di, _owner)
	next_target.apply_stun(learned_skill.float_dict["ministun_in_seconds"])

func _set_last_target_impacted(_target: Entity) -> void:
	_last_target_impacted = _target
	_last_pos_impacted = _target.position

static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 9, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)

	int_array = [40, 50, 60]
	float_array1 = [0.2, 0.4, 0.6]
	aux_array[0] = [5, 7, 9] # max targets
	int_array1 = [120, 180, 240] # mana cost
	aux_array[1] = [8, 6, 4] # cooldown
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].instant_use = false
		_SKILLS[NAME].item_skill_base[i].range_in_tiles = 20
		_SKILLS[NAME].item_skill_base[i].max_targets = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].float_dict["ministun_in_seconds"] = float_array1[i]
		_SKILLS[NAME].item_skill_base[i].float_dict["damage_per_target"] = int_array[i]
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		_SKILLS[NAME].item_skill_base[i].mana_cost = int_array1[i]
		_SKILLS[NAME].item_skill_base[i].cooldown = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].description = "Unleashes a chain lightning that starts from a target and arcs to up to " + str(aux_array[0][i]) + " nearby enemies, dealing " + StringHelpers.format_float(int_array[i]) + " magic damage and stunning each for " + StringHelpers.format_float(float_array1[i]) + " seconds."


static func try_to_use(_my_owner: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return true

	var skill := SkillArcLightningStorm.new(_my_owner, _target, _learned_skill, true)
	_my_owner.active_skills.append(skill)

	return true
