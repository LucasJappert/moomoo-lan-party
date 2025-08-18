class_name EnemiesWavesController

const ENEMIES_BY_ZONE = 7
const TILES_DISTANCE_TO_MOOMOO = 9 # TODO: Set spawn points
const _WAVE_DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
static var TOTAL_ENEMIES_TO_CREATE: int = 8 * ENEMIES_BY_ZONE * _WAVE_DIRECTIONS.size()

static var current_normal_wave: int = 0
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
	# WaveInfo.new([EnemyEmberFiend.LONG_NAME], [EnemyNightArcher.LONG_NAME]), # 3
	# WaveInfo.new([EnemyWardenOfDecay.LONG_NAME], [EnemyMosswoodShaman.LONG_NAME]), # 1
	# WaveInfo.new([EnemyInfernalMinotaur.LONG_NAME], [EnemyCinderflameWielder.LONG_NAME]), # 2
	# WaveInfo.new([EnemyBoneguard.LONG_NAME], [EnemyFrostboneArcher.LONG_NAME]), # 4
	# WaveInfo.new([EnemyFrostRevenant.LONG_NAME], [EnemyFlameCultist.LONG_NAME]), # 5
	# WaveInfo.new([EnemyReflector.LONG_NAME, EnemyCrimsonWarlock.LONG_NAME], [EnemyCrimsonWarlock.LONG_NAME]), # 6
	# WaveInfo.new([EnemyBlowDigger.LONG_NAME], [EnemyRotbull.LONG_NAME]), # 7
	# WaveInfo.new([EnemyDeadShield.LONG_NAME], [EnemySilentShuriken.LONG_NAME]), # 8
]

static func start_wave_process() -> void:
	_reset_wave_process()
	process_running = true
	extra_stats_by_wave = CombatStats.new()
	EventBus.connect_to_wave_finilized(func(): _wave_finilized())

static func _reset_wave_process() -> void:
	countdown_time_in_secs = COUNTDOWN_START
	process_running = false
	current_normal_wave = 0
	current_special_wave = 0
	countdown_time_to_show = COUNTDOWN_START
	countdown_active = false
	_current_wave_info = null

static func _get_final_message() -> String:
	if LanguageManager.is_english(): return "Wave " + str(current_normal_wave + 1) + " is coming!\nLet's fight!"
	return "¡Se aproxima la oleada " + str(current_normal_wave + 1) + "!\n¡Es hora de luchar!"

static func _stop_wave_process() -> void:
	process_running = false

static func process(_delta: float) -> void:
	if not GameManager.AM_I_HOST: return
	if not process_running: return
	if not GameManager.MY_PLAYER: return
	if GameManager.get_player_enemies().size() > 0: return
	if Moomoo.is_awake(): return

	if countdown_active == false: countdown_active = true

	if countdown_active and countdown_time_in_secs <= 0:
		if current_normal_wave >= WAVES_INFO.size() and current_special_wave >= (WAVES_INFO.size() / WAVES_PER_SPECIAL_WAVE):
			if not Moomoo.get_instance(): return _stop_wave_process()
			Moomoo.get_instance().wake_up()
			# The Moomoo awakens and reveals itself against the player
			print("The Moomoo awakens and reveals itself against the player")
			return
		if current_normal_wave > WAVES_INFO.size(): return

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
	if not _try_create_special_wave(): _create_normal_wave()

	InGameDialogsManager.show(InGameDialogsManager.wave(current_normal_wave + current_special_wave - 1))


static func _create_normal_wave() -> void:
	if current_normal_wave + 1 > WAVES_INFO.size():
		return print("All waves finished!")
		
	current_normal_wave += 1
	GameManager.MY_PLAYER.statistics.set_normal_wave(current_normal_wave)
	print("Wave " + str(current_normal_wave) + " started!")

	extra_stats_by_wave.set_agility(randi_range(6, 9) * current_normal_wave)
	extra_stats_by_wave.set_strength(randi_range(6, 9) * current_normal_wave)
	extra_stats_by_wave.set_intelligence(randi_range(6, 9) * current_normal_wave)
	extra_stats_by_wave.set_physical_attack_power(randi_range(6, 11) * current_normal_wave)
	extra_stats_by_wave.set_magic_attack_power(randi_range(6, 11) * current_normal_wave)

	_current_wave_info = WAVES_INFO[current_normal_wave - 1]

	# Ejecutar lo demás de forma asíncrona
	_run_wave_spawn_async()

