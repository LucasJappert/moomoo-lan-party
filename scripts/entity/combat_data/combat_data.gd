class_name CombatData

extends Node

const MIN_ATTACK_RANGE: int = int(MapManager.TILE_SIZE.x)

@export var max_hp: int = 100
@export var current_hp: int = 100
@export var physical_defense: int = 0
@export var magic_defense: int = 0
@export var evasion: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 1.0
@export var attack_speed: float = 1.0 # Higher is faster
@export var attack_range: int = 0
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = ProjectileTypes.NONE
var skills: Array[Skill] = []

@export var physical_attack_power: int = 10
@export var magic_attack_power: int = 0

var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity

var my_owner: Entity

func _ready() -> void:
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

# region TRY PHISICAL ATTACK
func _try_enemy_phisical_attack(_delta: float):
	if my_owner.target_entity == null:
		return

	if not my_owner is Enemy:
		return

	if not can_physical_attack():
		return

	if attack_type == AttackTypes.RANGED:
		var distance_to_target = my_owner.global_position.distance_to(my_owner.target_entity.global_position)
		if distance_to_target > attack_range:
			return
		Projectile.launch(my_owner, my_owner.target_entity, physical_attack_power)
		last_physical_hit_time = Time.get_ticks_msec()

	if attack_type == AttackTypes.MELEE:
		var distance_to_target = my_owner.global_position.distance_to(my_owner.target_entity.global_position)
		if distance_to_target > attack_range:
			return
		my_owner.target_entity.combat_data._server_receive_damage(physical_attack_power)
		last_physical_hit_time = Time.get_ticks_msec()

	
func can_physical_attack() -> bool:
	if my_owner.velocity != Vector2.ZERO:
		return false
	var now = Time.get_ticks_msec()
	return now - last_physical_hit_time >= (1000.0 / attack_speed)

# endregion

func _global_receive_damage(_di: DamageInfo):
	pass
