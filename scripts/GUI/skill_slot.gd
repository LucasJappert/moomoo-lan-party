class_name SkillSlot

extends Control

const SPECIAL_SKILL_LEVEL_REQUIREMENTS := {
	1: 6, # Level 1 of the skill can be learned at level 6
	2: 9, # Level 2 of the skill can be learned at level 9
	3: 12, # Level 3 of the skill can be learned at level 12
}
const SKILL_LEVEL_REQUIREMENTS := {
	1: 0, # Level 1 of the skill can be learned from the beginning
	2: 3, # Level 2 of the skill can be learned at level 3
	3: 5, # Level 3 of the skill can be learned at level 5
}

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
@onready var label_cool_down = $LabelCoolDown
@onready var container_of_skill_levels: Panel = $Panel
@onready var panel1: Panel = $Panel/CenterContainer/HBoxContainer/Panel1
@onready var panel2: Panel = $Panel/CenterContainer/HBoxContainer/Panel2
@onready var panel3: Panel = $Panel/CenterContainer/HBoxContainer/Panel3
@onready var upgrade_button = $UpgradeButton
var skill: Skill
var slot_number: int
var _STYLE_BLACK := StyleBoxFlat.new()
var _STYLE_BEIGE := StyleBoxFlat.new()
var _is_my_player_owner: bool
var HERO_PICKER_SCENE_NAME = "HeroPickerScene"


func _ready():
	# Commons settings
	label_cool_down.visible = false
	upgrade_button.visible = false
	_initialize_styles()
	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())
	
	# Try settings for hero picker
	if _try_settings_for_hero_picker(): return

	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[get_index()])

	upgrade_button.gui_input.connect(func(event):
		if not GameManager.MY_PLAYER: return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			GameManager.MY_PLAYER.rpc_handler.send_skill_uppgrade_button_pressed_to_server(slot_number)
		)

	EventBus.connect_to_skill_upgraded(func(_p_owner: Entity, _upgraded_skill: Skill, _slot_number: int): skill_updated(_upgraded_skill, _p_owner, _slot_number))
	EventBus.connect_to_skill_points_to_assign_changed(func(_p_owner: Entity): _update_controls())

func _try_settings_for_hero_picker():
	if get_owner().name != HERO_PICKER_SCENE_NAME: return false

	hotkey.visible = false
	container_of_skill_levels.visible = false


func _process(_delta: float) -> void:
	if not _is_my_player_owner: return _lock_slot()
	if not skill: return
	if not GameManager.MY_PLAYER: return

	if skill.can_use(GameManager.MY_PLAYER):
		label_cool_down.visible = false
		sprite.modulate = ItemSkillBase.CAN_USE_COLOR
		return
	
	# Cant use
	sprite.modulate = ItemSkillBase.CANT_USE_COLOR
	var remaining_cooldown := skill.get_remaining_cooldown()
	if remaining_cooldown > 0:
		label_cool_down.visible = true
		label_cool_down.text = StringHelpers.format_float_compact(remaining_cooldown, 1)
	else:
		label_cool_down.visible = false

# region 	GETTERS

# endregion GETTERS

# region 	SETTERS
func _clean_slot():
	skill = null
	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])
	sprite.region_rect = Rect2(0, 0, 0, 0)

func skill_updated(new_skill: Skill, _owner: Entity, _slot_number: int):
	if slot_number == 0: slot_number = _slot_number
	if slot_number != _slot_number: return
	
	_is_my_player_owner = _owner.is_my_player() if _owner else false
	hotkey.visible = true

	_set_slot_from_skill(new_skill)

	_update_controls()
	
func _set_slot_from_skill(new_skill: Skill):
	skill = new_skill
	if not skill: return _clean_slot()

	hotkey.visible = skill.get_safe_learned_skill().type == SkillType.ACTIVE
	sprite.region_rect = skill.region_rect

func _on_skill_changed():
	_update_controls()

func _update_controls():
	_refresh_upgrade_button()

	var panels_of_skill_level: Array[Panel] = [panel1, panel2, panel3]
	for i in range(Skill.AVAILABLE_LEVELS):
		panels_of_skill_level[i].visible = skill != null
		if skill and skill.learned_level > i:
			panels_of_skill_level[i].add_theme_stylebox_override("panel", _STYLE_BEIGE)
			continue

		panels_of_skill_level[i].add_theme_stylebox_override("panel", _STYLE_BLACK)

func _refresh_upgrade_button():
	if not skill or not _is_my_player_owner:
		upgrade_button.visible = false
		return

	var next_skill_level := skill.learned_level + 1
	var level_requirement: int = SKILL_LEVEL_REQUIREMENTS.get(next_skill_level, INF)
	if slot_number == 4: level_requirement = SPECIAL_SKILL_LEVEL_REQUIREMENTS.get(next_skill_level, INF)
		
	upgrade_button.visible = (
		GameManager.MY_PLAYER.skill_points_to_assign > 0
		&& skill.learned_level < Skill.AVAILABLE_LEVELS
		&& GameManager.MY_PLAYER.level >= level_requirement
	)

func _initialize_styles():
	# Fondo #000000
	_STYLE_BLACK.bg_color = Color.BLACK
	_STYLE_BLACK.set_border_width_all(2)
	_STYLE_BLACK.border_color = Color.BLACK
	_STYLE_BLACK.shadow_color = Color(1, 1, 1)
	_STYLE_BLACK.shadow_size = 1

	# Fondo #d3c5ac
	_STYLE_BEIGE.bg_color = Color(0.8, 0.8, 0.7)
	_STYLE_BEIGE.set_border_width_all(2)
	_STYLE_BEIGE.border_color = Color.BLACK
	_STYLE_BEIGE.shadow_color = Color(1, 1, 1)
	_STYLE_BEIGE.shadow_size = 1

func _lock_slot() -> void:
	label_cool_down.visible = false
	sprite.modulate = ItemSkillBase.CANT_USE_COLOR

# endregion SETTERS


func _on_mouse_entered():
	if not skill: return
	MyTooltip.show_tooltip(skill.item_skill_base[0].my_name, skill.get_description(false), 20)

func _on_mouse_exited():
	if not skill: return
	MyTooltip.hide_tooltip()

func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not _is_my_player_owner: return

		GameManager.MY_PLAYER.rpc_handler.notify_key_pressed_to_server(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])
