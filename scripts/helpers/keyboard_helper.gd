class_name KeyboardHelper

const INVENTORY_HOTKEYS := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
const SKILL_HOTKEYS := [KEY_A, KEY_S, KEY_D, KEY_F]

static func key_pressed(_keycode: int, player: Entity) -> void:
	if not player: return
	
	# SKILL HOTKEYs
	for i in SKILL_HOTKEYS.size():
		if _keycode == SKILL_HOTKEYS[i]:
			return player.combat_data.charge_skill(i)

	# INVENTORY HOTKEYs
	for i in INVENTORY_HOTKEYS.size():
		if _keycode == INVENTORY_HOTKEYS[i]:
			return player.combat_data.use_item(i + 1)

	# OTHER HOTKEYs
	if _keycode == KEY_Q:
		player.combat_data.toogle_keep_ground()