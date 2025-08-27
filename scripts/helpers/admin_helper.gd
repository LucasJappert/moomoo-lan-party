class_name AdminHelper

static func kill_all_enemies():
	if not Player.get_my_player(): return

	for enemy in GameManager.MY_PLAYER.get_my_enemies():
		enemy.server_receive_damage(
			DamageInfo.new(enemy.current_hp, DamageType.PURE, Player.get_my_player()), Player.get_my_player()
	)