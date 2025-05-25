class_name Projectile

extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/general_objects/projectile.tscn")

@export var speed: float = 400.0
var direction := Vector2.ZERO
var target_position := Vector2.ZERO
var origin_entity: Entity
var target_entity: Entity
var damage: int

func _physics_process(delta: float) -> void:
	_server_move(delta)

func _server_move(delta: float):
	if not multiplayer.is_server():
		return

	if target_entity != null:
		target_position = target_entity.projectile_zone.global_position
		direction = (target_position - position)
		rotation = direction.angle()

	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	if position.distance_to(target_position) < 10:
		if target_entity != null && origin_entity != null:
			SoundManager.play_arrow_impact()
			origin_entity.combat_data._server_calculate_physical_damage(target_entity)
		queue_free()

static func launch(_origin_entity: Entity, _target_entity: Entity, _damage: int):
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.damage = _damage
	projectile.origin_entity = _origin_entity
	projectile.target_entity = _target_entity
	projectile.position = _origin_entity.projectile_zone.global_position
	projectile.target_position = _target_entity.projectile_zone.global_position
	projectile.direction = (projectile.target_position - projectile.position).normalized()
	projectile.rotation = projectile.direction.angle()
	GameManager.add_projectile(projectile)
