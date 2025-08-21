class_name ProjectileVenomArrow

extends ProjectileBase

const NAME = "venom_arrow"
const RECTS: Array[Rect2] = [Rect2(Vector2(0, 256), Vector2(64, 32))]
const SPEED: float = 400
const SCALE: float = 1
const VOLUME: float = -15


static func try_init(_projectile: Projectile):
	if _projectile.type != NAME: return

	_projectile.speed = SPEED
	set_frames(_projectile, RECTS)
	_projectile.sprite.play("default")
	_projectile.sprite.scale = Vector2(0.6, 0.7)
	# _projectile.trail_texture = SpritesHelper.get_texture_from_region(SMOKE_RECT)
	SoundsHelper.play_projectile_hit(ProjectileArrow.NAME, VOLUME)

	# ParticleTrailHelper.attach_to_projectile(_projectile, make_random_green_supplier(0.8))


# static func make_random_green_supplier(alpha: float = 0.8, dark_probability: float = 0.6) -> Callable:
# 	return func(_p: Projectile) -> Color:
# 		var h := randf_range(0.28, 0.36) # green band
# 		var is_dark: bool = randf() < clamp(dark_probability, 0.0, 1.0)

# 		var s: float
# 		var v: float
# 		if is_dark:
# 			# darker greens
# 			s = randf_range(0.65, 0.95)
# 			v = randf_range(0.45, 0.65)
# 		else:
# 			# bright greens
# 			s = randf_range(0.70, 1.00)
# 			v = randf_range(0.85, 1.00)

# 		return Color.from_hsv(h, s, v, alpha)

static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return

	const LIFETIME := 0.2
	const AMPLITUDE := 8
	var forward := Vector2(1, 0).rotated(_projectile.rotation)
	var lateral := Vector2(0, 1).rotated(_projectile.rotation)
	var forward_offset := forward * 6

	for i in 2:
		var offset := lateral * randf_range(-AMPLITUDE, AMPLITUDE)
		# var spawn := Vector2(randf_range(-4, 4), randf_range(-2, 2))
		var pos := _projectile.global_position + forward_offset
		var sprite := ParticleEffects.spawn_tween_to_black(pos, GameManager.game_world.general_container, LIFETIME, _get_random_color(), 0.8)

		sprite.create_tween() \
		.tween_method(
			func(t): sprite.global_position = pos.lerp(pos + offset, t),
			0.0, 1.0, LIFETIME
		)


static func _get_random_color() -> Color:
	return Color.from_hsv(0.33, 1, randf_range(0.05, 0.4), 0.3)
	# return Color.from_hsv(0.33, randf_range(0.6, 1.0), randf_range(0.05, 0.4), 0.3)
