class_name AdminHelper

static func kill_all_enemies():
	for enemy in GameManager.get_enemies():
		enemy.update_current_hp(-enemy.get_total_hp(), GameManager.MY_PLAYER)