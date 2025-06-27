class_name EffectsHelper

extends MyInitAuxiliary

var _effects: Array[CombatEffect] = []
var _my_owner: Entity

func _init() -> void:
	super._init()

func set_my_owner(p_owner: Entity) -> void:
	_my_owner = p_owner

func _process(_delta: float) -> void:
	var effects_ids_to_remove: Array[int] = []
	for effect in _effects:
		effect._process(_delta)
		if effect.is_cooldown_finished: effects_ids_to_remove.append(effect.id)

	remove_effect_by_ids(effects_ids_to_remove)

func get_effects() -> Array[CombatEffect]:
	return _effects

func get_effect_by_name(effect_name: String) -> CombatEffect:
	for effect in _effects:
		if effect.effect_name == effect_name: return effect
	return null

func get_effect_by_id(id: int) -> CombatEffect:
	for effect in _effects:
		if effect.id == id: return effect
	return null

func add_effect(p_effect: CombatEffect) -> void:
	_server_verifications_before_adding_effect(p_effect)
	_effects.append(p_effect)
	notify_changes_to_subscribers()
	
	_try_to_update_my_gui(p_effect)

	if GameManager.AM_I_HOST: # Notify if we are host
		_my_owner.rpc_handler.notify_effect_added_to_clients(p_effect)

func remove_effect_by_ids(ids: Array[int]) -> void:
	if not ids: return
	_remove_effects_by_predicate(func(effect): return effect.id in ids)

func remove_effect_by_name(effect_name: String) -> void:
	_remove_effects_by_predicate(func(effect): return effect.effect_name == effect_name)

func _remove_effects_by_predicate(predicate: Callable) -> void:
	var removed_ids: Array[int] = []
	for effect in _effects.duplicate(): # use `.duplicate()` to avoid modifying the collection while iterating
		if not predicate.call(effect): continue

		removed_ids.append(effect.id)
		_effects.erase(effect)
	
	notify_changes_to_subscribers()

	if GameManager.MY_PLAYER:
		if _my_owner.is_my_player(): # Remove effects from my GUI
			GameManager.my_main.gui_scene.my_effects.remove_effects_by_ids(removed_ids)
		if _my_owner.name == GameManager.MY_PLAYER.combat_data.target_entity_name: # Remove effects from target GUI
			GameManager.my_main.gui_scene.target_effects.remove_effects_by_ids(removed_ids)

	if GameManager.AM_I_HOST and removed_ids:
		_my_owner.rpc_handler.notify_effects_removed_to_clients(removed_ids)

func _server_verifications_before_adding_effect(p_effect: CombatEffect) -> void:
	if not GameManager.AM_I_HOST: return

	var current_stacks := 0
	var matching_effects: Array[CombatEffect] = []

	for effect in get_effects():
		if effect.effect_name == p_effect.effect_name:
			current_stacks += 1
			matching_effects.append(effect)

	var ids_to_remove: Array[int] = []
	if current_stacks >= p_effect.max_stacks:
		if not p_effect.stats.keep_latest_stacks: return

		matching_effects.sort_custom(func(a, b): return a._elapsed > b._elapsed)

		var effects_to_remove = current_stacks - p_effect.max_stacks + 1
		for i in range(effects_to_remove):
			ids_to_remove.append(matching_effects[i].id)

	matching_effects.clear()
	remove_effect_by_ids(ids_to_remove)

func _try_to_update_my_gui(p_effect: CombatEffect) -> void:
	if not GameManager.MY_PLAYER: return

	if _my_owner.is_my_player(): # Update my GUI
		GameManager.my_main.gui_scene.my_effects.add_effect(p_effect)
	if _my_owner.name == GameManager.MY_PLAYER.combat_data.target_entity_name: # Update target GUI
		GameManager.my_main.gui_scene.target_effects.add_effect(p_effect)
