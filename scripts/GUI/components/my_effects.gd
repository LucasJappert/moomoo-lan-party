class_name MyEffects

extends HBoxContainer

const MARGIN_LEFT := 4

func _ready() -> void:
	print("Remove children")
	for child in get_children():
		remove_child(child)
		child.queue_free()


func add_effect(effect: CombatEffect) -> void:
	add_child(GuiEffect.get_instance(effect), true)