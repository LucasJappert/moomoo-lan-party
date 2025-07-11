class_name ProjectileFireBall

extends ProjectileBase

const NAME = "fireball"
const RECTS: Array[Rect2] = [
	Rect2(Vector2(0, 288), Vector2(32, 32)),
	Rect2(Vector2(32, 288), Vector2(32, 32)),
	Rect2(Vector2(64, 288), Vector2(32, 32)),
	Rect2(Vector2(96, 288), Vector2(32, 32))
]
const SPEED: float = 300
const SCALE: float = 1
const VOLUME: float = -15

static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	set_frames(_projectile, RECTS)
	_projectile.sprite.play("default")

	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)

static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int) -> bool:
	if _proj_type != NAME: return false

	Projectile.launch(_entity, _target, _damage)
	return true
