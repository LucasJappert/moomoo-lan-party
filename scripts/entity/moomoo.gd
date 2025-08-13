class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)
const BODY_SCALE: float = 0.7
const LONG_NAME = "Moomoo"
const ALIAS = "The Eternal Guardian"

const _START_REGION = Vector2i(512, 864)
const _FRAME_SIZE = Vector2i(128, 128)
const _FRAMES := 2

signal life_state_promoted(previous: LifeState, current: LifeState)

var is_awake := false
enum LifeState {
    HEALTHY = 1, # 75–100%
    WOUNDED = 2, # 50–75%
    CRITICAL = 3, # 25–50%
    NEAR_DEATH = 4 # 0–25%
}
var _life_state: LifeState = LifeState.HEALTHY

func _ready():
	super._ready()
	_create_timer_500ms()

# region 	GETTERs
static func static_is_awake() -> bool:
	if ObjectHelpers.is_null(GameManager.moomoo): return false
	return GameManager.moomoo.is_awake
func get_my_enemies() -> Array[Entity]:
	if is_awake: return GameManager.get_player_allies(true)
	return GameManager.get_player_enemies()

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result
# endregion GETTERs

# region 	SETTERs
func wake_up() -> void: is_awake = true

func _create_timer_500ms() -> void:
	var timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	timer_500ms.timeout.connect(_on_every_500ms)
	add_child(timer_500ms)

func _on_every_500ms() -> void:
	if not is_awake: return

	var nearest_enemy = GlobalsEntityHelpers.get_nearest_enemy_inside_vision(self)
	set_target_to_attack(nearest_enemy)
	movement_helper.set_target_entity(nearest_enemy, MovementHelper.AttackMoveType.PhysicalAttack)
# endregion SETTERs


static func get_instance() -> Moomoo:
	var moomoo: Moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	moomoo.name = "Moomoo"
	moomoo.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i.ZERO), ALIAS)
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	moomoo.combat_stats.set_hp(10000)
	moomoo.combat_stats.set_move_speed(3)
	moomoo.combat_stats.set_attack_speed(2)
	moomoo.combat_stats.set_attack_range(CombatStats.MIN_ATTACK_RANGE)
	moomoo.combat_stats.set_magic_attack_power(200)
	moomoo.combat_stats.set_physical_attack_power(200)
	moomoo.combat_stats.set_crit_chance(0.8, 3)
	moomoo.combat_stats.set_agility(300)
	moomoo.combat_stats.set_strength(500)
	moomoo.combat_stats.set_intelligence(500)
	moomoo.combat_stats.set_evasion(0.5)
	moomoo.combat_stats.set_stun_chance(0.5, 2)
	moomoo.combat_stats.set_physical_defense_points(300)
	moomoo.combat_stats.set_magic_defense_points(300)
	moomoo.combat_stats.set_life_steal_percent(0.1)
	
	# var pain_echo_edited := SkillBase.get_skill(SkillPainEcho.NAME)
	# for i in SkillBase.AVAILABLE_LEVELS:
	# 	pain_echo_edited.item_skill_base[i].float_dict["percent_reflected"] = 0.9

	moomoo._skills.append_array([
		SkillBase.get_new_learned_skill(SkillPainEcho.NAME, 3),
		SkillBase.get_new_learned_skill(SkillBloodFury.NAME, 1),
	])

	moomoo.add_item(Item.get_item(ItemPowerCore.NAME, 1, true))

	moomoo.set_current_hp_and_mana()
	moomoo.update_base_stats(moomoo.combat_stats.get_info())
	
	return moomoo

func set_life_state(_state: LifeState) -> void: _life_state = _state

func _process(_delta: float) -> void:
	super._process(_delta)

	_update_life_state()
	
	# if state == LifeState.WOUNDED:
	# 	print("WOUNDED")
	# if state == LifeState.CRITICAL:
	# 	print("CRITICAL")
	# if state == LifeState.NEAR_DEATH:
	# 	print("NEAR DEATH")
	
func _update_life_state() -> void:
	var max_hp := maxf(get_full_health(), 1.0)
	var pct: float = clamp(current_hp / max_hp, 0.0, 1.0)

	var target := _state_from_pct(pct)
	if target <= _life_state: return # no promoción → no señal

	var prev := _life_state
	_life_state = target
	life_state_promoted.emit(prev, _life_state)
	_on_promotion(_life_state)

func _state_from_pct(pct: float) -> LifeState:
	if pct < 0.25:
		return LifeState.NEAR_DEATH
	if pct < 0.50:
		return LifeState.CRITICAL
	if pct < 0.75:
		return LifeState.WOUNDED
	return LifeState.HEALTHY

func _on_promotion(state: LifeState) -> void:
	if state == LifeState.WOUNDED:
		print("WOUNDED")
		return
	if state == LifeState.CRITICAL:
		print("CRITICAL")
		return
	if state == LifeState.NEAR_DEATH:
		print("NEAR DEATH")
		return

func actionsForHealth75To100() -> void:
	# En esta etapa el moomoo invoca esqueletos de rango y melee. Tambien le damos el hechizo de escudo
	pass
func actionsForHealth50To75() -> void:
	pass
func actionsForHealth25To50() -> void:
	# En esta etapa le damos  el hechizo de 
	pass
func actionsForHealthBelow25() -> void:
	pass
