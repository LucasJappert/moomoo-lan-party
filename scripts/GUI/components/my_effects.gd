class_name MyEffects

extends HBoxContainer

const MARGIN_LEFT := 4

func _ready() -> void:
	clean_effects()

func _process(_delta: float) -> void:
	if GameManager.MY_PLAYER == null:
		if get_effects().size() > 0:
			clean_effects()

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