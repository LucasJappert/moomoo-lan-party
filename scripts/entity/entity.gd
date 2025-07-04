class_name Entity

extends CombatData

var extra_info := ExtraInfo.new()

@onready var hud: HUD = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack
@onready var area_attack_shape = $AreaAttack/CollisionShape2D
@onready var area_vision = $AreaVision
@onready var area_vision_shape = $AreaVision/CollisionShape2D
@onready var area_hovered_shape = $AreaHovered/CollisionShape2D
@onready var projectile_zone = $ProjectileZone/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var front_animations_node = $FrontAnimationsNode

var sprite_heigth: float = 0
var can_attack: bool = true

var id: int = 0

@export var direction: Vector2 = Vector2.ZERO
var combat_stats = CombatStats.new()
var replicated: bool = false

# Move this logic to a separate module
var movement_helper: MovementHelper

@export var current_state: String:
	set(value):
		if _current_state == value: return
		_current_state = value
		EntityState.server_and_client_on_state_changed(self)
	get:
		return _current_state
var _current_state: String = EntityState.States.IDLE

@export var _boss_level: int = 0
@export var level: int = 1

@onready var rpc_handler: RpcHandler = $RpcHandler

func _init() -> void:
	super._init()

func _ready():
	collision_layer = 1
	collision_mask = 1
	movement_helper = MovementHelper.new(self)
	set_attack_type_according_to_projectile_type()
	area_attack_shape.shape = area_attack_shape.shape.duplicate() # to avoid changing the original shape
	for child in front_animations_node.get_children():
		child.queue_free()
	_client_init()
	rpc_handler.initialize()
	call_deferred("_post_ready")
	ready_combat_data()

	EventBus.connect_to_freed_entity(Callable(self, "_on_entity_freed"))

func _post_ready():
	hud._post_ready(self)
	post_ready_combat_data()
	
func _process(_delta: float) -> void:
	if GameManager.AM_I_HOST: process_combat_data(_delta)
	EntityState.server_process(self)

func _physics_process(_delta):
	movement_helper._physics_process(_delta) # we need this because movement_helper is not a child node
	_client_physics_process(_delta)

func _client_physics_process(_delta: float) -> void:
	if multiplayer.is_server() && not MyMain.HOSTED_GAME: return
		
	sprite.flip_h = direction.x < 0

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
# endregion GETTERs

# region 	SETTERs
func set_boss_level(_level: int) -> void:
	_boss_level = _level

func _set_area_attack_shape_radius() -> void:
	area_attack_shape.shape.radius = cache_total_stats.attack_range

func _client_init() -> void:
	SpritesHelper.set_entity_sprites(self)

# endregion SETTERs

# region OTHERS
func _global_die():
	# Implemented in Player and Enemy
	# if multiplayer.is_server(): GameManager.remove_entity(self)
	GameManager.remove_entity(self)
	print("GameManager: " + str(GameManager.entities))

# endregion OTHERS
