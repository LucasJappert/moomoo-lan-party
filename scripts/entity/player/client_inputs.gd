class_name ClientInputs

extends Node2D

@onready var player: Player = get_parent()
static var SHIFT_PRESSED = false

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
	
func _process(_delta: float) -> void:
	SHIFT_PRESSED = Input.is_key_pressed(KEY_SHIFT)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_position = player.get_global_mouse_position()
			_on_right_click(mouse_position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = player.get_global_mouse_position()
			print("Client left_click_mouse_pos: ", mouse_position)

	# if event is InputEventMouseMotion:
	# 	var mouse_position = player.get_global_mouse_position()
	# 	MapManager.set_hovered_cell(MapManager.world_to_cell(mouse_position))


func _on_right_click(mouse_position: Vector2):
	if not SHIFT_PRESSED and AreaHovered.hovered_entity is Enemy:
		return rpc_id(1, "notify_to_server_the_right_click_on_entity", AreaHovered.hovered_entity.name)

	var _target_cell = MapManager.world_to_cell(mouse_position)
	rpc_id(1, "try_to_move", _target_cell)


@rpc("authority", "call_local")
func try_to_move(_target_cell: Vector2i):
	player.movement_helper.target_entity = null
	# TODO: Review target_pos = target_cell
	player.movement_helper.update_path(_target_cell)

@rpc("authority", "call_local")
func notify_to_server_the_right_click_on_entity(_target_entity_name: String):
	# Always run in server
	var target_entity = GameManager.entities[_target_entity_name]
	player.combat_data._target_entity = target_entity

	var is_in_attack_range = GlobalsEntityHelpers.is_target_in_attack_area(player, target_entity)
	if is_in_attack_range: player.movement_helper.clean_path()
	if not is_in_attack_range: player.movement_helper.update_path(MapManager.world_to_cell(target_entity.global_position))

	player.movement_helper.target_entity = target_entity
