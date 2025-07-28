class_name BloodStainEffect

const BLOOD_REGION := Rect2(512, 256, 64, 64) # regi n de la imagen que representa una mancha de sangre
const DROP_REGION := Rect2(256, 256, 16, 16) # región de la imagen que representa una gota de sangre
const APPEAR_TIME := 0.1 # tiempo que tarda en aparecer la mancha, en segundos
const FADE_TIME := 1 # tiempo que tarda en desaparecer la mancha, en segundos
const SMALL_SCALE_RANGE := Vector2(0.01, 0.05) # rango de escala para las manchas de sangre
const BIG_SCALE_RANGE := Vector2(0.05, 0.3)
const STAIN_COUNT := 8 # cantidad de manchas que se generan al mismo tiempo
const SMALL_SPREAD_RADIUS := 16.0 # radio de dispersion para las manchas de sangre
const BIG_SPREAD_RADIUS := 8.0 # radio de dispersion para las manchas de sangre

const BLEEDING_SPRITES_LIMIT_PER_BODY := 20
const STAIN_SPRITES_LIMIT_PER_CELL := 50
static var STAIN_PER_POSITION: Dictionary[Vector2i, int] = {}

static func spawn_on_death(global_position: Vector2, lifetime: float = 5.0) -> void:
	# Creamos varias chicas
	for i in 10:
		var offset := Vector2(randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS), randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS))
		var stain_pos := global_position + offset
		_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, SMALL_SCALE_RANGE)
	for i in 3:
		var offset := Vector2(randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS), randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS))
		var stain_pos := global_position + offset
		_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, BIG_SCALE_RANGE)
		
static func spawn_on_bleeding(global_position: Vector2, lifetime: float = 5.0) -> void:
	var offset: Vector2; var stain_pos: Vector2
	for i in 5:
		offset = Vector2(randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS), randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS))
		stain_pos = global_position + offset
		_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, SMALL_SCALE_RANGE)

	for i in 2:
		offset = Vector2(randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS), randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS))
		stain_pos = global_position + offset
		_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, BIG_SCALE_RANGE)

static func apply_bleeding_on_the_body(_owner: Entity) -> void:
	if _owner.projectile_zone.get_children().size() >= BLEEDING_SPRITES_LIMIT_PER_BODY: return
	for i in 5: _spawn_random_single_drop(_owner.projectile_zone)

static func _spawn_single_stain(global_position: Vector2, parent: Node, lifetime: float, scale_range: Vector2) -> void:
	var cell_pos := MapManager.world_to_cell(global_position)
	if STAIN_PER_POSITION.get(cell_pos, 0) >= STAIN_SPRITES_LIMIT_PER_CELL: return
	if STAIN_PER_POSITION.has(cell_pos): STAIN_PER_POSITION[cell_pos] += 1
	else: STAIN_PER_POSITION[cell_pos] = 1

	var sprite := Sprite2D.new()
	sprite.texture = SpritesHelper.get_texture_from_region(BLOOD_REGION)
	ShadersHelper.set_dissolve_shader_material(sprite, 0.5)
	sprite.centered = true
	sprite.scale = Vector2.ZERO
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.0)
	sprite.rotation = randf_range(0, TAU)
	sprite.global_position = global_position

	parent.add_child(sprite)

	var final_scale := Vector2.ONE * randf_range(scale_range.x, scale_range.y)

	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale", final_scale, APPEAR_TIME)
	tween.parallel().tween_property(sprite, "modulate:a", 0.6, APPEAR_TIME)

	# Esperar el tiempo de vida
	tween.tween_interval(lifetime)

	# Desvanecer y eliminar
	tween.tween_callback(func():
		var separate_tween := sprite.create_tween()
		TweenHelper.apply_tween_to_dissolve(separate_tween, sprite, FADE_TIME)
	)
	
	# tween.tween_callback(func():
	# 	var dissolve_tween := sprite.create_tween()
	# 	TweenHelper.apply_tween_to_dissolve(dissolve_tween, sprite, FADE_TIME)
	# 	dissolve_tween.tween_callback(node.queue_free)
	# )

	tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5, 0), FADE_TIME).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if STAIN_PER_POSITION.has(cell_pos): STAIN_PER_POSITION[cell_pos] -= 1
		sprite.queue_free()
	)

static func _spawn_random_single_drop(parent: Node) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = SpritesHelper.get_texture_from_region(DROP_REGION)
	# ShadersHelper.set_dissolve_shader_material(sprite, 0.5)
	sprite.centered = true
	sprite.scale = Vector2.ONE * randf_range(0.2, 0.8)
	sprite.modulate = Color(
		0.4 + randf_range(0, 0.3),
		0.0,
		0.0,
		1 - randf_range(0.0, 0.2)
	)
	var START_POSITION := Vector2(randf_range(-8, 8), randf_range(-4, 4))
	sprite.position = START_POSITION

	parent.add_child(sprite)

	var LIFETIME := 0.6
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "position:y", sprite.position.y + 24, LIFETIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(sprite, "scale:x", 0, LIFETIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# tween.parallel().tween_property(sprite, "modulate", Color(0, 0, 0, sprite.modulate.a), LIFETIME)

	# TweenHelper.apply_tween_to_dissolve(tween, sprite, LIFETIME)
	
	# Desvanecer y eliminar
	tween.tween_callback(func():
		spawn_on_bleeding(parent.global_position + Vector2(0, 20), 1.0)
		sprite.queue_free()
	)
