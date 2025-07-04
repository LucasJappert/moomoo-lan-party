class_name DamagePopup

extends Control

@onready var label = $CenterContainer/Label
@onready var anim = $AnimationPlayer

func show_damage(text: String, color: Color = Color.RED, speed_scale: float = 1.0):
	label.text = text
	label.modulate = color
	
	anim.speed_scale = speed_scale
	anim.play("show")

	await anim.animation_finished
	if is_inside_tree():
		get_parent().remove_child(self)
	DamagePopupPool.recycle(self)
