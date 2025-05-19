class_name Enemy

extends Entity

@export var enemy_type: String

var timer_500ms: Timer

func _ready():
	super._ready()

	EnemyFactory.set_combat_data_by_enemy_type(self)

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	mov_speed = 60

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

	
func set_enemy_type(_enemy_type: String) -> void:
	enemy_type = _enemy_type

func _load_sprite():
	# TODO: Load this assets from a new module Resources
	sprite.frames = load("res://assets/enemies/" + enemy_type + ".tres")
	pass

func _process(_delta: float) -> void:
	_server_process(_delta)

func _server_process(_delta: float):
	if not multiplayer.is_server():
		return

	combat_data._try_enemy_phisical_attack(_delta)

func _on_every_timer_500ms():
	_try_set_current_path()

func _try_set_current_path():
	target_entity = _get_nearest_player_inside_vision()

	if target_entity == null:
		target_entity = GameManager.moomoo

	if target_entity == null:
		return

	if GlobalsEntityHelpers.is_target_entity_in_attack_area(self):
		current_path = []
		return

	var from_cell = AStarGridManager.world_to_cell(target_pos if target_pos != null else global_position)
	var to_cell = AStarGridManager.world_to_cell(target_entity.global_position)
	current_path = AStarGridManager.find_path(from_cell, to_cell)

func _get_nearest_player_inside_vision():
	var closest_player: Node2D = null
	var closest_distance := INF

	for player in GameManager.get_players():
		var dist = global_position.distance_to(player.global_position)
		if dist > area_vision_shape.shape.radius:
			continue

		if dist < closest_distance:
			closest_distance = dist
			closest_player = player

	return closest_player

func _get_acceptable_distance():
	return area_attack_shape.shape.radius + target_entity.collision_shape.shape.radius
