class_name ProjectileNatureBall

extends ProjectileBase

const NAME = "nature_ball"
const RECTS: Array[Rect2] = [Rect2(Vector2(128, 288), Vector2(32, 32))]
const SPEED: float = 300
const SCALE: float = 1.2
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	_projectile.sprite.scale = Vector2.ONE * SCALE
	TweenHelper.apply_pulsing_modulate_and_scale(_projectile.sprite)
	set_frames(_projectile, RECTS)
	_projectile.sprite.play("default")
	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)

static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int) -> bool:
	if _proj_type != NAME: return false

	Projectile.launch(_entity, _target, _damage)
	return true

static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return
	for i in range(10):
		var spawn_position = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		ParticleTrail.spawn(
			_projectile.global_position + spawn_position,
			GameManager.game_world.general_container,
			0.1, Color(0, 0, 0, 0.5), 0.4
		)
	pass

# static func actions_on_reaching_target(_projectile: Projectile) -> void:
# 	if NAME != _projectile.type: return

# 	var target = _projectile.get_target_entity()
# 	if target: return ParticleTrail.spawn_explosion(Vector2.ZERO, target.projectile_zone)

# 	ParticleTrail.spawn_explosion(_projectile.global_position, GameManager.game_world.over_terrain_layer_layer_2)
# 	pass