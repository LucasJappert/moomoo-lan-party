# BloodStainEffect.gd
class_name BloodStainEffect

const BLOOD_REGION := Rect2(512, 256, 64, 64) # regi n de la imagen que representa una mancha de sangre
const APPEAR_TIME := 0.1 # tiempo que tarda en aparecer la mancha, en segundos
const FADE_TIME := 1 # tiempo que tarda en desaparecer la mancha, en segundos
const SMALL_SCALE_RANGE := Vector2(0.01, 0.05) # rango de escala para las manchas de sangre
const BIG_SCALE_RANGE := Vector2(0.1, 0.3)
const STAIN_COUNT := 8 # cantidad de manchas que se generan al mismo tiempo
const SMALL_SPREAD_RADIUS := 16.0 # radio de dispersion para las manchas de sangre
const BIG_SPREAD_RADIUS := 8.0 # radio de dispersion para las manchas de sangre

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
	for i in 3:
		offset = Vector2(randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS), randf_range(-SMALL_SPREAD_RADIUS, SMALL_SPREAD_RADIUS))
		stain_pos = global_position + offset
		_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, SMALL_SCALE_RANGE)

	offset = Vector2(randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS), randf_range(-BIG_SPREAD_RADIUS, BIG_SPREAD_RADIUS))
	stain_pos = global_position + offset
	_spawn_single_stain(stain_pos, GameManager.game_world.over_terrain_layer_layer_1, lifetime, BIG_SCALE_RANGE)


static func _spawn_single_stain(global_position: Vector2, parent: Node, lifetime: float, scale_range: Vector2) -> void:
	var node := Node2D.new()
	node.global_position = global_position

	var sprite := Sprite2D.new()
	sprite.texture = SpritesHelper.get_texture_from_region(BLOOD_REGION)
	ShadersHelper.set_dissolve_shader_material(sprite, 0.5)
	sprite.centered = true
	sprite.scale = Vector2.ZERO
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.0)
	sprite.rotation = randf_range(0, TAU)

	node.add_child(sprite)
	parent.add_child(node)

	var final_scale := Vector2.ONE * randf_range(scale_range.x, scale_range.y)

	var tween := node.create_tween()
	tween.tween_property(sprite, "scale", final_scale, APPEAR_TIME)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, APPEAR_TIME)

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
	# tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, FADE_TIME).set_ease(Tween.EASE_IN)
	tween.tween_callback(node.queue_free)
