class_name HeroPickerScene
extends CanvasLayer

const HERO_BOX_SCENE: PackedScene = preload("res://scenes/GUI/hero_picker/hero_box.tscn")

@onready var grid_heros_container: GridContainer = %GridHerosContainer
@onready var skills_container: GridContainer = %SkillsContainer
@onready var hero_box_preview: HeroBox = %HeroBoxPreview
@onready var name_and_alias: Label = %NameAndAlias
@onready var choose_and_play_button: NinePatchRect = %ChooseAndPlayButton

var selected_hero: Player


func _ready() -> void:
	EventBusHeroPicker.connect_to_hero_selected(func(player: Player): _on_hero_selected(player))
	choose_and_play_button.connect("gui_input", func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if selected_hero: _start_game()
	)

	choose_and_play_button.modulate = Color(0.4, 0.4, 0.4, 1)
	_clean_hero_selected()
	_clean_grid_heros_container()
	_set_hero_options()

# region	GETTERS
func get_skill_slots() -> Array[SkillSlot]:
	var result: Array[SkillSlot] = []
	for child in skills_container.get_children():
		if child is SkillSlot:
			result.append(child as SkillSlot)
	return result

func get_hero_options() -> Array[HeroBox]:
	var result: Array[HeroBox] = []
	for child in grid_heros_container.get_children():
		result.append(child)
	return result

func get_selected_hero_box() -> HeroBox:
	for hero_box in get_hero_options():
		if hero_box.is_selected: return hero_box
	return null
# endregion GETTERS

# region	SETTERS
func _start_game() -> void:
	GameManager.start_game(selected_hero.extra_info.key_type)

func _set_effects_for_selected_hero_box() -> void:
	for hero_box in get_hero_options():
		if not selected_hero or not hero_box.player:
			continue

		if hero_box.player.extra_info.key_type == selected_hero.extra_info.key_type:
			hero_box.set_selected_effect(true)
			continue

		hero_box.set_selected_effect(false)

func _clean_hero_selected() -> void:
	_set_skills()
	hero_box_preview.set_texture()
	name_and_alias.text = ""

func _set_hero_options() -> void:
	for i in range(16):
		var hero_box = HERO_BOX_SCENE.instantiate()
		if i < HeroBase.REGISTERED_HEROS.size():
			var hero_class = HeroBase.REGISTERED_HEROS[i]
			hero_box.set_hero_type(hero_class.LONG_NAME)
		grid_heros_container.add_child(hero_box)

func _on_hero_selected(player: Player) -> void:
	selected_hero = player
	choose_and_play_button.modulate = Color(1, 1, 1, 1)
	_set_skills(player)
	hero_box_preview.set_texture(player.extra_info.rects[0])
	name_and_alias.text = player.extra_info.key_type + "\n (" + player.extra_info.alias + ")"
	_set_effects_for_selected_hero_box()


func _set_skills(_hero: Entity = null) -> void:
	var _slots := get_skill_slots()
	for i in range(_slots.size()):
		if not _hero:
			_slots[i].skill_updated(null, null, i + 1)
			continue

		var _skill: Skill = _hero._skills[i] if i < _hero._skills.size() else null
		_slots[i].skill_updated(_skill, _hero, i + 1)

func _clean_grid_heros_container() -> void:
	for child in grid_heros_container.get_children():
		grid_heros_container.remove_child(child)
		child.queue_free()
# endregion SETTERS