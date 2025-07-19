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
		# ParticleTrail.spawn_explosion(GameManager.MY_PLAYER.global_position, GameManager.game_world.general_container)
		# Aplicar efecto de escudo por 5 segundos
		# var _effect = ShieldEffect.attach_to(GameManager.MY_PLAYER.front_animations_node, 225.0)
		# O dejarlo permanente
		# var permanent = ShieldEffect.show(player_node, 0.0)
		# Eliminar manualmente cuando quieras
		# permanent.destroy()
		# for degree in range(-90, 91, 5):
		# 	var my_effect := RotatingRingEffect.play_loop(GameManager.MY_PLAYER.front_animations_node, degree, Vector2(0, -20))
		pass

	if _keycode == KEY_Q:
		player.toogle_keep_ground()

	if _keycode == KEY_SPACE and GameManager.MY_PLAYER:
		GameManager.MY_PLAYER.set_target_view(GameManager.MY_PLAYER)

	if _keycode == KEY_F11 and GameManager.MY_PLAYER:
		MainScene.set_paused(not MainScene.PAUSED)