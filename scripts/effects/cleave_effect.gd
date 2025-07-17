class_name CleaveEffect

extends MyInitAuxiliary

var damage_type: String
var percent: float
var radius_in_tiles: int = 1
const CLEAVE_RECT_REGION = Rect2(320, 256, 128, 64)

func _init(_percent: float = 0, _radius: int = 1, _damage_type: String = DamageType.PHYSICAL):
	super._init()
	percent = _percent
	radius_in_tiles = _radius
	damage_type = _damage_type

func get_cleave_damage(base_damage: int) -> int:
	return int(base_damage * percent)

func get_description() -> String:
	return str("- Cleave percent: ", StringHelpers.format_percent(percent), " (radius: ", radius_in_tiles, ") \n")

static func auxiliary_actions_after_hit(stats: CombatStats, _attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not stats.cleave_effect: return

	show_cleave_effect_with_texture(
		GameManager.game_world.over_terrain_layer,
		# _target.projectile_zone,
		_target.global_position,
		_attacker.global_position - _target.global_position,
		1
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
	duration: float = 0.5
) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = SpritesHelper.get_texture_from_region(CLEAVE_RECT_REGION)
	sprite.global_position = global_origin
	print("global_position: ", global_origin)
	# sprite.centered = false
	sprite.offset = Vector2(MapManager.TILE_SIZE_INT, -MapManager.TILE_SIZE_INT * 0.5)
	sprite.scale = Vector2.ZERO
	var final_scale = Vector2(1 + p_radius_in_tiles * 2, p_radius_in_tiles + 1) * 0.5
	sprite.rotation = direction.angle() - PI / 2
	print(direction.angle())
	print("sprite.rotation: ", sprite.rotation)
	var angle_deg := rad_to_deg(direction.angle())
	print("angle_deg: ", angle_deg)


	# Calcular el scale automáticamente según el radio
	# var desired_radius_px := p_radius_in_tiles * MapManager.TILE_SIZE_INT
	# var base_texture_width := CLEAVE_RECT_REGION.size.x
	# var scale_factor := desired_radius_px / base_texture_width
	# sprite.scale = Vector2(scale_factor, scale_factor)

	sprite.modulate = Color(1, 1, 1, 1) # alpha inicial
	parent.add_child(sprite)

	# Fade-out con tween
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale", final_scale, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(sprite, "queue_free"))
