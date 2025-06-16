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

func _get_hovered_entity_name() -> String:
	return str(AreaHovered.hovered_entity.name) if AreaHovered.hovered_entity else ""

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_position = player.get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not SHIFT_PRESSED and AreaHovered.hovered_entity is Enemy:
				return rpc_id(1, "_on_right_click_on_entity", _get_hovered_entity_name())
			rpc_id(1, "_on_try_to_move", MapManager.world_to_cell(mouse_position))
		if event.button_index == MOUSE_BUTTON_LEFT:
			rpc_id(1, "_on_left_click", _get_hovered_entity_name())

	if event is InputEventKey and event.pressed:
		rpc_id(1, "_on_key_pressed", event.keycode)
			

# region 	SERVER MESSAGES RECEIVED FROM CLIENT
@rpc("authority", "call_local")
func _on_try_to_move(_target_cell: Vector2i):
	player.movement_helper.set_target_cell(_target_cell)

@rpc("authority", "call_local")
func _on_right_click_on_entity(_target_entity_name: String):
	var target_entity = GameManager.get_entity(_target_entity_name)
	player.combat_data.set_target_entity(target_entity)
	player.movement_helper.set_target_entity(target_entity)
	
@rpc("authority", "call_local")
func _on_left_click(_target_entity_name: String):
	# Always run in server
	var target_entity = GameManager.get_entity(_target_entity_name)

	if target_entity:
		print("effects: ", target_entity.combat_data.get_effects())
		print("entity name: ", target_entity.name)

	player.combat_data.set_target_entity(target_entity)

	player.combat_data.use_charged_skill()

@rpc("authority", "call_local")
func _on_key_pressed(_keycode: int):
	if _keycode == KEY_A:
		player.combat_data.charge_skill(0)

# endregion SERVER MESSAGES RECEIVED FROM CLIENT