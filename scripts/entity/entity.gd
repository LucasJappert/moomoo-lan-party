class_name Entity

extends CharacterBody2D

@onready var hud = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack
@onready var area_attack_collision_shape = $AreaAttack/CollisionShape2D
@onready var path_line: Line2D = $PathLine
var id: int = 0

var combat_data = CombatData.new()
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


@rpc("any_peer")
func rpc_set_state(state: EntityState.StateEnum) -> void:
	current_state = state
	EntityState._play_animation(self)

func _ready():
	collision_layer = 1
	collision_mask = 1
	name = str(id)
	hud.initialize(self)
	_load_sprite()
	movement_helper.initialize(self)

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


func _server_verify_right_click_mouse_pos(_delta: float):
	# Implemented in Player
	pass

func _load_sprite():
	# Implemented in Player and Enemy
	pass

func _update_path():
	# Implemented in Player and Enemy
	pass

func die():
	# Implemented in Player and Enemy
	queue_free()