extends Node

const NEW_TARGET_SELECTED := "new_target_selected"
signal new_target_selected(p_owner: Entity, p_target: Entity)
func emit_new_target_selected(p_owner: Entity, p_target: Entity):
	emit_signal(NEW_TARGET_SELECTED, p_owner, p_target)

const ITEM_UPDATED := "item_updated"
signal item_updated(p_owner: Entity, slot_item_info: SlotItemInfo, p_target: Entity)
func emit_item_updated(p_owner: Entity, slot_item_info: SlotItemInfo, p_target: Entity):
	emit_signal(ITEM_UPDATED, p_owner, slot_item_info, p_target)