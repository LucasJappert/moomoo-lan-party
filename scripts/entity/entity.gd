class_name Entity

extends CharacterBody2D

@onready var hud = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack
@onready var area_attack_shape = $AreaAttack/CollisionShape2D
@onready var area_vision = $AreaVision
@onready var area_vision_shape = $AreaVision/CollisionShape2D
var id: int = 0

@onready var combat_data: CombatData = $CombatData
var mov_speed: float = 100.0
@export var direction: Vector2 = Vector2.ZERO

# Move this logic to a separate module
var target_entity: Entity
var target_position: Vector2 = Vector2.ZERO
var current_path: Array[Vector2i] = []
var current_cell = null
var target_pos = null
var movement_helper = MovementEntityHelper.new()

@export var current_state: EntityState.StateEnum = EntityState.StateEnum.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


@rpc("authority", "call_local")
func rpc_set_state(state: EntityState.StateEnum) -> void:
	current_state = state
	
	if MultiplayerManager.HOSTED_GAME || not multiplayer.is_server():
		EntityState._play_animation(self)
	

@rpc("authority", "call_local")
func rpc_receive_damage(data: Dictionary):
	var di = DamageInfo.new()
	print("⚔️ Damage received:", di.amount, "critical:", di.critical)
	di.from_dict(data)
	combat_data._global_receive_damage(di)


@rpc("authority", "call_local")
func rpc_die():
	print("⚔️ Entity died")
	_global_die()

func _ready():
	collision_layer = 1
	collision_mask = 1
	name = str(id)
	_client_init()
	movement_helper.initialize_on_ready(self)
	hud.initialize_on_ready(self)
	combat_data.set_my_owner(self)
	

func _set_area_attack_shape_radius() -> void:
	const _MAR = CombatData.MIN_ATTACK_RANGE
	var _radius = combat_data.attack_range if combat_data.attack_range > _MAR else _MAR
	area_attack_shape.shape.radius = _radius

func _process(_delta: float) -> void:
	_server_verify_right_click_mouse_pos(_delta)
	EntityState._process(self)

func _physics_process(_delta):
	movement_helper._server_move_along_path(_delta)
	_physics_process_server(_delta)

func _physics_process_server(_delta: float) -> void:
	if multiplayer.is_server() && not MultiplayerManager.HOSTED_GAME:
		return
	sprite.flip_h = direction.x < 0

func _client_init() -> void:
	if multiplayer.is_server() && not MultiplayerManager.HOSTED_GAME:
		return

	_load_sprite()

func _server_verify_right_click_mouse_pos(_delta: float):
	# Implemented in Player
	pass

func _load_sprite():
	# Implemented in Player and Enemy
	pass

func _update_path():
	# Implemented in Player and Enemy
	pass

func _global_die():
	# Implemented in Player and Enemy
	queue_free()
