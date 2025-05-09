class_name Enemy

extends Entity

static var enemy_scene = preload("res://scenes/enemy_scene.tscn")
@onready var nav_agent = $NavigationAgent2D
@export var vision_radius: float = 400.0
@onready var vision_area = $AreaVision
@onready var vision_shape = $AreaVision/CollisionShape2D
var speed: float = 100

var target_position: Vector2 = Vector2.ZERO
var timer_500ms: Timer
var target_node: Node2D = null

func _ready():
	super._ready()
	collision_layer = 1
	collision_mask = 1

	# nav_agent.radius = 16
	# nav_agent.target_desired_distance = 1
	# nav_agent.path_desired_distance = 16
	# nav_agent.debug_enabled = true
	vision_shape.shape.radius = vision_radius

	timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	add_child(timer_500ms)
	timer_500ms.timeout.connect(_on_every_timer_500ms)


func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	_movement_actions()

func _movement_actions():
	if GameManager.players.size() == 0 or target_node == null:
		return

	if nav_agent.is_navigation_finished():
		return

	var distance_to_target = global_position.distance_to(target_node.global_position)
	if distance_to_target <= _get_acceptable_distance():
		nav_agent.set_target_position(global_position)
		velocity = Vector2.ZERO
		return

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	velocity = direction * speed

	move_and_slide()
	
func _on_every_timer_500ms():
	_update_nav_agent()

func _update_nav_agent():
	var closest_player = _get_nearest_player_inside_vision()
	if closest_player != null:
		target_node = closest_player

	if target_node == null:
		target_node = GameManager.moomoo

	var distance_to_target = global_position.distance_to(target_node.global_position)
	if distance_to_target <= _get_acceptable_distance():
		return

	nav_agent.set_target_position(target_node.global_position)

func _get_nearest_player_inside_vision():
	var closest_player: Node2D = null
	var closest_distance := INF

	for player in GameManager.players.values():
		var dist = global_position.distance_to(player.global_position)
		if dist > vision_radius:
			continue

		if dist < closest_distance:
			closest_distance = dist
			closest_player = player

	return closest_player

func _get_acceptable_distance():
	# return collision_shape.shape.radius + target_node.collision_shape.shape.radius + 5
	return area_attack.shape.radius + target_node.collision_shape.shape.radius

static func spawn_enemy(moomoo_position = Vector2.ZERO):
	var TILES_DISTANCE = 10
	var ENEMIES_BY_ZONE = 6
	# return

	var counter = 0
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for i in range(ENEMIES_BY_ZONE):
			counter += 1
			var enemy = enemy_scene.instantiate()
			enemy.id = counter
			var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
			enemy.position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
			GameManager.enemies_node.add_child(enemy)
