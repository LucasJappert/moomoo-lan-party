class_name SpritesHelper

static var _ATLAS1 = load("res://assets/atlas1.png")

const _PLAYERS_START_REGION = Vector2(256, 448)
const _PLAYERS_FRAME_SIZE = Vector2(128, 128)
const _PLAYERS_SCALE = Vector2(0.75, 0.75)

const _ENEMIES_SCALE = Vector2(0.85, 0.85)

static func set_entity_sprites(entity: Entity) -> void:
	if entity is Player:
		_set_sprites(entity, _PLAYERS_START_REGION, _PLAYERS_FRAME_SIZE, _PLAYERS_SCALE)
	elif entity is Enemy:
		_set_enemy_sprites(entity)

static func _set_enemy_sprites(entity: Entity) -> void:
	var frames := SpriteFrames.new()
	var rects = EnemyTypes.get_enemy_rect_frames(entity.enemy_type)

	# Setup "idle" animation using the first frame
	_add_animation(frames, "idle", [rects[0]])

	# Setup "walk" animation with 2 frames horizontally aligned
	var walk_regions: Array[Rect2] = []
	for rect in rects:
		walk_regions.append(rect)
	_add_animation(frames, "walk", walk_regions)

	# Apply the animations and set initial animation
	entity.sprite.frames = frames
	entity.sprite.scale = _ENEMIES_SCALE
	entity.sprite.play("idle")

static func _set_sprites(entity: Entity, start_region: Vector2, frame_size: Vector2, scale: Vector2) -> void:
	var frames := SpriteFrames.new()

	# Setup "idle" animation using the first frame
	_add_animation(frames, "idle", [Rect2(start_region, frame_size)])

	# Setup "walk" animation with 2 frames horizontally aligned
	var walk_regions: Array[Rect2] = []
	for i in range(2):
		var region := Rect2(Vector2(start_region.x + i * frame_size.x, start_region.y), frame_size)
		walk_regions.append(region)
	_add_animation(frames, "walk", walk_regions)

	# Apply the animations and set initial animation
	entity.sprite.frames = frames
	entity.sprite.scale = scale
	entity.sprite.play("idle")

static func _add_animation(frames: SpriteFrames, name: String, regions: Array[Rect2]) -> void:
	# Create a new animation and configure its properties
	frames.add_animation(name)
	frames.set_animation_speed(name, 10)
	frames.set_animation_loop(name, true)

	# Add each frame to the animation from the atlas
	for region in regions:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = _ATLAS1
		atlas_texture.region = region
		frames.add_frame(name, atlas_texture)
