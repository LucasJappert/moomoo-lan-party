class_name Entity

extends CombatData

var tween_effects := TweenEffects.new()
var statistics: Statistics
var extra_info := ExtraInfo.new()
var movement_helper: MovementHelper

@onready var hud: HUD = $HUD
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_attack: Area2D = $AreaAttack
@onready var area_attack_shape: CollisionShape2D = $AreaAttack/CollisionShape2D
@onready var area_vision: Area2D = $AreaVision
@onready var area_vision_shape: CollisionShape2D = $AreaVision/CollisionShape2D
@onready var projectile_zone: CollisionShape2D = %ProjectileZone
@onready var body_sprite: AnimatedSprite2D = %BodySprite
@onready var body_shadow: Sprite2D = %BodyShadow
@onready var front_animations_node: Node2D = $FrontAnimationsNode
@onready var back_animations_node: Node2D = %BackAnimationsNode

var sprite_height: float = 0
var can_attack: bool = true

var id: int = 0

@export var direction: Vector2 = Vector2.ZERO
var combat_stats = CombatStats.new()
var replicated: bool = false

@export var current_state: String:
	set(value):
		if _current_state == value: return
		_current_state = value
		EntityState.server_and_client_on_state_changed(self)
	get:
		return _current_state
var _current_state: String = ""

@export var _boss_level: int = 0
@export var level: int = 1

var is_spawning: bool = true

func _init() -> void:
	super._init()

func _ready():
	collision_layer = 1
	collision_mask = 1
	movement_helper = MovementHelper.new(self)
	statistics = Statistics.new(self)
	tween_effects = TweenEffects.new(self)
	_test()
	area_attack_shape.shape = area_attack_shape.shape.duplicate() # to avoid changing the original shape
	for child in front_animations_node.get_children():
		child.queue_free()
	_client_init()
	call_deferred("_post_ready")
	ready_combat_data()
	ShadersHelper.set_dissolve_shader_material(body_sprite)

	EventBus.connect_to_freed_entity(Callable(self, "_on_entity_freed"))
	EventBus.connect_to_paused(func(_paused: bool, _show_menu: bool): EntityState.paused_game(self))

func _test():
	modulate.a = 0
	scale = Vector2.ZERO
	modulate = Color(0, 0, 0, 0)

	if self is Enemy:
		for i in 1:
			_span_line()
		await get_tree().create_timer(0.2).timeout # 100 ms
		
		for i in 3:
			_span_line()
		await get_tree().create_timer(0.2).timeout # 100 ms

		for i in 5:
			_span_line()
			await get_tree().create_timer(0.05).timeout # 100 ms

	tween_effects.apply_spawn_effect()
	is_spawning = false

func _span_line():
	const M := 24
	var start_pos := Vector2(global_position.x + randf_range(-M, M), global_position.y + randf_range(-M, M))
	var end_pos := Vector2(global_position.x + randf_range(-M, M), global_position.y + randf_range(-M, M))
	var random_duration := randf_range(0.1, 0.2)
	LineEffect.spawn(GameManager.game_world.general_container, start_pos, end_pos, random_duration)


func _post_ready():
	hud._post_ready(self)
	post_ready_combat_data()
	
func _process(_delta: float) -> void:
	if GameManager.AM_I_HOST: process_combat_data(_delta)
	EntityState.server_process(self)
	statistics._process(_delta)

func _physics_process(_delta):
	movement_helper._physics_process(_delta) # we need this because movement_helper is not a child node
	_client_physics_process(_delta)

func _client_physics_process(_delta: float) -> void:
	if multiplayer.is_server() && not GameWorld.HOSTED_GAME: return
		
	body_sprite.flip_h = direction.x < 0

func _on_entity_freed(entity_name: String) -> void:
	verify_freed_target_to_attack(entity_name)
	verify_freed_target_view(entity_name)

# region 	GETTERs
func is_in_range(target_cell: Vector2i, distance_in_tiles: int) -> bool:
	return (target_cell - movement_helper.current_cell).length() <= distance_in_tiles

func is_my_player() -> bool: return false

func get_my_enemies() -> Array[Entity]:
	if self is Player or self is Moomoo: return GameManager.get_enemies()

	if self is Enemy:
		var result: Array[Entity] = []
		result.append_array(GameManager.get_players())
		result.append(GameManager.get_moomoo())
		return result
		
	return []

func get_allies(include_me: bool = false) -> Array[Entity]:
	var result: Array[Entity] = []

	if self is Player or self is Moomoo: result.append_array(GameManager.get_players())
	if self is Enemy: result.append_array(GameManager.get_enemies())
	if not include_me: result.erase(self)
		
	return result
# endregion GETTERs

# region 	SETTERs
func set_direction_according_to_target(target: Entity) -> void:
	direction = get_direction_according_to_target(target)
	
func get_direction_according_to_target(target: Entity) -> Vector2: return ObjectHelpers.get_snapped_8_direction(target.global_position - global_position)

func set_boss_level(_level: int) -> void:
	_boss_level = _level

func _set_area_attack_shape_radius() -> void:
	area_attack_shape.shape.radius = cache_total_stats.get_attack_range()

func _client_init() -> void:
	SpritesHelper.set_entity_sprites(self)

func global_die(_killed_by: Entity) -> void:
	if _killed_by: _killed_by.statistics.register_kill()

	MapManager.set_cell_blocked(movement_helper.current_cell, false)

	for registered_skill in SkillBase.REGISTERED_SKILLS:
		registered_skill.actions_after_die(self, _killed_by)

	SoundsHelper.play_dying()

	var killed_by_ref = weakref(_killed_by)
	_apply_effects_after_die(func():
		GameManager.remove_entity(self, killed_by_ref.get_ref())
	)

# endregion SETTERs


# region 	INTERNAL AUXILIARY METHODS
func _apply_effects_after_die(on_finished: Callable) -> void:
	BloodStainEffect.spawn_on_death(global_position, 2)

	const TWEEN_DURATION := 1.5
	var tween := create_tween()


	TweenHelper.apply_tween_to_dissolve(tween, body_sprite, TWEEN_DURATION)

	TweenHelper.apply_tween_to_property(body_sprite, tween, "position", body_sprite.position + Vector2(0, -64), TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "scale", Vector2(1.5, 1.5), TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "modulate:a", 0.0, TWEEN_DURATION + 1)

	TweenHelper.apply_tween_to_property(body_shadow, tween, "modulate:a", 0.0, TWEEN_DURATION)
	
	TweenHelper.apply_tween_to_property(front_animations_node, tween, "modulate:a", 0.0, TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(back_animations_node, tween, "modulate:a", 0.0, TWEEN_DURATION)

	tween.tween_callback(on_finished)

	
# endregion INTERNAL AUXILIARY METHODS