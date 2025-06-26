extends Node

const EFFECT_REMOVED := "effect_removed"
signal effect_removed(p_owner: Entity, p_effect: CombatEffect)
func emit_effect_removed(p_owner: Entity, p_effect: CombatEffect) -> void:
	emit_signal(EFFECT_REMOVED, p_owner, p_effect)
func connect_to_effect_removed(p_callback: Callable) -> void:
	EventBus.connect(EFFECT_REMOVED, p_callback)

const EFFECT_ADDED := "effect_added"
signal effect_added(p_owner: Entity, p_effect: CombatEffect)
func emit_effect_added(p_owner: Entity, p_effect: CombatEffect) -> void:
	emit_signal(EFFECT_ADDED, p_owner, p_effect)
func connect_to_effect_added(p_callback: Callable) -> void:
	EventBus.connect(EFFECT_ADDED, p_callback)

const TOTAL_HP_CHANGED := "total_hp_changed"
signal total_hp_changed(p_owner: Entity)
func emit_total_hp_changed(p_owner: Entity): emit_signal(TOTAL_HP_CHANGED, p_owner)
func connect_to_total_hp_changed(p_callback: Callable) -> void:
	EventBus.connect(TOTAL_HP_CHANGED, p_callback)

# const CURRENT_HP_CHANGED := "current_hp_changed"
# signal current_hp_changed(p_owner: Entity)
# func emit_current_hp_changed(p_owner: Entity): emit_signal(CURRENT_HP_CHANGED, p_owner)
# func connect_to_current_hp_changed(p_callback: Callable) -> void:
# 	EventBus.connect(CURRENT_HP_CHANGED, p_callback)

const WAVE_FINILIZED := "wave_finilized"
signal wave_finilized()
func emit_wave_finilized() -> void:
	emit_signal(WAVE_FINILIZED)
func connect_to_wave_finilized(p_callback: Callable) -> void:
	EventBus.connect(WAVE_FINILIZED, p_callback)

const WINDOW_FOCUSED := "window_focused"
signal window_focused()
func emit_window_focused() -> void:
	emit_signal(WINDOW_FOCUSED)

const WINDOW_UNFOCUSED := "window_unfocused"
signal window_unfocused()
func emit_window_unfocused() -> void:
	emit_signal(WINDOW_UNFOCUSED)

const NEW_TARGET_SELECTED := "new_target_selected"
signal new_target_selected(p_owner: Entity, p_target: Entity)
func emit_new_target_selected(p_owner: Entity, p_target: Entity):
	emit_signal(NEW_TARGET_SELECTED, p_owner, p_target)

const ITEM_UPDATED := "item_updated"
signal item_updated(p_owner: Entity, slot_item_info: SlotItemInfo, p_target: Entity)
func emit_item_updated(p_owner: Entity, slot_item_info: SlotItemInfo, p_target: Entity):
	emit_signal(ITEM_UPDATED, p_owner, slot_item_info, p_target)

const SKILL_POINTS_TO_ASSIGN_CHANGED := "skill_points_to_assign_changed"
signal skill_points_to_assign_changed(p_owner: Entity)
func emit_skill_points_to_assign_changed(p_owner: Entity):
	emit_signal(SKILL_POINTS_TO_ASSIGN_CHANGED, p_owner)
func connect_to_skill_points_to_assign_changed(p_callback: Callable) -> void:
	EventBus.connect(SKILL_POINTS_TO_ASSIGN_CHANGED, p_callback)

const SKILL_UPGRADED := "skill_upgraded"
signal skill_upgraded(p_owner: Entity, p_skill: Skill)
func emit_skill_upgraded(p_owner: Entity):
	emit_signal(SKILL_UPGRADED, p_owner)
func connect_to_skill_upgraded(p_callback: Callable) -> void:
	EventBus.connect(SKILL_UPGRADED, p_callback)