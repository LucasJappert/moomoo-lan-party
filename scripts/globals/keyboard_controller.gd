extends Node

func _unhandled_input(event: InputEvent):
	MyCamera.try_update_zoom(event)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if GameManager.game_world.gui_scene.shop_interface.close_shop(): return
			get_tree().quit() # CLOSE THE GAME

		if event.keycode == KEY_I:
			GUIScene.SHOW_DEBUG_DATA = not GUIScene.SHOW_DEBUG_DATA
		if event.keycode == KEY_SPACE:
			MyCamera.update_camera_position_to_my_player()
