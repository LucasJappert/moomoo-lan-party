class_name ProjectileBase

static var REGISTERED_CLASSES = [
	ProjectileHolyArrow,
	ProjectileFireArrow,
	ProjectileFrozenArrow,
	ProjectileVenomArrow,
	ProjectileDemonBolt,
	ProjectileShuriken,
	ProjectileNatureBall,
	ProjectileArcLightning,
	ProjectileFireBall,
	ProjectileArrow
]
const NONE = "none"

static var projectile_frames: Dictionary[String, SpriteFrames] = {}


static func try_init(_projectile: Projectile):
	pass

static func set_frames(_projectile: Projectile, rects: Array[Rect2]):
	if projectile_frames.has(_projectile.type):
		_projectile.sprite.frames = projectile_frames[_projectile.type]
		return

	var frames := SpriteFrames.new()
	SpritesHelper._add_animation(frames, "default", rects)

	_projectile.sprite.frames = frames
	projectile_frames[_projectile.type] = frames
	
static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int, _name: String, _extra_projectile: bool = false) -> bool:
	if _proj_type != _name: return false

	Projectile.launch(_entity, _target, _damage, _extra_projectile)
	return true

static func actions_while_flying(_projectile: Projectile):
	pass

static func actions_on_reaching_target(_projectile: Projectile):
	pass
