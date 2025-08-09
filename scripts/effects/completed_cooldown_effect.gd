class_name CompletedCooldownEffect

static func play(control: Control, sprite: Sprite2D, general_container: Node2D, particle_scale: float = 1):
	const LIFETIME := 1
	var ORIGINAL_SCALE := sprite.scale
	var tween := control.create_tween()
	tween.tween_property(sprite, "scale", ORIGINAL_SCALE * 1.2, LIFETIME * 0.4)
	tween.tween_property(sprite, "scale", ORIGINAL_SCALE, LIFETIME * 0.4)

	for point in _get_perimeter_points(sprite):
		ParticleEffects.spawn(point, general_container, LIFETIME, Color.WHITE, particle_scale)

static func _get_perimeter_points(sprite: Sprite2D, step: float = 4) -> Array[Vector2]:
	var points: Array[Vector2] = []

	var texture_size := sprite.region_rect.size * sprite.scale
	var top_left := Vector2.ZERO # Vector2(-texture_size.x / 2, -texture_size.y / 2)

	for x in range(0, int(texture_size.x), int(step)):
		points.append(top_left + Vector2(x, 0))
	for y in range(0, int(texture_size.y), int(step)):
		points.append(top_left + Vector2(texture_size.x, y))
	for x in range(int(texture_size.x), 0, -int(step)):
		points.append(top_left + Vector2(x, texture_size.y))
	for y in range(int(texture_size.y), 0, -int(step)):
		points.append(top_left + Vector2(0, y))

	return points