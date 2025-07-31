class_name ClientInputs

extends Node2D

@onready var player: Player = get_parent()

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
	
func _process(_delta: float) -> void:
	pass

func _get_hovered_entity_name() -> String:
	return str(AreaHovered.hovered_entity.name) if AreaHovered.hovered_entity else ""


func _unhandled_input(event):
	MyCamera.handle_input(event)
	
	if event is InputEventMouseButton and event.pressed:
		#### Keep this code for debug 🔍
		# var pos = get_viewport().get_mouse_position()
		# var window := get_viewport().get_window() # 👈 importante!
		# var node := window.gui_get_hovered_control()
		# print("Clicked at: ", pos, " - Hovered control: ", node)
		if DraggableSlot.verify_global_click(event): return
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# if ObjectHelpers.is_enemy(AreaHovered.hovered_entity):
			# 	if not KeyboardController.SHIFT_PRESSED: return rpc_id(1, "_on_right_click_on_entity", _get_hovered_entity_name())
			if AreaHovered.hovered_entity: return
			rpc_id(1, "_on_try_to_move", MapManager.world_to_cell(MapManager.GLOBAL_MOUSE_POSITION))
		if event.button_index == MOUSE_BUTTON_LEFT:
			rpc_id(1, "_on_left_click", _get_hovered_entity_name())

	if event is InputEventKey and event.pressed:
		KeyboardHelper.key_pressed_server_side(event.keycode, GameManager.MY_PLAYER)
			

# region 	SERVER MESSAGES RECEIVED FROM CLIENT
@rpc("authority", "call_local")
func _on_try_to_move(_target_cell: Vector2i):
	CursorManager.show_move_effect()
	player.movement_helper.set_target_cell(_target_cell)

@rpc("authority", "call_local")
func _on_right_click_on_entity(_target_entity_name: String):
	var target_entity = GameManager.get_entity(_target_entity_name)
	player.set_target_to_attack(target_entity)
	player.movement_helper.set_target_entity(target_entity)
	
@rpc("authority", "call_local")
func _on_left_click(_target_entity_name: String):
	# Always run in server
	var target_entity = GameManager.get_entity(_target_entity_name)
		
	ShopInterface.static_close_shop()

	if not GameManager.MY_PLAYER: return

	player.use_charged_skill(target_entity)

@rpc("authority", "call_local")
func _on_inventory_slot_clicked(_position: int):
	player.use_item(_position)
# endregion SERVER MESSAGES RECEIVED FROM CLIENT