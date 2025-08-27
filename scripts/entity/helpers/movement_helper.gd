class_name MovementHelper

enum AttackMoveType {
	None,
	PhysicalAttack,
	SkillAttack,
}

var my_owner: Entity
var current_target_pos = null
var _target_entity: Entity
var _target_cell
var current_path: Array[Vector2i] = []
var _attack_move = false
var _attack_move_type := AttackMoveType.None
var _can_move := true
var _last_current_path_update_time: float = - INF
var current_cell: Vector2i
const _NEXT_PATH_RECALC_MS = 1000

func _init(p_owner: Entity):
	my_owner = p_owner
	current_cell = MapManager.world_to_cell(my_owner.global_position)
	# if my_owner is Moomoo: _can_move = false

func _physics_process(_delta: float) -> void:
	if GameManager.main_scene.PAUSED: return
	if my_owner.current_hp <= 0: return
	if not _can_move: return
	if not GameManager.AM_I_HOST: return
	if my_owner.is_spawning: return

	# _try_to_update_target_from_latest_attacker()
	_try_to_update_target_to_attack_of_my_player()

	if current_target_pos == null: _try_set_next_current_target_pos()

	if current_target_pos == null and my_owner.is_moving(): _stop_movements()

	if current_target_pos: _try_to_move(_delta)

# region 	SETTERs
func _try_set_next_current_target_pos() -> void:
	controlled_update_path()

	if current_path.is_empty(): return _clean_movements()

	if my_owner.is_stunned: return

	if _attack_move:
		# Return if the target is in attack range (dont move, just attack)
		if _verify_range_from_charged_skill(): return _clean_movements()

		if _verify_range_from_physical_attack(): return _clean_movements()

	if MapManager._astar_grid.is_point_solid(current_path[0]):
		# Esto pasa cuando el siguiente tile ya fue ocupado, entonces hay que actualizar el path
		if my_owner.is_my_player(): update_path()
		elif controlled_update_path() == false: return _clean_movements()
		if current_path.is_empty(): return _clean_movements()

	MapManager.set_cell_blocked(current_cell, false)
	current_cell = current_path[0]
	MapManager.set_cell_blocked(current_cell, true)
	
	current_target_pos = MapManager.cell_to_world(current_cell)
	current_path.remove_at(0)
	
func clean_path() -> void:
	current_path = []

func set_attack_mode_mode(p_value: bool, attack_move_type: AttackMoveType) -> void:
	_attack_move = p_value
	_attack_move_type = attack_move_type

func _stop_movements() -> void:
	current_target_pos = null
	my_owner.velocity = Vector2.ZERO
	_clean_movements()

func _clean_movements() -> void:
	_target_cell = null
	_target_entity = null
	current_path = []
	set_attack_mode_mode(false, AttackMoveType.None)

func set_target_entity(target: Entity, attack_move_type: AttackMoveType) -> void:
	if target == _target_entity: return
	
	_clean_movements()

	if target == null: return

	set_attack_mode_mode(true, attack_move_type)
	_target_entity = target
	if my_owner.is_my_player(): update_path()
	else: controlled_update_path()

func set_target_cell(target_cell: Vector2i) -> void:
	if current_cell == target_cell: return
	_clean_movements()
	_target_cell = MapManager.get_safe_cell(target_cell)
	update_path()
	my_owner.register_attacker(null)
	my_owner.set_target_to_attack(null)

func controlled_update_path() -> bool:
	if _target_cell == null && _target_entity == null: return false

	# We do the following to update the current_path (useful for refreshing the path when an enemy has a tile blocked in the current path)
	# if current_path.size() > 0:
	var diff_time = Time.get_ticks_msec() - _last_current_path_update_time
	if diff_time < _NEXT_PATH_RECALC_MS: return false

	_last_current_path_update_time = Time.get_ticks_msec()

	update_path()
	return true

func update_path() -> void:
	var from_pos = current_target_pos if current_target_pos else my_owner.global_position
	var from_cell = MapManager.world_to_cell(from_pos)
	var target_cell = _target_cell if _target_cell != null else _target_entity.movement_helper.current_cell
	current_path = MapManager.find_path(from_cell, target_cell, my_owner)

# endregion SETTERs

func _verify_range_from_charged_skill() -> bool:
	if _attack_move_type != AttackMoveType.SkillAttack: return false
	if not my_owner.charged_skill: return false
	var learned_skill = my_owner.charged_skill.get_learned_skill()
	if not learned_skill: return false # Should never happen
	
	var is_in_range := my_owner.is_in_range(_target_entity.movement_helper.current_cell, learned_skill.cast_range_in_tiles)
	if not is_in_range: return false
	my_owner.use_charged_skill(_target_entity)
	return true

func _verify_range_from_physical_attack() -> bool:
	if _attack_move_type != AttackMoveType.PhysicalAttack: return false
	if not _target_entity: return false
	return GlobalsEntityHelpers.is_target_in_attack_range(my_owner, _target_entity)

func _try_to_update_target_to_attack_of_my_player():
	if my_owner is Player == false: return # Enemies should always have a target (Moomoo by default)
	if _target_cell or _target_entity: return
	if my_owner.is_moving(): return

	if my_owner.get_target_to_attack(): return

	# With the following logic, we ensure that our character moves towards the target (only if the target is out of attack range)
	# if my_owner.get_target_to_attack():
	# 	if GlobalsEntityHelpers.is_target_in_attack_range(my_owner, my_owner.get_target_to_attack()): return

	var nearest_enemy: Entity
	var max_range := my_owner.vision_helper.radius_in_pixel
	if my_owner.hold_terrain: max_range = my_owner.range_attack_helper.radius_in_pixel
	nearest_enemy = GlobalsEntityHelpers.get_nearest_entity(my_owner.global_position, my_owner.get_my_enemies(), max_range)

	if nearest_enemy:
		my_owner.set_target_to_attack(nearest_enemy) # Esta funcion tambien deberia setear el movimiento hacia el target si no esta en rango de ataque

func _try_to_move(_delta: float) -> void:
	var old_distance = current_target_pos - my_owner.global_position
	var direction: Vector2 = old_distance.normalized()
	# TODO: get_total_stats en Entity
	var speed := my_owner.cache_total_stats.get_total_move_speed() * MapManager.TILE_SIZE.x
	var velocity := direction * speed

	var move_delta := velocity * _delta
	var new_pos := my_owner.global_position + move_delta

	# Detect if you went past the target
	var new_distance = current_target_pos - new_pos

	# If the sign of the dot product changes, you overshot
	if old_distance.dot(new_distance) <= 0.0:
		# my_owner.global_position = current_target_pos
		my_owner.global_position = MapManager.cell_to_world(MapManager.world_to_cell(current_target_pos))
		current_target_pos = null
		return

	my_owner.global_position = new_pos
	my_owner.direction = direction
	my_owner.velocity = velocity
