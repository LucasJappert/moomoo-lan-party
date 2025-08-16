class_name Player

extends Entity

const INITIAL_GOLD: int = 80000
const PLAYER_CELL_SPAWN: Vector2i = Vector2i(20, 12)
static var _EXP_PER_LEVEL: Dictionary[int, int] = {}
const MAX_LEVEL: int = 30
@export var player_id: int = 0
@export var current_exp: int = 0
@export var current_gold: int:
	set(_value):
		current_gold = _value
		if current_gold > 9999: current_gold_string = StringHelpers.format_float_compact(current_gold)
		else: current_gold_string = StringHelpers.format_float(current_gold)
		if is_my_player(): SoundsHelper.play_coins()
var current_gold_string: String = ""
@export var skill_points_to_assign: int:
	set(_value):
		skill_points_to_assign = _value
		EventBus.emit_skill_points_to_assign_changed(self)
var EXTRA_INT_BY_LEVEL: int = 0
var EXTRA_STR_BY_LEVEL: int = 0
var EXTRA_AGI_BY_LEVEL: int = 0
const ATTR_PERC_EXTRA_BY_LEVEL = 0.1

func set_player(data: Dictionary) -> void:
	player_id = data["player_id"]
	extra_info.key_type = data["key_type"]
	skill_points_to_assign = 1
	level = 1
	current_gold = INITIAL_GOLD
	HeroBase.initialize_from_name(extra_info.key_type, self)
	EXTRA_INT_BY_LEVEL = round(cache_total_stats.get_intelligence() * ATTR_PERC_EXTRA_BY_LEVEL)
	EXTRA_STR_BY_LEVEL = round(cache_total_stats.get_strength() * ATTR_PERC_EXTRA_BY_LEVEL)
	EXTRA_AGI_BY_LEVEL = round(cache_total_stats.get_agility() * ATTR_PERC_EXTRA_BY_LEVEL)

func get_client_inputs(): return %ClientInputs

func _ready():
	global_position = MapManager.cell_to_world(PLAYER_CELL_SPAWN)
	super._ready()

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	if player_id == multiplayer.get_unique_id():
		MyCamera.update_camera_position(global_position)
		GameManager.set_my_player(self)

# region 	GETTERs
func is_my_player() -> bool:
	return player_id == GameManager.MY_PLAYER_ID
# endregion GETTERs

# region 	SETTERs
func increment_current_exp(value: int) -> void:
	if current_hp <= 0: return
	current_exp += value

	while level < MAX_LEVEL:
		var exp_needed := get_exp_per_level(level)
		if current_exp < exp_needed: break
		current_exp -= exp_needed
		level_up()

func increment_skill_points_to_assign(value: int) -> void:
	skill_points_to_assign = max(0, skill_points_to_assign + value)

func level_up() -> void:
	if level >= MAX_LEVEL:
		current_exp = min(current_exp, get_exp_per_level(level))
		return

	print("🎉✨ LEVEL UP! You've reached Level %d! 🚀🔥" % level)
	level += 1
	increment_skill_points_to_assign(1)
	if is_my_player(): SoundsHelper.play_level_up()
	
	var stats_to_add = CombatStats.new()
	stats_to_add.set_strength(EXTRA_STR_BY_LEVEL)
	stats_to_add.set_agility(EXTRA_AGI_BY_LEVEL)
	stats_to_add.set_intelligence(EXTRA_INT_BY_LEVEL)
	combat_stats.accumulate_info(stats_to_add.get_info())

	update_base_stats(combat_stats.get_info())
	AnimationsHelper.apply_animation(self, AnimationsHelper.ANIMATION_NAMES.LEVEL_UP)

func increment_current_gold(value_to_increment: int) -> void:
	if current_hp <= 0: return
	current_gold += value_to_increment
	statistics.add_gold(value_to_increment)
# endregion SETTERs

static func get_exp_per_level(_level: int) -> int:
	if not _EXP_PER_LEVEL.is_empty(): return _EXP_PER_LEVEL[_level]

	for i in range(1, MAX_LEVEL + 1):
		_EXP_PER_LEVEL[i] = int(floor(100 * pow(i, 1.5)))
	print("EXP_PER_LEVEL: ", _EXP_PER_LEVEL)

	return _EXP_PER_LEVEL[_level]

static func get_total_accumulated_exp() -> int:
	var total_exp = 0
	for i in range(1, MAX_LEVEL + 1):
		total_exp += get_exp_per_level(i)
	return total_exp
