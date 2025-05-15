class_name Enemy

extends Entity

const ENEMY_SCENE = preload("res://scenes/entity/enemy_scene.tscn")

@export var vision_radius: float = 400.0
@onready var vision_area = $AreaVision
@onready var vision_shape = $AreaVision/CollisionShape2D
@export var enemy_type: String

var timer_500ms: Timer

func _ready():
	super._ready()
	mov_speed = 100
	vision_shape.shape.radius = vision_radius
	
	$Sprite2D.texture = load("res://assets/enemies/" + enemy_type + ".png")

	timer_500ms = Timer.new()
	timer_500ms.wait_time = 0.5
	timer_500ms.one_shot = false
	timer_500ms.autostart = true
	add_child(timer_500ms)
	timer_500ms.timeout.connect(_on_every_timer_500ms)

static func get_instance(_enemy_type: String) -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemy.enemy_type = _enemy_type
	return enemy

func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	super._physics_process(_delta)
	
func _on_every_timer_500ms():
	_try_set_current_path()

func _try_set_current_path():
	target_entity = _get_nearest_player_inside_vision()

	if target_entity == null:
		target_entity = GameManager.moomoo

	if target_entity == null:
		return

	if is_target_entity_in_attack_area():
		current_path = []
		return

	var from_cell = AStarGridManager.world_to_cell(target_pos if target_pos != null else global_position)
	var to_cell = AStarGridManager.world_to_cell(target_entity.global_position)
	current_path = AStarGridManager.find_path(from_cell, to_cell)

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
	return area_attack_collision_shape.shape.radius + target_entity.collision_shape.shape.radius
