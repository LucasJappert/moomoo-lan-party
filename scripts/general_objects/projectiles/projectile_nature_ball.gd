class_name ProjectileNatureBall

extends ProjectileBase

const NAME = "nature_ball"
const RECT_REGION := Rect2(Vector2(128, 288), Vector2(32, 32))
const SPEED: float = 300
const SCALE: float = 1.2
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	set_frames(_projectile, [RECT_REGION])
	_projectile.sprite.play("default")
	_projectile.sprite.scale = Vector2.ZERO
	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)


static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return
	for i in range(4):
		var spawn_position = Vector2(randf_range(-2, 2), randf_range(-2, 2))
		var particle_sprite := SpritesHelper.get_sprite_2d(RECT_REGION)
		particle_sprite.rotation = _projectile.rotation
		ParticleEffects.spawn_sprite(
			GameManager.game_world.general_container,
			_projectile.global_position + spawn_position,
			particle_sprite,
			0.2,
			Color(0, 0, 0, 0)
		)
