class_name Enemy

extends Entity

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")

@onready var nav_agent = $NavigationAgent2D
@export var vision_radius: float = 400.0
@onready var vision_area = $AreaVision
@onready var vision_shape = $AreaVision/CollisionShape2D
var enemy_type: String

var target_position: Vector2 = Vector2.ZERO
var timer_500ms: Timer
var target_node: Node2D = null

func _ready():
	super._ready()
	mov_speed = 100

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

func set_sprite():
	$Sprite2D.texture = load("res://assets/enemies/" + enemy_type + ".png")

static func get_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.enemy_type = _enemy_type
	enemy.set_sprite()
	return enemy

func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	_apply_movement()

func _apply_movement():
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
	velocity = direction * mov_speed

	move_and_slide()
	
func _on_every_timer_500ms():
	_update_nav_agent()

func _update_nav_agent():
	target_node = _get_nearest_player_inside_vision()

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
