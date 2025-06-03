class_name SpritesAnimationHelper

static var _ATLAS1 = load("res://assets/atlas1.png")

const _PLAYERS_SCALE = Vector2(0.75, 0.75)

const _ENEMIES_SCALE = Vector2(0.85, 0.85)

static func set_entity_sprites(entity: Entity) -> void:
	if entity is Player:
		var rects = HeroTypes.get_rect_frames(entity.hero_type)
		_set_sprites(entity, rects, _PLAYERS_SCALE)
	elif entity is Enemy:
		var rects = EnemyTypes.get_rect_frames(entity.enemy_type)
		_set_sprites(entity, rects, _ENEMIES_SCALE)
	
	if entity._boss_level > 0:
		var scale_factor = 1.3
		entity.sprite.scale *= scale_factor
		entity.sprite.position.y *= scale_factor
		entity.hud.my_health_bar.position.y -= 10

	entity.sprite_heigth = entity.sprite.sprite_frames.get_frame_texture("idle", 0).get_height() * entity.sprite.scale.y

static func get_sprite_frames(start_region: Vector2, frame_size: Vector2, frames_size: int, speed: float, looped: bool) -> SpriteFrames:
	var frames := SpriteFrames.new()
	var regions: Array[Rect2] = []
	for i in range(frames_size):
		var region := Rect2(Vector2(start_region.x + i * frame_size.x, start_region.y), frame_size)
		regions.append(region)
	_add_animation(frames, "default", regions)
	frames.set_animation_speed("default", speed)
	frames.set_animation_loop("default", looped)
	return frames

static func _set_sprites(entity: Entity, rects: Array[Rect2], scale: Vector2) -> void:
	var frames := SpriteFrames.new()

	# Setup "idle" animation using the first frame
	_add_animation(frames, "idle", [rects[0]])

	# Setup "walk" animation with 2 frames horizontally aligned
	var walk_regions: Array[Rect2] = []
	for rect in rects:
		walk_regions.append(rect)
	_add_animation(frames, "walk", walk_regions)

	# Apply the animations and set initial animation
	entity.sprite.frames = frames
	entity.sprite.scale = scale
	entity.sprite.play("idle")

static func _add_animation(frames: SpriteFrames, name: String, regions: Array[Rect2]) -> void:
	# Create a new animation and configure its properties
	frames.remove_animation(name)
	frames.add_animation(name)
	frames.set_animation_speed(name, 10)
	frames.set_animation_loop(name, true)

	# Add each frame to the animation from the atlas
	for region in regions:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = _ATLAS1
		atlas_texture.region = region
		frames.add_frame(name, atlas_texture)
