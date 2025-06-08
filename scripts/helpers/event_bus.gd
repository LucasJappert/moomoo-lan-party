extends Node

const NEW_TARGET_SELECTED := "new_target_selected"
signal new_target_selected(p_target: Entity)

func emit_new_target_selected(p_target: Entity):
	emit_signal(NEW_TARGET_SELECTED, p_target)