class_name DamagePopup

extends Control

@onready var label = $Label
@onready var anim = $AnimationPlayer

func show_damage(amount: int, color: Color = Color.RED):
	label.text = str(amount)
	label.modulate = color
	anim.play("show")

	await anim.animation_finished
	if is_inside_tree():
		get_parent().remove_child(self)
	DamagePopupPool.recycle(self)
