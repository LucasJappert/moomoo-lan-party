class_name Projectile

extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/general_objects/projectile.tscn")

var speed: float = 400.0
var direction := Vector2.ZERO
var target_position := Vector2.ZERO
var origin_entity: Entity
var target_entity: Entity
var damage: int
var _type = TYPES.ARROW
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

static var projectile_frames: Dictionary[String, SpriteFrames] = {}

const TYPES = {
	NONE = "none",
	FIREBALL = "fireball",
	ARROW = "arrow",
	DARK_BOLT = "dark_bolt",
	ICE_BOLT = "ice_bolt"
}

func set_type(type: String):
	_type = type
	if _type == TYPES.FIREBALL: speed = 300

func _ready():
	var volumen = -15.0
	if _type == TYPES.FIREBALL: volumen = -5.0
	SoundManager.play_projectile_hit(_type, volumen)

	if _type == TYPES.FIREBALL: _animated_sprite.scale = Vector2(1, 2)
	_animated_sprite.frames = _get_frames()
	_animated_sprite.play("default")

func _get_frames() -> SpriteFrames:
	if projectile_frames.has(_type): return projectile_frames[_type]

	var frames: SpriteFrames

	if _type == TYPES.FIREBALL: frames = _get_fireball_frames()
	elif _type == TYPES.ARROW: frames = _get_arrow_frames()
	else: frames = _get_fireball_frames()

	_animated_sprite.frames = frames
	_animated_sprite.play("default")
	projectile_frames[_type] = frames

	return frames

func _get_fireball_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	var rects: Array[Rect2] = [
		Rect2(Vector2(0, 288), Vector2(32, 32)),
		Rect2(Vector2(32, 288), Vector2(32, 32)),
		Rect2(Vector2(64, 288), Vector2(32, 32)),
		Rect2(Vector2(96, 288), Vector2(32, 32))
	]

	SpritesHelper._add_animation(frames, "default", rects)
	return frames

func _get_arrow_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	var rects: Array[Rect2] = [
		Rect2(Vector2(0, 256), Vector2(64, 32))
	]

	SpritesHelper._add_animation(frames, "default", rects)
	return frames

func _physics_process(delta: float) -> void:
	_server_move(delta)

func _server_move(delta: float):
	if not multiplayer.is_server():
		return

	if target_entity != null:
		target_position = target_entity.global_position
		direction = (target_position - position)
		rotation = direction.angle()

	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	if position.distance_to(target_position) < 10:
		if target_entity != null && origin_entity != null:
			origin_entity.combat_data._server_execute_physical_damage(target_entity)
		queue_free()


static func get_instance_from_dict(dict: Dictionary) -> Projectile:
	var instance = PROJECTILE_SCENE.instantiate()
	ObjectHelpers.from_dict(instance, dict)
	return instance

static func launch(_origin_entity: Entity, _target_entity: Entity, _damage: int):
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.set_type(_origin_entity.combat_data.projectile_type)
	projectile.damage = _damage
	projectile.origin_entity = _origin_entity
	projectile.target_entity = _target_entity
	projectile.position = _origin_entity.projectile_zone.global_position
	projectile.target_position = _target_entity.projectile_zone.global_position
	projectile.direction = (projectile.target_position - projectile.position).normalized()
	projectile.rotation = projectile.direction.angle()
	GameManager.add_projectile(projectile)
	projectile.queue_free()
