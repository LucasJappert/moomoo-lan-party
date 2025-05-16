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
var direction: Vector2 = Vector2.ZERO

# Move this logic to a separate module
var target_entity: Entity
var target_position: Vector2 = Vector2.ZERO
var current_path: Array[Vector2i] = []
var current_cell = null
var target_pos = null

@export var current_state: EntityState.StateEnum = EntityState.StateEnum.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


@rpc("any_peer")
func rpc_set_state(state: EntityState.StateEnum) -> void:
	print("rpc_set_state", state)
	current_state = state
	EntityState._play_animation_for_state(self)

func _ready():
	collision_layer = 1
	collision_mask = 1
	name = str(id)
	hud.initialize(self)
	_load_sprite()

func _server_verify_right_click_mouse_pos(_delta: float):
	# Implemented in Player
	pass

func _load_sprite():
	pass

func _process(_delta: float) -> void:
	AuxEntityClient._process(self, _delta)
	AuxEntityServer._process(self, _delta)
	EntityState._update(self)
	hud._process(_delta)

	_server_verify_right_click_mouse_pos(_delta)

func _physics_process(delta):
	_server_move_along_path(delta)

func _server_move_along_path(_delta: float):
	if not multiplayer.is_server():
		return

	if is_target_entity_in_attack_area():
		current_path = []

	if target_pos == null:
		if current_path.is_empty():
			return _stop_movement()

		current_cell = AStarGridManager.world_to_cell(global_position)
		var next_target_cell = current_path[0]

		
		if AStarGridManager.astar_grid.is_point_solid(next_target_cell):
			 # Update the path and return when next target cell is blocked
			_update_path()
			return _stop_movement()
		AStarGridManager.set_cell_blocked(current_cell, false)
		AStarGridManager.set_cell_blocked(next_target_cell, true)
		target_pos = AStarGridManager.cell_to_world(next_target_cell)
		current_path.remove_at(0)

	direction = (target_pos - global_position).normalized()
	velocity = direction * mov_speed

	global_position.x += velocity.x * _delta
	global_position.y += velocity.y * _delta

	if global_position.distance_to(target_pos) < 2:
		global_position = target_pos
		target_pos = null

func is_target_entity_in_attack_area() -> bool:
	if target_entity == null:
		return false

	var result = area_attack.overlaps_body(target_entity)
	return result

func _stop_movement():
	velocity = Vector2.ZERO

func _update_path():
	pass

func die():
	queue_free()
