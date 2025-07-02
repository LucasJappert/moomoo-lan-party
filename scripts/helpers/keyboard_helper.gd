class_name KeyboardHelper

const INVENTORY_HOTKEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
const SKILL_HOTKEYS := [KEY_A, KEY_S, KEY_D, KEY_F]

static func key_pressed_server_side(_keycode: int, player: Entity) -> void:
	if not player: return
	
	print("Key pressed: ", _keycode)
	# SKILL HOTKEYs
	for i in SKILL_HOTKEYS.size():
		if _keycode == SKILL_HOTKEYS[i]:
			return player.charge_skill(i)

	# INVENTORY HOTKEYs
	for i in INVENTORY_HOTKEYS.size():
		if _keycode == INVENTORY_HOTKEYS[i]:
			return player.use_item(i + 1)

	# OTHER HOTKEYs
	if _keycode == KEY_Q:
		player.toogle_keep_ground()