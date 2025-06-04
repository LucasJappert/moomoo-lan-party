extends CanvasLayer

@onready var _skills_bar = $SkillsBarContainer/SkillsBar

# Panel Bottom Left
@onready var _hp_ball = $PanelBL/HpBall
@onready var _current_exp_rect = $PanelBL/CurrentExpRect
@onready var _level = $PanelBL/Level
@onready var _stats1_lab1 = $PanelBL/ContainerStats1Values/Lab1
@onready var _stats1_lab2 = $PanelBL/ContainerStats1Values/Lab2
@onready var _stats1_lab3 = $PanelBL/ContainerStats1Values/Lab3
@onready var _stats1_lab4 = $PanelBL/ContainerStats1Values/Lab4
@onready var _stats1_lab5 = $PanelBL/ContainerStats1Values/Lab5
@onready var _stats1_lab6 = $PanelBL/ContainerStats1Values/Lab6
@onready var _stats2_lab1 = $PanelBL/ContainerStats2Values/Lab1
@onready var _stats2_lab2 = $PanelBL/ContainerStats2Values/Lab2
@onready var _stats2_lab3 = $PanelBL/ContainerStats2Values/Lab3
@onready var _stats2_lab4 = $PanelBL/ContainerStats2Values/Lab4
@onready var _stats2_lab5 = $PanelBL/ContainerStats2Values/Lab5
@onready var _stats2_lab6 = $PanelBL/ContainerStats2Values/Lab6

# Panel Bottom Right
@onready var _mana_ball = $PanelBR/ManaBall
@onready var _hp_label = $SkillsBarContainer/HpLabel
@onready var _skill_slots_container = $SkillsBarContainer/SkillSlotsContainer

var _original_ball_size: Vector2
var _original_ball_pos_y: float
var _original_ball_rect_pos_y: float
const EXP_BAR_FULL_SIZE = Vector2i(612, 27)
# var exp_bar_position = Vector2(-EXP_BAR_FULL_SIZE.x * 0.5, -EXP_BAR_FULL_SIZE.y * 0.5)

var _player_skills: Array[Skill] = []


func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_host()
	GameManager.spawn_moomoo()
	
	EnemiesWavesController.start_wave()
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_client()


func _ready() -> void:
	if multiplayer.is_server() && not Main.HOSTED_GAME: return

	%HostGameButton.connect("pressed", _on_host_game_pressed)
	%JoinAsPlayerButton.connect("pressed", _on_join_as_player_pressed)
	%MultiplayerHUD.show()
	_hp_ball.modulate = Color(0.8, 0, 0)
	_mana_ball.modulate = Color(0, 0.4, 0.8)
	_original_ball_size = _hp_ball.region_rect.size
	_original_ball_pos_y = _hp_ball.position.y
	_original_ball_rect_pos_y = _hp_ball.region_rect.position.y

	_current_exp_rect.size.y = EXP_BAR_FULL_SIZE.y
	# _skills_bar.set_visible(false)

func _process(_delta: float) -> void:
	if not Main.MY_PLAYER: return

	_hp_label.text = "%d/%d" % [Main.MY_PLAYER.combat_data.current_hp, Main.MY_PLAYER.combat_data.get_total_hp()]
	_update_hp_ball_sprite()
	_update_mana_ball_sprite()
	_update_exp_bar()
	_update_slots_of_skills()
	_update_panel_bottom_left()

func _update_hp_ball_sprite():
	_update_ball_sprite(
		_hp_ball,
		Main.MY_PLAYER.combat_data.current_hp,
		Main.MY_PLAYER.combat_data.get_total_hp()
	)
func _update_mana_ball_sprite():
	_update_ball_sprite(
		_mana_ball,
		Main.MY_PLAYER.combat_data.current_mana,
		Main.MY_PLAYER.combat_data.get_total_mana()
	)
func _update_ball_sprite(ball_sprite: Sprite2D, current_value: int, max_value: int) -> void:
	var percent: float = clamp(current_value / float(max_value), 0.0, 1.0)
	var visible_height := int(_original_ball_size.y * percent)
	var crop_from_top := _original_ball_size.y - visible_height

	ball_sprite.region_rect = Rect2(
		Vector2(ball_sprite.region_rect.position.x, _original_ball_rect_pos_y + crop_from_top),
		Vector2(_original_ball_size.x, visible_height)
	)

	ball_sprite.position.y = _original_ball_pos_y + crop_from_top

func _update_exp_bar():
	var current_level = Main.MY_PLAYER.current_level
	var percent: float = clamp(Main.MY_PLAYER.current_exp / float(Player.get_exp_per_level(current_level)), 0.0, 1.0)
	_current_exp_rect.size.x = int(EXP_BAR_FULL_SIZE.x * percent)

func _update_slots_of_skills():
	if _player_skills.is_empty():
		_player_skills = Main.MY_PLAYER.combat_data.skills
		_update_region_of_skill_slots()


	# for i in range(Main.MY_PLAYER.combat_data.skills.size()):
	# 	print(Main.MY_PLAYER.combat_data.skills[i].name)


# region 	INTERNAL AUXILIARY METHODS
func _update_region_of_skill_slots() -> void:
	var skill_children = _skill_slots_container.get_children()
	for i in range(skill_children.size()):
		if _player_skills[i] == null: continue

		skill_children[i].region_rect = _player_skills[i].rect_region

func _update_panel_bottom_left() -> void:
	_level.text = str(Main.MY_PLAYER.current_level)
	var total_stats = Main.MY_PLAYER.combat_data.get_total_stats_including_extras_by_attributes()
	_stats1_lab1.text = str(total_stats.strength)
	_stats1_lab2.text = str(total_stats.agility)
	_stats1_lab3.text = str(total_stats.intelligence)
	_stats1_lab4.text = StringHelpers.format_float(total_stats.move_speed) # str(total_stats.move_speed)
	_stats1_lab5.text = StringHelpers.format_float(total_stats.attack_speed)
	_stats1_lab6.text = StringHelpers.format_percent(total_stats.life_steal_percent)

	_stats2_lab1.text = StringHelpers.format_float(total_stats.physical_attack_power)
	_stats2_lab2.text = StringHelpers.format_float(total_stats.magic_attack_power)
	_stats2_lab3.text = StringHelpers.format_percent(total_stats.physical_defense_percent) + " / " + StringHelpers.format_percent(total_stats.magic_defense_percent)
	_stats2_lab4.text = StringHelpers.format_percent(total_stats.evasion)
	_stats2_lab5.text = StringHelpers.format_percent(total_stats.stun_chance)
	_stats2_lab6.text = StringHelpers.format_percent(total_stats.crit_chance) + " (*" + StringHelpers.format_float(total_stats.crit_multiplier) + ")"


# endregion INTERNAL AUXILIARY METHODS