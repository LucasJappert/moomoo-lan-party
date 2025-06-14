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
		var mouse_position = player.get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_on_right_click(mouse_position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_left_click(mouse_position)


func _on_right_click(mouse_position: Vector2):
	if not SHIFT_PRESSED and AreaHovered.hovered_entity is Enemy:
		return rpc_id(1, "notify_to_server_the_right_click_on_entity", AreaHovered.hovered_entity.name)

	var _target_cell = MapManager.world_to_cell(mouse_position)
	rpc_id(1, "try_to_move", _target_cell)

func _on_left_click(mouse_position: Vector2):
	print("Client left_click_mouse_pos: ", mouse_position)
	if not AreaHovered.hovered_entity is Enemy: return

	rpc_id(1, "notify_to_server_the_left_click_on_entity", AreaHovered.hovered_entity.name)


@rpc("authority", "call_local")
func try_to_move(_target_cell: Vector2i):
	player.movement_helper.set_target_cell(_target_cell)

@rpc("authority", "call_local")
func notify_to_server_the_right_click_on_entity(_target_entity_name: String):
	# Always run in server
	var target_entity = GameManager.entities[_target_entity_name]
	player.combat_data.set_target_entity(target_entity)
	player.movement_helper.set_target_entity(target_entity)
	
@rpc("authority", "call_local")
func notify_to_server_the_left_click_on_entity(_target_entity_name: String):
	# Always run in server
	var target_entity = GameManager.entities[_target_entity_name]
	player.combat_data.set_target_entity(target_entity)
	player.combat_data.skills[0].use(player, target_entity)
