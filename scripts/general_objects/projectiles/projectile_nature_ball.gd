class_name ProjectileNatureBall

extends ProjectileBase

const TYPE = "nature_ball"
const RECTS: Array[Rect2] = [Rect2(Vector2(128, 288), Vector2(32, 32))]
const SPEED: float = 300
const SCALE: float = 1.2
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != TYPE: return

	_projectile.speed = SPEED
	_projectile.sprite.scale = Vector2.ONE * SCALE
	TweenHelper.apply_pulsing_modulate_and_scale(_projectile.sprite)
	set_frames(_projectile, RECTS)
	_projectile.sprite.play("default")
	SoundsHelper.play_projectile_hit(_projectile.type, VOLUME)

static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int) -> bool:
	if _proj_type != TYPE: return false

	Projectile.launch(_entity, _target, _damage)
	return true