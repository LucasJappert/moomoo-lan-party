class_name Entity

extends CombatData

var _victory_auras: VictoryAuraEmitter
var vision_helper: VisionHelper
var range_attack_helper: VisionHelper
var summoned_helper: SummonedHelper
var tween_effects := TweenEffects.new()
var statistics: Statistics
var extra_info := ExtraInfo.new()
var movement_helper: MovementHelper


@onready var hud: HUD = $HUD
@onready var projectile_zone: CollisionShape2D = %ProjectileZone
@onready var body_sprite: AnimatedSprite2D = %BodySprite
@onready var body_shadow: Sprite2D = %BodyShadow
@onready var front_animations_node: Node2D = $FrontAnimationsNode
@onready var back_animations_node: Node2D = %BackAnimationsNode

var sprite_height: float = 0
var can_attack: bool = true
var is_dying: bool = false

var id: int = 0

@export var direction: Vector2 = Vector2.ZERO
var combat_stats := CombatStats.new()
var replicated: bool = false

@export var current_gold: int:
	set(_value):
		current_gold = _value
		if current_gold > 9999: current_gold_string = StringHelpers.format_float_compact(current_gold)
		else: current_gold_string = StringHelpers.format_float(current_gold)
var current_gold_string: String = ""

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
	_victory_auras = VictoryAuraEmitter.new(func() -> Vector2: return global_position)
	collision_layer = 1
	collision_mask = 1
	vision_helper = VisionHelper.new(self)
	range_attack_helper = VisionHelper.new(self, 0, Color.RED)
	# vision.set_color(Color(0.2, 0.9, 0.3, 0.22)) # opcional
	movement_helper = MovementHelper.new(self)
	statistics = Statistics.new(self)
	tween_effects = TweenEffects.new(self)
	_apply_spawn_effect()
	for child in front_animations_node.get_children():
		child.queue_free()
	_client_init()
	call_deferred("_post_ready")
	ready_combat_data()

	# Revisar el find_path para cuando tenemos un target attack y estamos a rango
	GlobalsEntityHelpers.set_group(self)

	if summoned_helper:
		summoned_helper = SummonedHelper.new(self, summoned_helper.summoned_by_name, summoned_helper.lifetime_sec)
		add_child(summoned_helper, true)

	EventBus.connect_to_freed_entity(Callable(self, "_on_entity_freed"))
	EventBus.connect_to_paused(func(_paused: bool, _show_menu: bool): EntityState.paused_game(self))

func _apply_spawn_effect():
	scale = Vector2.ZERO
	modulate = Color(0, 0, 0, 0)

	TweenEffects.apply_spawn_spin_effect(GameManager.game_world.over_terrain_layer_layer_1, global_position, 3)
	await get_tree().create_timer(0.5).timeout
	tween_effects.apply_spawn_effect()

func _span_line():
	const M := 24
	var start_pos := Vector2(global_position.x + randf_range(-M, M), global_position.y + randf_range(-M, M))
	var end_pos := Vector2(global_position.x + randf_range(-M, M), global_position.y + randf_range(-M, M))
	var random_duration := randf_range(0.1, 0.2)
	LineEffect.spawn(GameManager.game_world.general_container, start_pos, end_pos, random_duration)


func _post_ready():
	hud._post_ready(self)
	post_ready_combat_data()
	hud.update_health_bar()
	hud.update_mana_bar()
	
func _process(_delta: float) -> void:
	_victory_auras.process(_delta)
	if GameManager.AM_I_HOST: process_combat_data(_delta)
	EntityState.server_process(self)
	statistics._process(_delta)
	vision_helper.process()
	range_attack_helper.process()

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
func get_summoned_entities(unit_names: Array[String] = []) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in GameManager.get_entities():
		if not entity.summoned_helper: continue
		if entity.summoned_helper.summoned_by_name != self.name: continue
		if unit_names.is_empty():
			result.append(entity)
			continue
		if entity.extra_info.key_type in unit_names: result.append(entity)
	return result

func is_enemy_of_player() -> bool: return is_in_group(GlobalsEntityHelpers.GROUP_ENEMY)

func is_ally_of_player() -> bool: return not is_enemy_of_player()

func is_in_range(target_cell: Vector2i, distance_in_tiles: int) -> bool:
	return (target_cell - movement_helper.current_cell).length() <= distance_in_tiles

