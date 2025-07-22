class_name CleaveEffect

extends MyInitAuxiliary

var damage_type: String
var percent: float
var radius_in_tiles: int = 1
const CLEAVE_RECT_REGION = Rect2(320, 256, 96, 64)

func _init(_percent: float = 0, _radius: int = 1, _damage_type: String = DamageType.PHYSICAL):
	super._init()
	percent = _percent
	radius_in_tiles = _radius
	damage_type = _damage_type

func get_cleave_damage(base_damage: int) -> int:
	return int(base_damage * percent)

func get_description() -> String:
	return str("- Cleave percent: ", StringHelpers.format_percent(percent), " (radius: ", radius_in_tiles, ") \n")

func accumulate(other: CleaveEffect) -> void:
	if not other: return
	percent += other.percent

func get_new_instance() -> CleaveEffect:
	return CleaveEffect.new(percent, radius_in_tiles, damage_type)

static func auxiliary_actions_after_hit(stats: CombatStats, _attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not stats.cleave_effect: return

	show_cleave_effect_with_texture(
		GameManager.game_world.over_terrain_layer_layer_2,
		# GameManager.game_world.general_container,
		# _target.front_animations_node,
		_target.global_position,
		_attacker.get_direction_according_to_target(_target),
		stats.cleave_effect.radius_in_tiles
	)

	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_target.global_position, _attacker.get_my_enemies(), stats.cleave_effect.radius_in_tiles, 100, [_target])
	var filtered_enemies := GlobalsEntityHelpers.filter_enemies_according_to_caster_direction(_attacker.position, _target.position, nearest_enemies)

	if filtered_enemies.size() == 0: return

	var _cdi := DamageInfo.new(stats.cleave_effect.get_cleave_damage(_di.total_damage), _di.damage_type)
	_cdi.projectile_type = ProjectileBase.NONE
	_cdi.attacker_name = _attacker.name
	_cdi.can_be_evaded = false
	_cdi.was_a_cleave_damage = true

	for enemy in filtered_enemies: enemy.server_receive_damage(_cdi, _attacker)

static func show_cleave_effect(
	parent: Node,
	global_origin: Vector2,
	direction: Vector2,
	angle_degrees: float,
	radius: float,
	duration: float = 1
) -> void:
	var node := CleaveEffectNode.new()
	node.global_position = global_origin
	node.rotation = direction.angle()
	node.angle_deg = angle_degrees
	node.radius = radius
	node.duration = duration
	parent.add_child(node)

# Subclase real
class CleaveEffectNode:
	extends Node2D

	var radius: float = 64.0
	var angle_deg: float = 90.0
	var duration: float = 0.5
	var elapsed: float = 0.0

	func _ready():
		set_process(true)

	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			print("Cleave effect finished")
			queue_free()

	func _draw():
		var alpha := 1.0 - (elapsed / duration)
		var segments := 32
		var angle_rad := deg_to_rad(angle_deg)
		var start_angle := -angle_rad / 2.0
		var color := Color(1, 0.2, 0.2, alpha)
		print("alpha: ", alpha)

		draw_arc(Vector2.ZERO, radius, start_angle, angle_rad, segments, color, 6.0)

static func show_cleave_effect_with_texture(
	parent: Node,
	global_origin: Vector2,
	direction: Vector2,
	p_radius_in_tiles: float,
	duration: float = 0.4,
	count: int = 1,
	# delay_between: float = 0.05
) -> void:
	for i in range(count):
		# await parent.get_tree().create_timer(delay_between).timeout
		_create_single_cleave_effect(parent, global_origin, direction, p_radius_in_tiles, duration)

static func _create_single_cleave_effect(
	parent: Node,
	global_origin: Vector2,
	direction: Vector2,
	p_radius_in_tiles: float,
	duration: float
) -> void:
	# var effect_root := Node2D.new()
	# effect_root.global_position = global_origin
	# parent.add_child(effect_root)
	var sprite := Sprite2D.new()
	sprite.texture = SpritesHelper.get_texture_from_region(CLEAVE_RECT_REGION)
	sprite.centered = true
	sprite.modulate = Color(1, 1, 1, 1)

	var base_width_in_tiles := CLEAVE_RECT_REGION.size.x / MapManager.TILE_SIZE.x
	var base_height_in_tiles := CLEAVE_RECT_REGION.size.y / MapManager.TILE_SIZE.y
	var final_scale := Vector2(
		(1 + p_radius_in_tiles * 2) / base_width_in_tiles,
		(p_radius_in_tiles + 1) / base_height_in_tiles
	)
	sprite.scale.y = 0
	var texture_half_height := CLEAVE_RECT_REGION.size.y * 0.5
	sprite.global_position = Vector2(global_origin.x, global_origin.y - texture_half_height * final_scale.y + MapManager.TILE_SIZE.y)

	sprite.rotation = direction.angle() + PI / 2
	parent.add_child(sprite)

	var move_offset := direction.normalized() * MapManager.TILE_SIZE.x * 1.0
	var final_position := global_origin + move_offset

	var tween := sprite.create_tween()

	tween.parallel().tween_property(sprite, "scale", final_scale, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "global_position", final_position, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(sprite, "queue_free"))
