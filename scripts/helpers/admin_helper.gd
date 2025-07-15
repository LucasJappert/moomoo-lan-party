class_name AdminHelper

static func kill_all_enemies():
	for enemy in GameManager.get_enemies():
		enemy.server_receive_damage(DamageInfo.new(enemy.current_hp, DamageType.PURE, GameManager.MY_PLAYER.name), GameManager.MY_PLAYER)