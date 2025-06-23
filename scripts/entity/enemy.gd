extends Entity

class_name Enemy

@export var enemy_type: String
static var _exp_when_dead: int = 0
var monster_sounds_helper = MonsterSoundsHelper.new()

var timer_500ms: Timer

func _ready():
	super._ready()

	set_combat_data()
			
	# if _boss_level == 0: combat_data.skills.clear() # Remove skills from non-boss enemies

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	_ready_for_server()
	
func _ready_for_server():
	_set_next_cast_delay()

	if not multiplayer.is_server():
		return
	timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	timer_500ms.timeout.connect(_on_every_timer_500ms)
	add_child(timer_500ms)

func _process(_delta: float) -> void:
	super._process(_delta)
	monster_sounds_helper.try_to_play_boss_sound(self, _delta)

func set_combat_data():
	match enemy_type:
		EnemyTypes.FROST_REVENANT:
			EnemyFactory.set_frost_revenant(self)
		EnemyTypes.WARDEN_OF_DECAY:
			EnemyFactory.set_warden_of_decay(self)
		EnemyTypes.FLAME_CULTIST:
			EnemyFactory.set_flame_cultist(self)
		_:
			print("Unknown enemy type: " + enemy_type)
			return false

	if combat_data.stats.attack_range < CombatStats.MIN_ATTACK_RANGE:
		combat_data.stats.attack_range = CombatStats.MIN_ATTACK_RANGE
	combat_data.update_cache_total_stats()
	combat_data.current_hp = combat_data.get_total_hp()
		
	return true
	
func set_enemy_type(_enemy_type: String) -> void:
	enemy_type = _enemy_type

func _on_every_timer_500ms() -> void:
	var target: Entity = GameManager.moomoo
	var nearest_player = get_nearest_player_inside_vision()
	if nearest_player: target = nearest_player
	
	combat_data.set_target_entity(target)
	movement_helper.set_target_entity(target)

# region 	GETTERs

static func get_instance_from_dict(dict: Dictionary) -> Enemy:
	var instance = EnemyFactory.get_enemy_instance()
	ObjectHelpers.from_dict(instance, dict)
	return instance
# endregion GETTERs

static func get_enemy_exp_when_dead() -> int:
	if _exp_when_dead > 0: return _exp_when_dead

	var player_total_accumulated_exp: float = Player.get_total_accumulated_exp()
	_exp_when_dead = int(player_total_accumulated_exp / EnemiesWavesController.TOTAL_ENEMIES_TO_CREATE * 0.05)

	return _exp_when_dead

func get_nearest_player_inside_vision() -> Entity:
	var closest_player: Entity
	var closest_distance := INF

	for player in GameManager.get_players():
		var dist = global_position.distance_to(player.global_position)
		if dist > area_vision_shape.shape.radius:
			continue

		if dist < closest_distance:
			closest_distance = dist
			closest_player = player

	return closest_player

# region TRY SKILL USE
var cast_timer: float = 0.0
var next_cast_delay: float = 0.0
func _set_next_cast_delay():
	# Ejemplo: nivel 1 = casteo cada 4~6s, nivel 10 = casteo cada 1~2s
	var min_delay = lerp(6.0, 2.0, clamp(level / 10.0, 0, 1))
	var max_delay = lerp(8.0, 3.0, clamp(level / 10.0, 0, 1))
	next_cast_delay = randf_range(min_delay, max_delay)

func try_cast_random_skill():
	var available_skills = combat_data._skills.filter(func(s): return s.can_use(self))

	if available_skills.size() == 0:
		return

	var skill_to_cast = available_skills[randi() % available_skills.size()]
	skill_to_cast.use(self)