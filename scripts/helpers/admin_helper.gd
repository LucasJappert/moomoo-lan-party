class_name AdminHelper

static func kill_all_enemies():
	for enemy in GameManager.get_enemies():
		enemy.server_receive_damage(
			DamageInfo.new(enemy.current_hp, DamageType.PURE, Player.get_my_player()),
			GameManager.MY_PLAYER if ObjectHelpers.valid_instance(GameManager.MY_PLAYER) else null
	)