class_name GuiEffects

extends HBoxContainer

enum Type {MY_EFFECTS, TARGET_EFFECTS}

const MARGIN_LEFT := 4

var my_owner: Entity
@export var _type: Type = Type.MY_EFFECTS

func _ready() -> void:
	clean_effects()
	EventBus.connect(EventBus.NEW_TARGET_SELECTED, func(_owner: Entity, _target: Entity): _on_new_target_selected(_owner, _target))

func _on_new_target_selected(_owner: Entity, _target: Entity) -> void:
	if not _type == Type.TARGET_EFFECTS: return
	clean_effects()
	_add_current_effects(_target)

func _process(_delta: float) -> void:
	if GameManager.MY_PLAYER == null:
		if get_effects().size() > 0:
			clean_effects()
		return
	

func add_effect(effect: CombatEffect) -> void:
	add_child(GuiEffect.get_instance(effect), true)
	_sort_children_by_effect_name()

func remove_effects_by_ids(ids_to_remove: Array[int]) -> void:
	for gui_effect in get_children():
		if gui_effect._effect.id in ids_to_remove:
			gui_effect.queue_free()
	_sort_children_by_effect_name()

func _add_current_effects(target: Entity) -> void:
	if not target: return
	for effect in target.effects_helper.get_effects():
		add_effect(effect)

func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for gui_effect in get_children():
		effects.append(gui_effect._effect as CombatEffect)
	return effects

func clean_effects() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

func _sort_children_by_effect_name() -> void:
	var gui_effects := get_children().filter(func(c): return c is GuiEffect)

	gui_effects.sort_custom(func(a, b):
		if a._effect.is_permanent != b._effect.is_permanent: return a._effect.is_permanent
		if a._effect.unique_id != b._effect.unique_id: return a._effect.unique_id < b._effect.unique_id
		return a._effect.effect_name < b._effect.effect_name
	)

	for i in gui_effects.size(): move_child(gui_effects[i], i)
