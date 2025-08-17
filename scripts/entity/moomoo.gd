class_name Moomoo

extends Entity

const SPAWN_POSITION = Vector2i(20, 11)
const BODY_SCALE: float = 0.7
const LONG_NAME = "Moomoo"
const ALIAS = "The Eternal Guardian"
const EFFECT_SCALE: float = 1.8

const _START_REGION = Vector2i(512, 864)
const _FRAME_SIZE = Vector2i(128, 128)
const _FRAMES := 2

signal life_state_promoted(previous: LifeState, current: LifeState)

static var instance: Moomoo
var _is_awake := false
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
static func is_awake() -> bool:
	if not get_instance(): return false
	return get_instance()._is_awake
func get_my_enemies() -> Array[Entity]:
	if is_awake(): return GameManager.get_player_allies(true)
	return GameManager.get_player_enemies()

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result

static func get_instance() -> Moomoo: return ObjectHelpers.get_safe_instance(instance)
# endregion GETTERs

# region 	SETTERs
func wake_up() -> void:
	_is_awake = true
	
	update_skill(SkillBase.get_new_learned_skill(SkillBurningPresence.NAME, 3), 1)
	update_skill(SkillBase.get_new_learned_skill(SkillPainEcho.NAME, 3), 2)
	update_skill(SkillBase.get_new_learned_skill(SkillShieldedCore.NAME, 3), 3)
	update_skill(SkillBase.get_new_learned_skill(SkillBlessingOfPower.NAME, 3), 4)

	update_item(Item.get_item(ItemSkywrath.NAME, 1, true), 0)
	# update_item(Item.get_item(ItemSkeletonSummonersRing.NAME, 1, true), 0)
	update_item(Item.get_item(ItemCleaveEdge.NAME, 1, true), 1)

	set_current_hp_and_mana()
	update_base_stats(combat_stats.get_info())

func _create_timer_500ms() -> void:
	var timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	timer_500ms.timeout.connect(_on_every_500ms)
	add_child(timer_500ms)

func _on_every_500ms() -> void:
	if not is_awake(): return

	var nearest_enemy = GlobalsEntityHelpers.get_nearest_enemy_inside_vision(self)
	set_target_to_attack(nearest_enemy)
	movement_helper.set_target_entity(nearest_enemy, MovementHelper.AttackMoveType.PhysicalAttack)
# endregion SETTERs


static func get_new_instance() -> Moomoo:
	var moomoo: Moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	moomoo.name = "Moomoo"
	moomoo.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i.ZERO), ALIAS)
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	moomoo.combat_stats.set_hp(50000)
	moomoo.combat_stats.set_move_speed(2)
	moomoo.combat_stats.set_attack_speed(1.2)
	moomoo.combat_stats.set_attack_range(CombatStats.MIN_ATTACK_RANGE)
	moomoo.combat_stats.set_magic_attack_power(100)
	moomoo.combat_stats.set_physical_attack_power(100)
	moomoo.combat_stats.set_crit_chance(0.2, 4)
	moomoo.combat_stats.set_agility(100)
	moomoo.combat_stats.set_strength(200)
	moomoo.combat_stats.set_intelligence(150)
	moomoo.combat_stats.set_evasion(0.2)
	moomoo.combat_stats.set_stun_chance(0.25, 2)
	moomoo.combat_stats.set_physical_defense_points(200)
	moomoo.combat_stats.set_magic_defense_points(200)
	moomoo.combat_stats.set_life_steal_percent(0.1)

	moomoo.set_current_hp_and_mana()
	moomoo.update_base_stats(moomoo.combat_stats.get_info())
	
	return moomoo

func set_life_state(_state: LifeState) -> void: _life_state = _state

func _process(_delta: float) -> void:
	super._process(_delta)
	if not is_awake(): return
	
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
		update_skill(SkillBase.get_new_learned_skill(SkillTrueStrike.NAME, 3), 1)
		update_skill(SkillBase.get_new_learned_skill(SkillShockSpear.NAME, 3), 2)
		update_skill(SkillBase.get_new_learned_skill(SkillAbsorbAndRelease.NAME, 3), 3)
		update_skill(SkillBase.get_new_learned_skill(SkillBurningPresence.NAME, 3), 4)

		update_item(Item.get_item(ItemTrinityBoost.NAME, 1, true), 2)
		update_item(Item.get_item(ItemSoulPact.NAME, 1, true), 3)
		return
	if state == LifeState.CRITICAL:
		print("CRITICAL")
		update_skill(SkillBase.get_new_learned_skill(SkillStunningStrike.NAME, 3), 1)
		update_skill(SkillBase.get_new_learned_skill(SkillBloodFury.NAME, 3), 2)
		update_skill(SkillBase.get_new_learned_skill(SkillCleaveStrike.NAME, 3), 3)
		update_skill(SkillBase.get_new_learned_skill(SkillEarthshatter.NAME, 3), 4)

		update_item(Item.get_item(ItemTitanGuard.NAME, 1, true), 4)
		update_item(Item.get_item(ItemSkeletonSummonersRing.NAME, 1, true), 5)
		return
	if state == LifeState.NEAR_DEATH:
		update_skill(SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME, 3), 1)
		update_skill(SkillBase.get_new_learned_skill(SkillPainEcho.NAME, 3), 2)
		update_skill(SkillBase.get_new_learned_skill(SkillSilentAgony.NAME, 3), 3)
		update_skill(SkillBase.get_new_learned_skill(SkillUnbreakable.NAME, 3), 4)
		
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