static var ITEMS_BY_SPECIAL_WAVE := [ # Apply after special wave 1
	ItemSkywrath.NAME,
	ItemDeadeye.NAME,
	ItemPhantomEdge.NAME,
	ItemPowerCore.NAME,
	ItemSkeletonSummonersRing.NAME,
	ItemSoulPact.NAME,
	ItemTitanGuard.NAME,
	ItemTrinityBoost.NAME
]
static var current_special_wave := 0
const WAVES_PER_SPECIAL_WAVE := 2.0
static func _try_create_special_wave() -> bool:
	if current_normal_wave < (current_special_wave + 1) * WAVES_PER_SPECIAL_WAVE: return false
	
	current_special_wave += 1
	GameManager.MY_PLAYER.statistics.set_special_wave(current_special_wave)
	print("🎉 Special wave " + str(current_special_wave) + " started! ")

	var available_enemies: Array[String] = []
	for i in range(current_special_wave * WAVES_PER_SPECIAL_WAVE, (current_special_wave + 1) * WAVES_PER_SPECIAL_WAVE):
		available_enemies.append_array(WAVES_INFO[i % WAVES_INFO.size()].common_enemies)
		available_enemies.append_array(WAVES_INFO[i % WAVES_INFO.size()].boss_enemies)

	for i in range(2):
		for wave_direction in _WAVE_DIRECTIONS:
			var enemy_type = available_enemies[randi() % available_enemies.size()]

			var boss_enemy = _get_enemy(enemy_type, wave_direction, true)
			var extra_stats := CombatStats.new()
			extra_stats.accumulate_info(extra_stats_by_wave.get_info())
			extra_stats.accumulate_info(extra_stats_by_wave.get_info())
			boss_enemy.combat_stats.accumulate_info(extra_stats.get_info())
			GlobalsEntityHelpers.grants_random_skills(boss_enemy, min(3, current_special_wave))
			
			boss_enemy.set_current_hp_and_mana()

			# Adding items in certain special waves
			if current_special_wave > 3:
				boss_enemy.update_item(Item.get_item(ITEMS_BY_SPECIAL_WAVE[randi() % ITEMS_BY_SPECIAL_WAVE.size()], 1, true), 4)
				boss_enemy.update_item(Item.get_item(ITEMS_BY_SPECIAL_WAVE[randi() % ITEMS_BY_SPECIAL_WAVE.size()], 1, true), 5)
			elif current_special_wave > 1:
				boss_enemy.update_item(Item.get_item(ITEMS_BY_SPECIAL_WAVE[randi() % ITEMS_BY_SPECIAL_WAVE.size()], 1, true), 5)

			# enemy.can_attack = false
			GameManager.spawn_enemy(boss_enemy)

			if available_enemies.size() <= 1: continue

			available_enemies.erase(enemy_type)
	return true

	
static func _run_wave_spawn_async() -> void:
	await _spawn_wave_enemies()


static func _spawn_wave_enemies() -> void:
	for i in range(ENEMIES_BY_ZONE):
		for wave_direction in _WAVE_DIRECTIONS:
			var enemy_type = ""
			var is_boss = i == 0

			if is_boss:
				enemy_type = _current_wave_info.boss_enemies[randi() % _current_wave_info.boss_enemies.size()]
			else:
				enemy_type = _current_wave_info.common_enemies[randi() % _current_wave_info.common_enemies.size()]

			var enemy = _get_enemy(enemy_type, wave_direction, is_boss)
			# enemy.update_item(Item.get_item(ItemSkywrath.NAME, 1, true), 0)
			# enemy.can_attack = false
			GameManager.spawn_enemy(enemy)
			await GameManager.game_world.get_tree().create_timer(0.01).timeout
			# return

static func _get_enemy(enemy_type: String, wave_direction: Vector2, is_boss: bool) -> Enemy:
	var enemy: Enemy = EnemyBase.get_new_instance(enemy_type)

	var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
	var position = Moomoo.get_instance().global_position + wave_direction * TILES_DISTANCE_TO_MOOMOO * 64 + random_noise
	var cell = MapManager.world_to_cell(position)
	cell = MapManager.get_safe_cell(cell)
	enemy.global_position = MapManager.cell_to_world(cell)

	enemy.level = current_normal_wave
	enemy._boss_level = current_normal_wave if is_boss else 0

	enemy.combat_stats.accumulate_info(extra_stats_by_wave.get_info())
	if enemy._boss_level: enemy.combat_stats.accumulate_info(extra_stats_by_wave.get_info())

	for skill in enemy._skills:
		if not skill: continue
		skill.learned_level = min(int(((current_normal_wave - 1) / float(4))) + 1, 3)
		# skill.learned_level = min(int(((current_normal_wave - 1) / float(WAVES_INFO.size()))) + 1, 3)

	enemy.combat_stats.set_attack_speed(round(enemy.combat_stats.get_attack_speed() * (1.0 + randf_range(-0.05, 0.05)) * 100.0) / 100.0)

	enemy.set_current_hp_and_mana()

	return enemy

static func _wave_finilized() -> void:
	for player in GameManager.get_players():
		player.increment_current_gold(get_gold_earned_by_wave())

static func get_gold_earned_by_wave() -> int:
	return current_normal_wave * Player.INITIAL_GOLD

static func get_gold_earned_by_enemy() -> int:
	return int(get_gold_earned_by_wave() / float(ENEMIES_BY_ZONE * _WAVE_DIRECTIONS.size()))