# KeyboardController (Autoload)
extends Node

static var SHIFT_PRESSED := false
static var ALT_PRESSED := false
static var CONTROL_PRESSED := false

func _unhandled_input(event: InputEvent):
	MyCamera.try_update_zoom(event)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if GameManager.game_world.gui_scene.shop_interface.close_shop(): return
			# get_tree().quit() # CLOSE THE GAME

		if event.keycode == KEY_I:
			GUIScene.SHOW_DEBUG_DATA = not GUIScene.SHOW_DEBUG_DATA
		if CONTROL_PRESSED and event.keycode == KEY_P:
			AdminHelper.kill_all_enemies()

			
	_update_modifiers()

static func _update_modifiers():
	SHIFT_PRESSED = Input.is_key_pressed(KEY_SHIFT)
	ALT_PRESSED = Input.is_key_pressed(KEY_ALT)
	CONTROL_PRESSED = Input.is_key_pressed(KEY_CTRL)
