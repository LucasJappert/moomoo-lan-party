extends Node

const HERO_SELECTED := "hero_selected"
signal hero_selected(player: Player)
func emit_hero_selected(player: Player, _start_game := false): emit_signal(HERO_SELECTED, player, _start_game)
func connect_to_hero_selected(p_callback: Callable) -> void:
	EventBusHeroPicker.connect(HERO_SELECTED, p_callback)