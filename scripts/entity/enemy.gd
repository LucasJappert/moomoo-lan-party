extends Entity

class_name Enemy

@export var enemy_type: String
static var _exp_when_dead: int = 0

var timer_500ms: Timer

func _ready():
	super._ready()

	set_combat_data()
			
	# if _boss_level == 0: combat_data.skills.clear() # Remove skills from non-boss enemies

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

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

func set_combat_data():
	if combat_data == null: combat_data = CombatData.new()
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

	if combat_data.attack_range < CombatStats.MIN_ATTACK_RANGE:
		combat_data.attack_range = CombatStats.MIN_ATTACK_RANGE
	combat_data.current_hp = combat_data.get_total_hp()
		
	return true
	
func set_enemy_type(_enemy_type: String) -> void:
	enemy_type = _enemy_type

func _on_every_timer_500ms():
	var nearest_player = get_nearest_player_inside_vision()
	movement_helper.try_set_current_path_for_enemy(nearest_player)


static func get_enemy_exp_when_dead() -> int:
	if _exp_when_dead > 0: return _exp_when_dead

	var player_total_accumulated_exp: int = Player.get_total_accumulated_exp()
	_exp_when_dead = int(player_total_accumulated_exp / float(EnemiesWavesController.TOTAL_ENEMIES_TO_CREATE))

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
