class_name CombatData

extends Node

const MIN_ATTACK_RANGE: int = int(MapConstants.TILE_SIZE.x)

@export var max_hp: int = 100
@export var current_hp: int = 100
@export var physical_defense: int = 0
@export var magic_defense: int = 0
@export var evasion: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 1.0
@export var attack_speed: float = 1.0
@export var attack_range: int = 0
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = ProjectileTypes.NONE
var skills: Array[Skill] = []

var my_owner: Entity

func _ready() -> void:
	print("CombatData authority: " + str(is_multiplayer_authority()))
	pass

func set_my_owner(_owner: Entity) -> void:
	my_owner = _owner
	pass

func _server_receive_damage(amount: int) -> void:
	var damage_info = DamageInfo.new()
	damage_info.amount = amount
	my_owner.rpc("rpc_receive_damage", damage_info.to_dict())

	current_hp -= amount
	if current_hp <= 0:
		current_hp = 0
		my_owner.rpc("rpc_die")


func _global_receive_damage(di: DamageInfo):
	print("Recibimos daño por: " + str(di.amount))
	print("Reproducimos alguna animacion si es el cliente o si es el servidor en modo host")
