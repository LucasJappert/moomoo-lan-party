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
@onready var panel1 = $Panel/CenterContainer/HBoxContainer/Panel1
@onready var panel2 = $Panel/CenterContainer/HBoxContainer/Panel2
@onready var panel3 = $Panel/CenterContainer/HBoxContainer/Panel3
@onready var upgrade_button = $UpgradeButton
var skill: Skill
var slot_number: int
var _STYLE_BLACK := StyleBoxFlat.new()
var _STYLE_BEIGE := StyleBoxFlat.new()

func initialize(p_skill: Skill, _slot_number: int):
	skill = p_skill
	# skill.subscribe_to_changes(Callable(self, "_on_skill_changed")) # Ver si podemos usar una lambda
	slot_number = _slot_number
	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])
	if skill.item_skill_base[0].type == SkillType.PASSIVE: hotkey.visible = false
	sprite.region_rect = skill.region_rect

	initialize_styles()
	update_controls()
	
func _ready():
	label_cool_down.visible = false
	upgrade_button.visible = false

	hotkey.text = OS.get_keycode_string(KeyboardHelper.SKILL_HOTKEYS[get_index()])

	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())

	upgrade_button.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			GameManager.MY_PLAYER.rpc_handler.send_skill_uppgrade_button_pressed_to_server(slot_number)
		)

	EventBus.connect_to_skill_upgraded(func(_p_owner: Entity): update_controls())
	EventBus.connect_to_skill_points_to_assign_changed(func(_p_owner: Entity): update_controls())

		
# region 	GETTERS

# endregion GETTERS

# region 	SETTERS
func _on_skill_changed():
	update_controls()

func update_controls():
	if not skill: return

	var next_skill_level := skill.learned_level + 1
	var level_requirement: int = SKILL_LEVEL_REQUIREMENTS.get(next_skill_level, INF)
	if slot_number == 4: level_requirement = SPECIAL_SKILL_LEVEL_REQUIREMENTS.get(next_skill_level, INF)
		
	upgrade_button.visible = (
		GameManager.MY_PLAYER.skill_points_to_assign > 0
		&& skill.learned_level < Skill.AVAILABLE_LEVELS
		&& GameManager.MY_PLAYER.level >= level_requirement
	)

	var panels = [panel1, panel2, panel3]
	for i in range(Skill.AVAILABLE_LEVELS):
		if skill.learned_level > i:
			panels[i].add_theme_stylebox_override("panel", _STYLE_BEIGE)
			continue

		panels[i].add_theme_stylebox_override("panel", _STYLE_BLACK)

func initialize_styles():
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
# endregion SETTERS


func _on_mouse_entered():
	if not skill: return
	MyTooltip.show_tooltip(skill.item_skill_base[0].my_name, skill.get_description(false), 20)

func _on_mouse_exited():
	if not skill: return
	MyTooltip.hide_tooltip()

func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not GameManager.MY_PLAYER: return
		if GameManager.MY_PLAYER.charged_skill:
			return GameManager.MY_PLAYER.use_charged_skill(GameManager.MY_PLAYER)

		GameManager.MY_PLAYER.rpc_handler.notify_key_pressed_to_server(KeyboardHelper.SKILL_HOTKEYS[slot_number - 1])

func _process(_delta: float) -> void:
	if not GameManager.MY_PLAYER: return
	if not skill: return

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
