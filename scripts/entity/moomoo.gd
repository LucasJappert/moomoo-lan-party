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

const MOOMOO_PROMOTION_WAV := "res://sounds/moomoo/promotion.wav"
const MOOMOO_BREATH_WAV := "res://sounds/moomoo/breath.wav"

const _NOISE_WHEN_AWAKE := MapManager.TILE_SIZE_INT * 7
var _NOISE := MapManager.TILE_SIZE_INT * 10
var _effects_per_second: float = 0.2
const _EFFECTS_PER_SECONDS_WHEN_PLAYER_LOSES: float = 20
var _NOISE_WHEN_PLAYER_LOSES := _NOISE * 2
const _EFFECTS_EXTRA_PER_STATE: float = 0.5
const _EFFECT_LIFETIME: float = 10.0
const _NOISE_RADIUS: int = MapManager.TILE_SIZE_INT * 10
var _spawn_budget: float = 0.0 # única variable de estado

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
	EventBus.connect_to_entity_died(_verify_moomoo_died)

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

static func apply_breath_sound() -> void: SoundsHelper.play_sfx(MOOMOO_BREATH_WAV)
# endregion GETTERs

# region 	SETTERs
var _is_awaking: bool = false
func wake_up() -> void:
	if _is_awaking: return
	_is_awaking = true

	_spawn_wave_up_effects()

	InGameDialogsManager.show(InGameDialogsManager.moomoo_wake_up())

	# Esperar 2 segundos antes de marcar como despierto
	await get_tree().create_timer(2.0).timeout
	_is_awake = true
	_effects_per_second += _EFFECTS_EXTRA_PER_STATE
	_NOISE = _NOISE_WHEN_AWAKE
	
	update_skill(SkillBase.get_new_learned_skill(SkillBurningPresence.NAME, 3), 1)
	update_skill(SkillBase.get_new_learned_skill(SkillPainEcho.NAME, 3), 2)
	update_skill(SkillBase.get_new_learned_skill(SkillShieldedCore.NAME, 3), 3)
	update_skill(SkillBase.get_new_learned_skill(SkillBlessingOfPower.NAME, 3), 4)

	update_item(Item.get_item(ItemSkywrath.NAME, 1, true), 0)
	update_item(Item.get_item(ItemCleaveEdge.NAME, 1, true), 1)

	set_current_hp_and_mana()
	update_base_stats(combat_stats.get_info())
	GlobalsEntityHelpers.set_group(self)

func _spawn_wave_up_effects() -> void:
	SoundsHelper.play_sfx(MOOMOO_PROMOTION_WAV, 0, 2)
	for i in range(10):
		var noise := MapManager.TILE_SIZE_INT * 1
		var pos := Vector2(randi_range(-noise, noise), randi_range(-noise, noise))
		SmokeHelper.spawn_awaken_smoke_burst(GameManager.game_world.over_terrain_layer_layer_2, global_position + pos)
		
		for t in range(6):
			pos = Vector2(randi_range(-noise, noise), randi_range(-noise, noise))
			SmokeHelper.spawn_volcanic_sparks(GameManager.game_world.over_terrain_layer_layer_2, global_position + pos)
			
func _spawn_on_promotion_effects() -> void:
	for i in range(5):
		var noise := MapManager.TILE_SIZE_INT * 1
		var pos := Vector2(randi_range(-noise, noise), randi_range(-noise, noise))
		SmokeHelper.spawn_awaken_smoke_burst(GameManager.game_world.over_terrain_layer_layer_2, global_position + pos)
		
		for t in range(3):
			pos = Vector2(randi_range(-noise, noise), randi_range(-noise, noise))
			SmokeHelper.spawn_volcanic_sparks(GameManager.game_world.over_terrain_layer_layer_2, global_position + pos)

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

func _verify_moomoo_died(_entitiy_died: Entity, _killed_by: Entity) -> void:
	if not _entitiy_died is Player: return

	_effects_per_second = _EFFECTS_PER_SECONDS_WHEN_PLAYER_LOSES


# endregion SETTERs


