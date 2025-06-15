class_name SkillSlot

extends Control

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
var skill: Skill
var slot_number: int

var HOTKEY_BY_SLOT = ["A", "S", "D", "F"]

func _ready():
	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())

func _on_mouse_entered():
	if not skill: return
	GameManager.show_tooltip(skill.skill_name, skill.get_description())

func _on_mouse_exited():
	if not skill: return
	GameManager.hide_tooltip()

func initialize(p_skill: Skill, _slot_number: int):
	skill = p_skill
	slot_number = _slot_number
	hotkey.text = HOTKEY_BY_SLOT[slot_number - 1]
	sprite.region_rect = skill.region_rect

func _process(_delta: float) -> void:
	if not skill: return

	var remaining_cooldown := skill.get_remaining_cooldown()
	if remaining_cooldown > 0:
		%LabelCoolDown.visible = true
		%LabelCoolDown.text = StringHelpers.format_float(remaining_cooldown)
	else:
		%LabelCoolDown.visible = false
