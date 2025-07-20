class_name GuiEffects

extends HBoxContainer

enum Type {MY_EFFECTS, TARGET_EFFECTS}

const MARGIN_LEFT := 4

var _entity_info: Entity
@export var TYPE: Type = Type.MY_EFFECTS

func _ready() -> void:
	clean_effects()
	EventBus.connect_to_new_target_to_attack_selected(func(_owner: Entity, _target: Entity): _on_new_target_to_attack_selected(_owner, _target))
	EventBus.connect_to_new_target_view_selected(func(_owner: Entity, _target: Entity): _on_new_target_view_selected(_owner, _target))
	EventBus.connect_to_effect_added(func(_owner: Entity, effect: CombatEffect): _try_add_effect(_owner, effect))
	
	EventBus.connect_to_effects_removed(Callable(self, "_on_effects_removed"))


func _on_effects_removed(_owner: Entity, ids_to_remove: Array[int]) -> void:
	if not ObjectHelpers.valid_instance(_owner): return
	_try_remove_effects_by_ids(_owner, ids_to_remove)

func _on_new_target_to_attack_selected(_owner: Entity, _target: Entity) -> void:
	if not _owner.is_my_player(): return
	# if not _type == Type.TARGET_EFFECTS: return
	# clean_effects()
	# if not _target: return
	
	# _add_current_effects()
func _on_new_target_view_selected(_owner: Entity, _target: Entity) -> void:
	# if not ObjectHelpers.is_my_player(_owner): return
	_entity_info = _target
	if _entity_info == null: _entity_info = GameManager.MY_PLAYER

	clean_effects()
	_add_current_effects()

func _process(_delta: float) -> void:
	if GameManager.MY_PLAYER == null:
		if get_effects().size() > 0:
			clean_effects()
		return
	if _entity_info == null: _entity_info = GameManager.MY_PLAYER
	

func _try_add_effect(_owner: Entity, effect: CombatEffect) -> void:
	if TYPE != Type.MY_EFFECTS: return
	if _entity_info.name != _owner.name: return

	add_child(GuiEffect.get_instance(effect), true)
	_sort_children_by_effect_name()

func _try_remove_effects_by_ids(_owner: Entity, ids_to_remove: Array[int]) -> void:
	if ObjectHelpers.is_null(_entity_info): return
	if _entity_info.name != _owner.name: return

	for gui_effect in get_children():
		if gui_effect._effect.id in ids_to_remove:
			gui_effect.queue_free()
	_sort_children_by_effect_name()

func _add_current_effects() -> void:
	if not _entity_info: return
	for effect in _entity_info.effects_helper.get_effects():
		_try_add_effect(_entity_info, effect)

func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for gui_effect in get_children():
		effects.append(gui_effect._effect as CombatEffect)
	return effects

func clean_effects() -> void:
	for child in get_children():
		child.queue_free()

func _sort_children_by_effect_name() -> void:
	var gui_effects := get_children().filter(func(c): return c is GuiEffect)

	gui_effects.sort_custom(func(a, b):
		if a._effect.is_permanent != b._effect.is_permanent: return a._effect.is_permanent
		if a._effect.unique_id != b._effect.unique_id: return a._effect.unique_id < b._effect.unique_id
		return a._effect.effect_name < b._effect.effect_name
	)

	for i in gui_effects.size(): move_child(gui_effects[i], i)
