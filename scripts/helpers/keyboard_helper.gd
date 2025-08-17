class_name KeyboardHelper

const INVENTORY_HOTKEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
const SKILL_HOTKEYS := [KEY_A, KEY_S, KEY_D, KEY_F]

static func key_pressed_server_side(_keycode: int, player: Entity) -> void:
	if not player: return
	
	# SKILL HOTKEYs
	for i in SKILL_HOTKEYS.size():
		if _keycode == SKILL_HOTKEYS[i]:
			return player.charge_skill(i)

	# INVENTORY HOTKEYs
	for i in INVENTORY_HOTKEYS.size():
		if _keycode == INVENTORY_HOTKEYS[i]:
			return player.use_item(i + 1)

	# OTHER HOTKEYs
	if _keycode == KEY_T:
		var random_pos := GameManager.MY_PLAYER.global_position + Vector2(randi_range(-256, 256), randi_range(-256, 256))
		SmokeHelper.spawn_smoke(GameManager.game_world.over_terrain_layer_layer_2, random_pos, 5)
		SmokeHelper._attach_sulfur_layer(GameManager.game_world.over_terrain_layer_layer_2, random_pos)
		pass

	if _keycode == KEY_Q:
		player.toogle_keep_ground()

	if _keycode == KEY_SPACE and GameManager.MY_PLAYER:
		EventBus.emit_new_target_view_selected(null, GameManager.MY_PLAYER)
		MyCamera.update_camera_position_to_my_player()

	if _keycode == KEY_ESCAPE and GameManager.MY_PLAYER:
		MainScene.set_paused(not MainScene.PAUSED, true, true)