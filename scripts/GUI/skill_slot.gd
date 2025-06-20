class_name SkillSlot

extends Control

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
@onready var label_cool_down = $LabelCoolDown
var skill: Skill
var slot_number: int
var current_color: Color = Color.WHITE
const CAN_USE_COLOR = Color.WHITE
const CANT_USE_COLOR = Color(0.5, 0.5, 0.5)

func initialize(p_skill: Skill, _slot_number: int):
	skill = p_skill
	slot_number = _slot_number
	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])
	if skill.item_skill_base[0].type == SkillType.PASSIVE: hotkey.visible = false
	sprite.region_rect = skill.region_rect

func _ready():
	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())
	label_cool_down.visible = false

func _on_mouse_entered():
	if not skill: return
	GameManager.show_tooltip(skill.item_skill_base[0].my_name, skill.get_description())

func _on_mouse_exited():
	if not skill: return
	GameManager.hide_tooltip()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		KeyboardHelper.key_pressed(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1], GameManager.MY_PLAYER)

func _process(_delta: float) -> void:
	if not GameManager.MY_PLAYER: return
	if not skill: return

	if skill.can_use(GameManager.MY_PLAYER):
		label_cool_down.visible = false
		sprite.modulate = CAN_USE_COLOR
		return
	
	# Cant use
	sprite.modulate = CANT_USE_COLOR
	var remaining_cooldown := skill.get_remaining_cooldown()
	if remaining_cooldown > 0:
		label_cool_down.visible = true
		label_cool_down.text = StringHelpers.format_float(remaining_cooldown, 1)
	else:
		label_cool_down.visible = false
