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
@export var stun_chance: float = 0.0
@export var stun_duration: float = 0.0
@export var attack_speed: float = 1.0 # Higher is faster
@export var attack_range: int = 0
@export var physical_attack_power: int = 10
@export var magic_attack_power: int = 0
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = ProjectileTypes.NONE
var skills: Array[Skill] = []


var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity
var last_damage_received_time: int = 0 # In milliseconds

var my_owner: Entity

func _ready() -> void:
	pass

func set_my_owner(_owner: Entity) -> void:
	my_owner = _owner
	pass

func _server_calculate_physical_damage(_target: Entity) -> void:
	if _target == null: return

	var extra_power = physical_attack_power * get_extra_physical_attack_power()
	var total_damage = physical_attack_power + extra_power
	print("Normal power: ", physical_attack_power, " Extra power: ", extra_power, " Total total_damage: ", total_damage)

	_target.combat_data._server_receive_physical_damage(total_damage)

func _server_receive_physical_damage(_damage: int) -> void:
	var reduced_damage = _damage * get_extra_physical_defense()
	var total_damage: int = _damage - reduced_damage
	if total_damage < 0: total_damage = 0

	print("Received damage: ", _damage, " reduced: ", reduced_damage, " total: ", total_damage)

	var damage_info = DamageInfo.new()
	damage_info.amount = total_damage
	my_owner.rpc("rpc_receive_damage", damage_info.to_dict())

	current_hp -= total_damage
	if current_hp <= 0:
		current_hp = 0
		my_owner.rpc("rpc_die")


# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float):
	if not multiplayer.is_server(): return

	if my_owner.velocity != Vector2.ZERO: return

	if my_owner.target_entity == null: _assign_target_if_needed()

	if my_owner.target_entity == null: return

	if not can_physical_attack(): return

	if not GlobalsEntityHelpers.is_target_in_attack_area(my_owner, my_owner.target_entity): return

	_execute_physical_attack()
	last_physical_hit_time = Time.get_ticks_msec()

func _assign_target_if_needed():
	if my_owner is Player:
		my_owner.target_entity = GlobalsEntityHelpers.get_nearest_entity_to_attack(my_owner, GameManager.get_enemies())
		return

	if my_owner is Enemy:
		# First we check if there is a player nearby, then if the moomoo is in attack range
		my_owner.target_entity = GlobalsEntityHelpers.get_nearest_entity_to_attack(my_owner, GameManager.get_players())
		if my_owner.target_entity != null: return
		if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, GameManager.moomoo): my_owner.target_entity = GameManager.moomoo

func _execute_physical_attack():
	match attack_type:
		AttackTypes.RANGED:
			Projectile.launch(my_owner, my_owner.target_entity, physical_attack_power)

		AttackTypes.MELEE:
			_server_calculate_physical_damage(my_owner.target_entity)
	
func can_physical_attack() -> bool:
	if my_owner.velocity != Vector2.ZERO:
		return false
	var now = Time.get_ticks_msec()
	return now - last_physical_hit_time >= (1000.0 / attack_speed)
# endregion

func _global_receive_damage(_di: DamageInfo):
	last_damage_received_time = Time.get_ticks_msec()
	pass

# region Skills calculation
func get_extra_physical_defense() -> float:
	var total: float = 0
	for skill in skills:
		total += skill.extra_physical_defense_percent
	return total

func get_extra_physical_attack_power() -> float:
	var total: float = 0
	for skill in skills:
		total += skill.extra_physical_attack_power_percent
	return total
# endregion