func is_my_player() -> bool: return false

func get_my_enemies() -> Array[Entity]:
	if self is Player: return GameManager.get_player_enemies()

	if self is Enemy:
		var player_allies_ids := GameManager.get_player_allies(true).map(func(entity: Entity): return entity.id)
		if self.id in player_allies_ids: return GameManager.get_player_enemies()
		else: return GameManager.get_player_allies(true)

	if self is Moomoo:
		if Moomoo.is_awake(): return GameManager.get_player_allies(true)
		else: return GameManager.get_player_enemies()
		
	return []

func get_allies(include_me: bool = false) -> Array[Entity]:
	var result: Array[Entity] = []
	if self is Player: result = GameManager.get_player_allies(true)
	if self is Enemy:
		var player_allies_ids := GameManager.get_player_allies(true).map(func(entity: Entity): return entity.id)
		if self.id in player_allies_ids: result = GameManager.get_player_allies(true)
		else: result = GameManager.get_player_enemies()
	if self is Moomoo:
		if Moomoo.is_awake(): result = GameManager.get_player_enemies()
		else: result = GameManager.get_player_allies(true)
		
	if not include_me: result.erase(self)
	return result
		
func is_alive() -> bool: return current_hp > 0
# endregion GETTERs

# region 	SETTERs
func increment_current_gold(value_to_increment: int, add_to_stats: bool = true, play_sound: bool = true) -> void:
	if current_hp <= 0: return
	current_gold += value_to_increment
	if add_to_stats: statistics.add_gold(value_to_increment)
	if is_my_player() and play_sound: SoundsHelper.play_coins()

func set_is_spawning(_is_spawning: bool) -> void: is_spawning = _is_spawning

func set_summoned_helper(entity_name: String, duration: float) -> void:
	summoned_helper = SummonedHelper.new(self, entity_name, duration)

func set_direction_according_to_target(target: Entity) -> void:
	direction = get_direction_according_to_target(target)
	
func get_direction_according_to_target(target: Entity) -> Vector2: return ObjectHelpers.get_snapped_8_direction(target.global_position - global_position)

func set_boss_level(_level: int) -> void:
	_boss_level = _level

func _client_init() -> void:
	SpritesHelper.set_entity_sprites(self)

func global_die(_killed_by: Entity, _expired: bool = false) -> void:
	if self is Player: GlobalsEntityHelpers.set_group_by_value(Moomoo.instance, GlobalsEntityHelpers.GROUP_ENEMY)
	is_dying = true
	if _killed_by: _killed_by.statistics.register_kill()

	MapManager.set_cell_blocked(movement_helper.current_cell, false)

	for registered_skill in SkillBase.REGISTERED_SKILLS:
		registered_skill.actions_after_die(self, _killed_by)

	if not _expired: SoundsHelper.play_dying()

	var killed_by_ref = weakref(_killed_by)
	_apply_effects_after_die(func():
		GameManager.remove_entity(self, killed_by_ref.get_ref())
	)

# endregion SETTERs


# region 	INTERNAL AUXILIARY METHODS
func _apply_effects_after_die(on_finished: Callable) -> void:
	ShadersHelper.set_dissolve_shader_material(body_sprite)
	BloodStainEffect.spawn_on_death(global_position, 2)

	const TWEEN_DURATION := 1.5
	var tween := create_tween()

	TweenHelper.apply_tween_to_dissolve(tween, body_sprite, TWEEN_DURATION)

	TweenHelper.apply_tween_to_property(body_sprite, tween, "position", body_sprite.position + Vector2(0, -64), TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "scale", Vector2(1.5, 1.5), TWEEN_DURATION)
	# TweenHelper.apply_tween_to_property(body_sprite, tween, "modulate:a", 0.0, TWEEN_DURATION + 1)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "modulate", Color(0, 0, 0, body_sprite.modulate.a), TWEEN_DURATION)

	TweenHelper.apply_tween_to_property(body_shadow, tween, "modulate:a", 0.0, TWEEN_DURATION)
	
	TweenHelper.apply_tween_to_property(front_animations_node, tween, "modulate:a", 0.0, TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(back_animations_node, tween, "modulate:a", 0.0, TWEEN_DURATION)

	tween.tween_callback(on_finished)

	
# endregion INTERNAL AUXILIARY METHODS