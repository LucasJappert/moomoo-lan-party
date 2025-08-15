class_name AdminHelper

static func kill_all_enemies():
	var attacker_name: String = GameManager.MY_PLAYER_NAME
	for enemy in GameManager.get_enemies():
		enemy.server_receive_damage(
			DamageInfo.new(enemy.current_hp, DamageType.PURE, attacker_name),
			GameManager.MY_PLAYER if ObjectHelpers.valid_instance(GameManager.MY_PLAYER) else null
	)