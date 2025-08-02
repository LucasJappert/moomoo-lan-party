class_name ProjectileShuriken

extends ProjectileBase

const NAME = "shuriken"
const RECTS: Array[Rect2] = [Rect2(Vector2(288, 288), Vector2(32, 32))]
const SPEED: float = 400
const SCALE: float = 0.8
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	_projectile.sprite.scale = Vector2.ONE * SCALE
	TweenHelper.apply_rotation_loop(_projectile.sprite)
	set_frames(_projectile, RECTS)
	_projectile.sprite.play("default")
	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)
	

static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return
	for i in range(2):
		var spawn_position = Vector2(randf_range(-4, 4), randf_range(-8, 8))
		var sprite := SpritesHelper.get_sprite_2d(Rect2(272, 256, 16, 16))
		sprite.scale = Vector2(1.3, 1)
		sprite.modulate.a = 0.5
		sprite.rotation = _projectile.rotation
		ParticleTrail.spawn_sprite_with_tween(
			GameManager.game_world.general_container,
			_projectile.global_position + spawn_position,
			sprite, 0.2
		)
	pass