class_name Entity

extends CharacterBody2D

@onready var hud = $HUD
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

var id: int = 0

@onready var combat_data: CombatData = $CombatData
@export var direction: Vector2 = Vector2.ZERO
var replicated: bool = false

# Move this logic to a separate module
var target_entity: Entity
var target_position: Vector2 = Vector2.ZERO
var current_path: Array[Vector2i] = []
var current_cell = null
var target_pos = null
var movement_helper = MovementEntityHelper.new()

@export var current_state: EntityState.StateEnum = EntityState.StateEnum.IDLE
@export var _boss_level: int = 0


@rpc("authority", "call_local")
func rpc_server_message(data: Dictionary):
	var sm = ServerMessage.get_instance()
	sm.from_dict(data)
	hud.show_popup(sm.message, Color(sm.color.x, sm.color.y, sm.color.z))

@rpc("authority", "call_local")
func rpc_receive_damage(data: Dictionary):
	var di = DamageInfo.get_instance()
	di.from_dict(data)
	combat_data._global_receive_damage(di)

@rpc("authority", "call_local")
func rpc_die():
	print("⚔️ Entity died")
	print("Multiplayer: ", multiplayer.is_server())
	_global_die()

func _init() -> void:
	# combat_data = load("res://scenes/entity/combat_data/combat_data.tscn").instantiate()
	# add_child(combat_data)
	# print("_init Entity name: ", name, " combat_data.current_hp: ", combat_data.current_hp)
	pass

func _ready():
	collision_layer = 1
	collision_mask = 1
	print("_ready Entity name: ", name, " combat_data.current_hp: ", combat_data.current_hp)
	movement_helper.set_my_owner(self)
	combat_data.set_my_owner(self)
	area_attack_shape.shape = area_attack_shape.shape.duplicate() # to avoid changing the original shape
	_client_init()
	call_deferred("_post_ready")

func _post_ready():
	hud._post_ready(self)
	

func set_boss_level(_level: int) -> void:
	_boss_level = _level

func _set_area_attack_shape_radius() -> void:
	area_attack_shape.shape.radius = combat_data.attack_range

func _process(_delta: float) -> void:
	EntityState._process(self)
	combat_data.try_physical_attack(_delta)

func _physics_process(_delta):
	movement_helper._server_move_along_path(_delta)
	_client_physics_process(_delta)

func _client_physics_process(_delta: float) -> void:
	if multiplayer.is_server() && not MultiplayerManager.HOSTED_GAME: return
		
	sprite.flip_h = direction.x < 0
	# if self is Enemy:
	# 	if AreaHovered.hovered_entity == self:
	# 		sprite.modulate = Color(1, 0, 0)

func _client_init() -> void:
	if multiplayer.is_server() && not MultiplayerManager.HOSTED_GAME: return

	SpritesAnimationHelper.set_entity_sprites(self)

func _update_path(_target_cell: Vector2i):
	# Implemented in Player and Enemy
	pass

func _global_die():
	# Implemented in Player and Enemy
	# if multiplayer.is_server(): GameManager.remove_entity(self)
	GameManager.remove_entity(self)
	print("GameManager: " + str(GameManager.entities))
