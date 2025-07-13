class_name Entity

extends CombatData

var tween_effects: TweenEffects
var statistics: Statistics
var extra_info := ExtraInfo.new()
var movement_helper: MovementHelper

@onready var hud: HUD = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack
@onready var area_attack_shape = $AreaAttack/CollisionShape2D
@onready var area_vision = $AreaVision
@onready var area_vision_shape = $AreaVision/CollisionShape2D
@onready var area_hovered_shape = $AreaHovered/CollisionShape2D
@onready var projectile_zone = $ProjectileZone/CollisionShape2D
@onready var body_sprite: AnimatedSprite2D = %BodySprite
@onready var body_shadow: Sprite2D = %BodyShadow
@onready var front_animations_node: Node2D = $FrontAnimationsNode

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

@onready var rpc_handler: RpcHandler = $RpcHandler

func _init() -> void:
	super._init()

func _ready():
	collision_layer = 1
	collision_mask = 1
	movement_helper = MovementHelper.new(self)
	statistics = Statistics.new(self)
	tween_effects = TweenEffects.new(self)
	area_attack_shape.shape = area_attack_shape.shape.duplicate() # to avoid changing the original shape
	for child in front_animations_node.get_children():
		child.queue_free()
	_client_init()
	rpc_handler.initialize()
	call_deferred("_post_ready")
	ready_combat_data()
	ShadersHelper.set_dissolve_shader_material(self)

	EventBus.connect_to_freed_entity(Callable(self, "_on_entity_freed"))

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
	if include_me: result.append(self)
		
	return result
# endregion GETTERs

# region 	SETTERs
func set_boss_level(_level: int) -> void:
	_boss_level = _level

func _set_area_attack_shape_radius() -> void:
	area_attack_shape.shape.radius = cache_total_stats.attack_range

func _client_init() -> void:
	SpritesHelper.set_entity_sprites(self)

func global_die(_killed_by: Entity) -> void:
	if _killed_by: _killed_by.statistics.register_kill()

	_apply_effects_after_die(_killed_by, func():
		GameManager.remove_entity(self, _killed_by)
	)

# endregion SETTERs


# region 	INTERNAL AUXILIARY METHODS
func _apply_effects_after_die(_killed_by: Entity, on_finished: Callable) -> void:
	const TWEEN_DURATION := 1.5
	var tween := create_tween()

	var dissolve_updater := func(value: float):
		if is_instance_valid(body_sprite.material):
			body_sprite.material.set_shader_parameter("dissolve_amount", value)

	tween.parallel().tween_method(dissolve_updater, 0.0, 1.0, TWEEN_DURATION).set_trans(Tween.TRANS_LINEAR)

	TweenHelper.apply_tween_to_property(body_sprite, tween, "position", body_sprite.position + Vector2(0, -64), TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "scale", Vector2(1.5, 1.5), TWEEN_DURATION)
	TweenHelper.apply_tween_to_property(body_sprite, tween, "modulate:a", 0.0, TWEEN_DURATION + 1)

	TweenHelper.apply_tween_to_property(body_shadow, tween, "modulate:a", 0.0, TWEEN_DURATION)
	
	TweenHelper.apply_tween_to_property(front_animations_node, tween, "modulate:a", 0.0, TWEEN_DURATION)

	tween.tween_callback(on_finished)
	
# endregion INTERNAL AUXILIARY METHODS