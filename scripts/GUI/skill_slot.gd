class_name SkillSlot

extends Control

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
var skill: Skill
var slot_number: int

func _ready():
	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())

func _on_mouse_entered():
	if not skill: return
	GameManager.show_tooltip(skill.skill_name, skill.get_description())

func _on_mouse_exited():
	if not skill: return
	GameManager.hide_tooltip()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		KeyboardHelper.key_pressed(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1], GameManager.MY_PLAYER)

func initialize(p_skill: Skill, _slot_number: int):
	skill = p_skill
	slot_number = _slot_number
	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])
	if skill.type == SkillType.PASSIVE: hotkey.visible = false
	sprite.region_rect = skill.region_rect

func _process(_delta: float) -> void:
	if not skill: return

	var remaining_cooldown := skill.get_remaining_cooldown()
	if remaining_cooldown > 0:
		%LabelCoolDown.visible = true
		%LabelCoolDown.text = StringHelpers.format_float(remaining_cooldown, 1)
	else:
		%LabelCoolDown.visible = false
