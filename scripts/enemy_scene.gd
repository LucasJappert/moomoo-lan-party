class_name Enemy

extends CharacterBody2D

static var enemy_scene = preload("res://scenes/enemy_scene.tscn")
@onready var nav_agent = $NavigationAgent2D
@onready var collision_shape = $CollisionShape2D
@export var vision_radius: float = 400.0
@onready var vision_area = $AreaVision
@onready var vision_shape = $AreaVision/CollisionShape2D
var speed: float = 100

var target_position: Vector2 = Vector2.ZERO
var timer_500ms: Timer
var target_node: Node2D = null

@export var id: int:
	set(value):
		id = value
		print("ID: " + str(id))
		name = str(id)
		set_multiplayer_authority(1)

func _ready():
	collision_layer = 1
	collision_mask = 1

	# nav_agent.radius = 16
	# nav_agent.target_desired_distance = 1
	# nav_agent.path_desired_distance = 16
	nav_agent.debug_enabled = true
	vision_shape.shape.radius = vision_radius

	timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	add_child(timer_500ms)
	timer_500ms.timeout.connect(_on_every_timer_500ms)

func _process(_delta):
	$HUD/Label.text = str(id)

func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	if GameManager.players.size() == 0 or target_node == null:
		return

	var distance_to_target = global_position.distance_to(target_node.global_position)
	var acceptable_distance = collision_shape.shape.radius + target_node.collision_shape.shape.radius + 5
	if distance_to_target <= acceptable_distance:
		nav_agent.set_target_position(global_position)
		return

	if nav_agent.is_navigation_finished() == false:
		var next_point = nav_agent.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
func _on_every_timer_500ms():
	_update_nav_agent()
		

func _on_area_vision_body_entered(body: Node2D) -> void:
	if body is Player:
		_update_target()


func _on_area_vision_body_exited(body: Node2D) -> void:
	if body == target_node:
		target_node = null
		_update_target()

func _update_target():
	var closest: Node2D = null
	var closest_distance := INF

	for body in vision_area.get_overlapping_bodies():
		if body is Player:
			var dist = global_position.distance_to(body.global_position)
			if dist < closest_distance:
				closest_distance = dist
				closest = body

	target_node = closest

func _update_nav_agent():
	if target_node == null:
		nav_agent.set_target_position(GameManager.moomoo.global_position)
		return

	if nav_agent.target_position != target_node.global_position:
		nav_agent.set_target_position(target_node.global_position)

static func spawn_enemy(moomoo_position = Vector2.ZERO):
	var TILES_DISTANCE = 10
	var ENEMIES_BY_ZONE = 6

	var counter = 0
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for i in range(ENEMIES_BY_ZONE):
			counter += 1
			var enemy = enemy_scene.instantiate()
			enemy.id = counter
			var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
			enemy.position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
			GameManager.enemies_node.add_child(enemy)
