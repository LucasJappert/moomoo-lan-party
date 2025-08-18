extends Entity

class_name Enemy

const DAMAGE_MODIFIER: float = 0.5 # Used to calculate the damage done to the target
static var _exp_when_dead: int = 0
var monster_sounds_helper := MonsterSoundsHelper.new()

var timer_500ms: Timer

func _ready():
	super._ready()

	_ready_for_server()
	
func _ready_for_server():
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
	
func set_enemy_type(_enemy_type: String) -> void:
	extra_info.key_type = _enemy_type

func _on_every_timer_500ms() -> void:
	var target: Entity = GlobalsEntityHelpers.get_nearest_enemy_inside_vision(self)
	if not target:
		if Moomoo.get_instance() in get_my_enemies(): target = Moomoo.get_instance()
	
	set_target_to_attack(target)

# region 	GETTERs
func get_physical_attack_power() -> int:
	return int(cache_total_stats.get_physical_attack_power() * DAMAGE_MODIFIER)
func get_magic_attack_power() -> int:
	return int(cache_total_stats.get_magic_attack_power() * DAMAGE_MODIFIER)

static func get_instance_from_dict(dict: Dictionary) -> Enemy:
	var instance = EnemyBase.get_new_instance()
	ObjectHelpers.from_dict(instance, dict)
	return instance
# endregion GETTERs

static func get_enemy_exp_when_dead() -> int:
	if _exp_when_dead > 0: return _exp_when_dead * EnemiesWavesController.current_normal_wave

	var player_total_accumulated_exp: float = Player.get_total_accumulated_exp()
	_exp_when_dead = int(player_total_accumulated_exp / EnemiesWavesController.TOTAL_ENEMIES_TO_CREATE * 0.05)

	return _exp_when_dead * EnemiesWavesController.current_normal_wave

func get_nearest_enemy_inside_vision() -> Entity:
	var closest_player: Entity
	var closest_distance := INF

	for player in GameManager.get_players():
		var dist := global_position.distance_to(player.global_position)
		if dist > vision_helper.radius_in_pixel:
			continue

		if dist < closest_distance:
			closest_distance = dist
			closest_player = player

	return closest_player
