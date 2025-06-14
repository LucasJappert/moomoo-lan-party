extends Node

func _unhandled_input(event: InputEvent):
	MyCamera.try_update_zoom(event)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit() # CLOSE THE GAME

		if event.keycode == KEY_I:
			GUI.SHOW_DEBUG_DATA = not GUI.SHOW_DEBUG_DATA

		if event.keycode == KEY_T:
			GameManager.MY_PLAYER.combat_data.apply_lightning_animation()
