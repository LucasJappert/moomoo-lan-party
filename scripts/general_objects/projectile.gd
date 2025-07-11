class_name Projectile

extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/general_objects/projectile.tscn")

var speed: float = 400.0
var direction := Vector2.ZERO
var target_position := Vector2.ZERO
var origin_entity_name: String
var target_entity_name: String
var damage: int
var type: String
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

static var projectile_frames: Dictionary[String, SpriteFrames] = {}

func _ready():
	for registered_class in ProjectileBase.REGISTERED_CLASSES: registered_class.try_init(self)

func _get_target_entity() -> Entity:
	return GameManager.get_entity(target_entity_name)

func _get_origin_entity() -> Entity:
	return GameManager.get_entity(origin_entity_name)

func _physics_process(delta: float) -> void:
	_server_move(delta)

func _server_move(delta: float):
	if not multiplayer.is_server():
		return

	if _get_target_entity() != null:
		target_position = _get_target_entity().global_position
		direction = (target_position - position)
		rotation = direction.angle()

	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	if position.distance_to(target_position) < 10: _projectile_reached_target()

func _projectile_reached_target():
	if _get_target_entity() != null && _get_origin_entity() != null:
		_get_origin_entity().server_execute_physical_damage(_get_target_entity())
	queue_free()

static func get_instance_from_dict(dict: Dictionary) -> Projectile:
	var instance = PROJECTILE_SCENE.instantiate()
	ObjectHelpers.from_dict(instance, dict)
	return instance

static func launch(_origin: Entity, _target: Entity, _damage: int):
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.type = _origin.projectile_type
	projectile.damage = _damage
	projectile.origin_entity_name = _origin.name
	projectile.target_entity_name = _target.name
	projectile.position = _origin.projectile_zone.global_position
	projectile.target_position = _target.projectile_zone.global_position
	projectile.direction = (projectile.target_position - projectile.position).normalized()
	projectile.rotation = projectile.direction.angle()
	GameManager.add_projectile(projectile)
	projectile.queue_free()