static func get_new_instance() -> Moomoo:
	var moomoo: Moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	moomoo.name = "Moomoo"
	moomoo.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i.ZERO), ALIAS)
	moomoo.global_position = MapManager.cell_to_world(MapManager.get_safe_cell(SPAWN_POSITION))
	moomoo.combat_stats.set_hp(80000)
	moomoo.combat_stats.set_mana(500000)
	moomoo.combat_stats.set_hp_regeneration_points(200)
	moomoo.combat_stats.set_mana_regeneration_points(400)
	moomoo.combat_stats.set_move_speed(2)
	moomoo.combat_stats.set_attack_speed(1.2)
	moomoo.combat_stats.set_attack_range(CombatStats.MIN_ATTACK_RANGE)
	moomoo.combat_stats.set_magic_attack_power(100)
	moomoo.combat_stats.set_physical_attack_power(100)
	moomoo.combat_stats.set_crit_chance(0.2, 4)
	moomoo.combat_stats.set_agility(100)
	moomoo.combat_stats.set_strength(200)
	moomoo.combat_stats.set_intelligence(350)
	moomoo.combat_stats.set_evasion(0.2)
	moomoo.combat_stats.set_stun_chance(0.1, 2)
	moomoo.combat_stats.set_physical_defense_points(400)
	moomoo.combat_stats.set_magic_defense_points(400)
	moomoo.combat_stats.set_life_steal_percent(0.1)

	moomoo.set_current_hp_and_mana()
	moomoo.update_base_stats(moomoo.combat_stats.get_info())
	
	return moomoo

func set_life_state(_state: LifeState) -> void: _life_state = _state

func _process(_delta: float) -> void:
	super._process(_delta)
	_try_spawn_floor_effects(_delta)

	if not is_awake(): return
	
	_update_life_state()
	
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
	_spawn_on_promotion_effects()
	_effects_per_second += _EFFECTS_EXTRA_PER_STATE
	SoundsHelper.play_sfx(MOOMOO_PROMOTION_WAV, 0, 2)
	if state == LifeState.WOUNDED:
		InGameDialogsManager.show(InGameDialogsManager.boss_hp_75())
		print("WOUNDED")
		update_skill(SkillBase.get_new_learned_skill(SkillTrueStrike.NAME, 3), 1)
		update_skill(SkillBase.get_new_learned_skill(SkillShockSpear.NAME, 3), 2)
		update_skill(SkillBase.get_new_learned_skill(SkillAbsorbAndRelease.NAME, 3), 3)
		update_skill(SkillBase.get_new_learned_skill(SkillBurningPresence.NAME, 3), 4)

		update_item(Item.get_item(ItemTrinityBoost.NAME, 1, true), 2)
		update_item(Item.get_item(ItemSoulPact.NAME, 1, true), 3)
		return
	if state == LifeState.CRITICAL:
		InGameDialogsManager.show(InGameDialogsManager.boss_hp_50())
		print("CRITICAL")
		update_skill(SkillBase.get_new_learned_skill(SkillStunningStrike.NAME, 3), 1)
		update_skill(SkillBase.get_new_learned_skill(SkillBloodFury.NAME, 3), 2)
		update_skill(SkillBase.get_new_learned_skill(SkillCleaveStrike.NAME, 3), 3)
		update_skill(SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME, 3), 4)

		update_item(Item.get_item(ItemTitanGuard.NAME, 1, true), 4)
		update_item(Item.get_item(ItemSkeletonSummonersRing.NAME, 1, true), 5)
		return
	if state == LifeState.NEAR_DEATH:
		InGameDialogsManager.show(InGameDialogsManager.boss_hp_25())
		update_skill(SkillBase.get_new_learned_skill(SkillEarthshatter.NAME, 3), 1)
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

# region 	FLOOR EFFECTS SPAWNER
func _try_spawn_floor_effects(delta: float) -> void:
	_spawn_budget += _effects_per_second * max(delta, 0.0)

	# spawnea la parte entera del presupuesto
	var to_spawn := int(_spawn_budget)
	if to_spawn <= 0:
		return

	_spawn_budget -= float(to_spawn)
	for i in to_spawn: _create_effect()

func _create_effect() -> void:
	var _noise := _NOISE if GameManager.PLAYER_WIN else _NOISE_WHEN_PLAYER_LOSES
	var random_pos := global_position + Vector2(randi_range(-_noise, _noise), randi_range(-_noise, _noise))
	var cell := MapManager.world_to_cell(random_pos)
	TileHazardManager.add_hazard(cell, _EFFECT_LIFETIME, 0.5, func(): TileHazardManager.on_hazard_tick_apply_damage_to_allies_of_player(cell))

	random_pos = global_position + Vector2(randi_range(-_noise, _noise), randi_range(-_noise, _noise))
	SmokeHelper.spawn_volcanic_sparks(GameManager.game_world.over_terrain_layer_layer_2, random_pos)
	

# endregion 	FLOOR EFFECTS SPAWNER