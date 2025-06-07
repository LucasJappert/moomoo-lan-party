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
	GameManager.show_tooltip(skill.name, skill.description)

func _on_mouse_exited():
	if not skill: return
	GameManager.hide_tooltip()

func initialize(p_skill: Skill, _slot_number: int):
	skill = p_skill
	slot_number = _slot_number
	hotkey.text = HOTKEY_BY_SLOT[slot_number - 1]
	sprite.region_rect = skill.rect_region
