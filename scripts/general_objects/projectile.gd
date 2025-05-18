class_name Projectile

extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/general_objects/projectile.tscn")

@export var speed: float = 600.0
var direction := Vector2.ZERO
var target_position := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	if position.distance_to(target_position) < 10:
		queue_free()

static func launch(start_pos: Vector2, target_pos: Vector2):
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.position = start_pos
	print(start_pos, target_pos)
	projectile.target_position = target_pos
	projectile.direction = target_pos - start_pos
	projectile.rotation = projectile.direction.angle()
	GameManager.add_projectile(projectile)
