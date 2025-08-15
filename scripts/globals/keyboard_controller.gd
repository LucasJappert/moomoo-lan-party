# KeyboardController (Autoload)
extends Node

static var SHIFT_PRESSED := false
static var ALT_PRESSED := false
static var CONTROL_PRESSED := false

func _unhandled_input(event: InputEvent):
	MyCamera.try_update_zoom(event)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and GameManager.game_world:
			if ShopInterface.close_shop(): return
			# get_tree().quit() # CLOSE THE GAME

		if event.keycode == KEY_I:
			GUIScene.SHOW_DEBUG_DATA = not GUIScene.SHOW_DEBUG_DATA
		if CONTROL_PRESSED and event.keycode == KEY_P:
			AdminHelper.kill_all_enemies()
	

	if event is InputEventMouseButton and event.pressed:
		# #### Keep this code for debug 🔍
		# var area := get_area2d_under_mouse()
		# if area: print("Clicked on Area2D:", area.name)
		# else: print("No Area2D under mouse.")
		if DraggableSlot.verify_global_click(event): return
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not GameManager.MY_PLAYER: return
			if AreaHovered.hovered_entity: return
			CursorManager.show_move_effect()
			var _target_cell = MapManager.world_to_cell(MapManager.GLOBAL_MOUSE_POSITION)
			GameManager.MY_PLAYER.movement_helper.set_target_cell(_target_cell)
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_left_click(_get_hovered_entity_name())

	if event is InputEventKey and event.pressed:
		KeyboardHelper.key_pressed_server_side(event.keycode, ObjectHelpers.get_safe_instance(GameManager.MY_PLAYER))

			
	_update_modifiers()
	MyCamera.handle_input(event)

static func _update_modifiers():
	SHIFT_PRESSED = Input.is_key_pressed(KEY_SHIFT)
	ALT_PRESSED = Input.is_key_pressed(KEY_ALT)
	CONTROL_PRESSED = Input.is_key_pressed(KEY_CTRL)

static func _on_left_click(_target_entity_name: String) -> void:
	# Always run in server
	var target_entity = GameManager.get_entity(_target_entity_name)
		
	ShopInterface.close_shop()

	if GameManager.MY_PLAYER and GameManager.MY_PLAYER.charged_skill:
		return GameManager.MY_PLAYER.use_charged_skill(target_entity)

	EventBus.emit_new_target_view_selected(ObjectHelpers.get_safe_instance(GameManager.MY_PLAYER), target_entity)

	
static func _get_hovered_entity_name() -> String:
	return str(AreaHovered.hovered_entity.name) if AreaHovered.hovered_entity else ""
