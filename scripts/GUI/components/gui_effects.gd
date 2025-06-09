class_name GuiEffects

extends HBoxContainer

const TARGET_EFFECTS_INSTANCE = "TargetEffects"
const MY_EFFECTS_INSTANCE = "MyEffects"

const MARGIN_LEFT := 4

var my_owner: Entity

func _ready() -> void:
	clean_effects()
	EventBus.connect(EventBus.NEW_TARGET_SELECTED, func(_owner: Entity, _target: Entity): _on_new_target_selected(_owner, _target))

func _on_new_target_selected(_owner: Entity, _target: Entity) -> void:
	if name != TARGET_EFFECTS_INSTANCE: return
	if not _owner.is_my_player(): return
	clean_effects()

func _process(_delta: float) -> void:
	if GameManager.MY_PLAYER == null:
		if get_effects().size() > 0:
			clean_effects()
		return
	

func add_effect(effect: CombatEffect) -> void:
	add_child(GuiEffect.get_instance(effect), true)

func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for gui_effect in get_children():
		effects.append(gui_effect._effect as CombatEffect)
	return effects

func clean_effects() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()