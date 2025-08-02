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
	SoundsHelper.play_projectile_hit(ProjectileArrow.NAME, VOLUME)


static func actions_while_flying(_projectile: Projectile):
	if NAME != _projectile.type: return

	const LIFETIME := 0.2
	const AMPLITUDE := 15
	var forward := Vector2(1, 0).rotated(_projectile.rotation)
	var lateral := Vector2(0, 1).rotated(_projectile.rotation)
	var forward_offset := forward * 6

	for i in 5:
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
