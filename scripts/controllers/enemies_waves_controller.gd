class_name EnemiesWavesController

const ENEMIES_BY_ZONE = 7
const TOTAL_WAVES = 20
const TILES_DISTANCE_TO_MOOMOO = 9 # TODO: Set spawn points
const _WAVE_DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
static var TOTAL_ENEMIES_TO_CREATE: int = TOTAL_WAVES * ENEMIES_BY_ZONE * _WAVE_DIRECTIONS.size()

static var current_wave: int = 0
static var _current_wave_info: WaveInfo

static var COUNTDOWN_START := 10
static var countdown_time_in_secs: float = COUNTDOWN_START
static var countdown_time_to_show: int
static var countdown_active := false
static var process_running := false

static var extra_stats_by_wave: CombatStats

class WaveInfo:
	var common_enemies: Array[String]
	var boss_enemies: Array[String]
	func _init(p_common_enemies: Array[String], p_boss_enemies: Array[String]):
		common_enemies = p_common_enemies
		boss_enemies = p_boss_enemies

static var WAVES_INFO = [
	WaveInfo.new([EnemyWardenOfDecay.LONG_NAME], [EnemyMosswoodShaman.LONG_NAME]),
	WaveInfo.new([EnemyEmberFiend.LONG_NAME], [EnemyCinderflameWielder.LONG_NAME]),
	WaveInfo.new([EnemyBoneguard.LONG_NAME], [EnemyFrostboneArcher.LONG_NAME]),
	WaveInfo.new([EnemyFrostRevenant.LONG_NAME], [EnemyFlameCultist.LONG_NAME]),
	WaveInfo.new([EnemyInfernalMinotaur.LONG_NAME], [EnemyNightArcher.LONG_NAME]),
]

static func start_wave_process() -> void:
	_reset_wave_process()
	process_running = true
	extra_stats_by_wave = CombatStats.new()
	EventBus.connect_to_wave_finilized(func(): _wave_finilized())

static func _reset_wave_process() -> void:
	process_running = false
	current_wave = 0
	countdown_time_to_show = COUNTDOWN_START
	countdown_active = false
	_current_wave_info = null

static func _get_final_message() -> String:
	return "Wave " + str(current_wave + 1) + " is coming!\nLet's fight!"

static func _process(_delta: float) -> void:
	if not GameManager.AM_I_HOST: return
	if not process_running: return
	if not GameManager.MY_PLAYER: return
	if GameWorld.current_enemies_in_scene > 0: return

	if countdown_active == false: countdown_active = true

	if countdown_active and countdown_time_in_secs <= 0:
		if current_wave > TOTAL_WAVES: return

		countdown_active = false
		countdown_time_in_secs = COUNTDOWN_START
		countdown_time_to_show = COUNTDOWN_START
		return create_next_wave()

	countdown_time_in_secs -= _delta
	if int(countdown_time_in_secs) != countdown_time_to_show:
		countdown_time_to_show = int(countdown_time_in_secs)
		var message = str(countdown_time_to_show)
		if countdown_time_to_show == 0: message = _get_final_message()
		CountdownScene.show_countdown_number(message, countdown_time_to_show == 0)

static func skip_countdown() -> void:
	countdown_time_in_secs = 0.01 # ✅ un poco mayor a 0 para que _process reste y lo lleve a 0
	countdown_time_to_show = 1 # ✅ fuerza el cambio a 0 en el siguiente frame

static func create_next_wave() -> void:
	current_wave += 1
	GameManager.MY_PLAYER.statistics.set_wave(current_wave)
	print("Wave " + str(current_wave) + " started!")

	extra_stats_by_wave.agility = 5 * current_wave
	extra_stats_by_wave.strength = 5 * current_wave
	extra_stats_by_wave.intelligence = 5 * current_wave

	_current_wave_info = WAVES_INFO[current_wave % WAVES_INFO.size() - 1]

	for wave_direction in _WAVE_DIRECTIONS:
		for i in range(ENEMIES_BY_ZONE):
			var enemy_type = ""
			var is_boss = i == 0

			if is_boss: enemy_type = _current_wave_info.boss_enemies[randi() % _current_wave_info.boss_enemies.size()]
			else: enemy_type = _current_wave_info.common_enemies[randi() % _current_wave_info.common_enemies.size()]

			var enemy = _get_enemy(enemy_type, wave_direction, is_boss)

			# enemy.can_attack = false
			GameManager.spawn_enemy(enemy)
		return

static func _get_enemy(enemy_type: String, wave_direction: Vector2, is_boss: bool) -> Enemy:
	var enemy: Enemy = EnemyBase.get_new_instance(enemy_type)

	var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
	var position = GameManager.moomoo.global_position + wave_direction * TILES_DISTANCE_TO_MOOMOO * 64 + random_noise
	var cell = MapManager.world_to_cell(position)
	cell = MapManager.get_safe_cell(cell)
	enemy.global_position = MapManager.cell_to_world(cell)

	enemy.level = current_wave
	enemy._boss_level = current_wave if is_boss else 0

	enemy.combat_stats.accumulate_combat_stats(extra_stats_by_wave)
	if enemy._boss_level: enemy.combat_stats.accumulate_combat_stats(extra_stats_by_wave)

	enemy.combat_stats.attack_speed = round(enemy.combat_stats.attack_speed * (1.0 + randf_range(-0.05, 0.05)) * 100.0) / 100.0

	enemy.set_current_hp_and_mana()
	enemy.update_cache_total_stats()

	return enemy

static func _wave_finilized() -> void:
	for player in GameManager.get_players():
		var earned_gold = current_wave * Player.INITIAL_GOLD * 3
		player.increment_current_gold(earned_gold)