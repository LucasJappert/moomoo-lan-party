class_name Enemy

extends CharacterBody2D

static var enemy_scene = preload("res://scenes/enemy_scene.tscn")
@onready var nav_agent = $NavigationAgent2D
@export var vision_radius: float = 400.0
@onready var vision_shape = $AreaVision/CollisionShape2D
var speed: float = 100

var target_position: Vector2 = Vector2.ZERO
var timer_500ms: Timer
var player: Node2D = null

@export var id: int:
	set(id):
		id = id
		name = str(id)
		set_multiplayer_authority(1)

func _ready():
	collision_layer = 1
	collision_mask = 1

	nav_agent.radius = 32
	nav_agent.target_desired_distance = 64
	nav_agent.path_desired_distance = 32
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

	if player != null and nav_agent.is_navigation_finished() == false:
		var next_point = nav_agent.get_next_path_position()
		var direction = (next_point - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
func _on_every_timer_500ms():
	if player != null:
		if nav_agent.target_position != player.global_position:
			nav_agent.set_target_position(player.global_position)
		

func _on_area_vision_body_entered(body: Node2D) -> void:
	print("body_entered: " + body.name)
	if body is Player:
		player = body
		nav_agent.set_target_position(player.global_position)

func _on_area_vision_body_exited(body: Node2D) -> void:
	if body is not Player:
		return

	if body.name == player.name:
		player = null
		nav_agent.set_target_position(global_position)

func _set_target_position(new_target_position: Vector2) -> void:
	if (target_position - position).length() > 32:
		nav_agent.set_target_position(target_position)

	nav_agent.set_target_position(target_position)

static func spawn_enemy(moomoo_position = Vector2.ZERO):
	var TILES_DISTANCE = 10
	var ENEMIES_BY_ZONE = 4

	var counter = 0
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		for i in range(ENEMIES_BY_ZONE):
			counter += 1
			var enemy = enemy_scene.instantiate()
			enemy.id = counter
			var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
			enemy.position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
			GameManager.enemies_node.add_child(enemy)
