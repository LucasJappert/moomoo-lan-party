class_name DecorationsFactory

extends Node

const _ATLAS_TEXTURE: Texture2D = preload("res://assets/atlas1.png")
const _TILE_SIZE = Vector2i(MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y)

static func _create_decoration_sprite(atlas_rect: Rect2i) -> Sprite2D:
	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = _ATLAS_TEXTURE
	atlas.region = atlas_rect
	sprite.texture = atlas
	return sprite

static func add_random_decorations(start: Vector2i, grid_size: Vector2i, get_cells_func: Callable, sample_fraction: float) -> void:
	var decoration_types: Array[Rect2i] = []
	for y in grid_size.y:
		for x in grid_size.x:
			var pos = start + Vector2i(x, y) * _TILE_SIZE
			decoration_types.append(Rect2i(pos, _TILE_SIZE))

	if decoration_types.is_empty():
		return

	var cells: Array[Vector2i] = get_cells_func.call()
	var random_sample := Utilities.get_random_sample(cells, sample_fraction)
	for cell in random_sample:
		var sprite = _create_decoration_sprite(decoration_types[randi_range(0, decoration_types.size() - 1)])
		sprite.global_position = MapManager.cell_to_world_2i(cell) + Vector2i(randi_range(-16, 16), randi_range(-16, 16))
		sprite.flip_h = randi() % 2 == 0
		GameManager.add_decoration(sprite)

static func add_random_decorations_over_grass_terrain() -> void:
	add_random_decorations(
		Vector2i(576, 1792), Vector2i(3, 4),
		func(): return MapManager.get_grass_cells(), 0.07
	)

static func add_random_decorations_over_dirt_terrain() -> void:
	add_random_decorations(
		Vector2i(672, 1792), Vector2i(1, 3),
		func(): return MapManager.get_dirt_cells(), 0.02
	)
