class_name GUI

extends CanvasLayer

@onready var my_tooltip = $MyTooltip

static var SHOW_DEBUG_DATA = true

var _ORIGINAL_BALL_SIZE: Vector2
var _ORIGINAL_BALL_POS_Y: float
var _ORIGINAL_BALL_RECT_POS_Y: float
var reseted_gui := false


# region Panel TOP LEFT
const _RECT_TARGET_MAX_HP = Rect2(81, 27, 189, 21)
const _RECT_TARGET_MAX_MANA = Rect2(80, 51, 183, 15)
const EXP_BAR_FULL_SIZE = Vector2i(612, 27)
@onready var _panelTL_avatar = $PanelTL/TargetAvatar
@onready var _panel_tl = $PanelTL
@onready var _target_rect_current_hp = $PanelTL/TargetRectCurrentHP
@onready var _target_rect_current_mana = $PanelTL/TargetRectCurrentMana
@onready var _label_target_level = $PanelTL/TargetLevel
@onready var _label_target_current_hp = $PanelTL/TargetCurrentHp
@onready var _label_target_current_mana = $PanelTL/TargetCurrentMana
# endregion

# region Panel BOTTOM LEFT
@onready var _my_player_avatar = $PanelBL/MyPlayerAvatar
@onready var _hp_ball = $PanelBL/HpBall
@onready var _hp_label = $PanelBL/LabelHP
@onready var _current_exp_rect = $PanelBL/CurrentExpRect
@onready var _level = $PanelBL/Level
@onready var _stats1_lab1 = $PanelBL/ContainerStats1Values/Lab1
@onready var _stats1_lab2 = $PanelBL/ContainerStats1Values/Lab2
@onready var _stats1_lab3 = $PanelBL/ContainerStats1Values/Lab3
@onready var _stats1_lab4 = $PanelBL/ContainerStats1Values/Lab4
@onready var _stats1_lab5 = $PanelBL/ContainerStats1Values/Lab5
@onready var _stats1_lab6 = $PanelBL/ContainerStats1Values/Lab6
@onready var _stats2_lab1 = $PanelBL/ContainerStats2Values/Lab1
# @onready var _stats2_lab2 = $PanelBL/ContainerStats2Values/Lab2
@onready var _stats2_lab3 = $PanelBL/ContainerStats2Values/Lab3
@onready var _stats2_lab4 = $PanelBL/ContainerStats2Values/Lab4
@onready var _stats2_lab5 = $PanelBL/ContainerStats2Values/Lab5
@onready var _stats2_lab6 = $PanelBL/ContainerStats2Values/Lab6
@onready var _hero_type = $PanelBL/HeroType
@onready var _hero_alias = $PanelBL/HeroAlias
# endregion

# region Panel BOTTOM RIGHT
@onready var _mana_ball = $PanelBR/ManaBall
@onready var _mana_label = $PanelBR/LabelMana
@onready var _skill_slots_container = $PanelBR/SkillSlotsContainer
# endregion

var _player_skills: Array[Skill] = []
var delta: float


func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	GameManager.spawn_moomoo()
	
	EnemiesWavesController.start_wave()
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	MultiplayerManager.become_client()


func _ready() -> void:
	if multiplayer.is_server() && not MyMain.HOSTED_GAME: return
	
	EventBus.connect(EventBus.NEW_TARGET_SELECTED, func(_owner: Entity, _target: Entity): _on_new_target_selected(_owner, _target))

	%HostGameButton.connect("pressed", _on_host_game_pressed)
	%JoinAsPlayerButton.connect("pressed", _on_join_as_player_pressed)
	%MultiplayerHUD.show()
	_ORIGINAL_BALL_SIZE = _hp_ball.region_rect.size
	_ORIGINAL_BALL_POS_Y = _hp_ball.position.y
	_ORIGINAL_BALL_RECT_POS_Y = _hp_ball.region_rect.position.y

	_current_exp_rect.size.y = EXP_BAR_FULL_SIZE.y

	%HpBallCircle.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		var regen_points = GameManager.MY_PLAYER.combat_data.get_total_stats().hp_regeneration_points
		GameManager.show_tooltip("HP regen", str(regen_points) + " points per second", 200)
	)
	%HpBallCircle.connect("mouse_exited", func(): GameManager.hide_tooltip())

	%ManaBallCircle.connect("mouse_entered", func():
		if not GameManager.MY_PLAYER: return
		var regen_points = GameManager.MY_PLAYER.combat_data.get_total_stats().mana_regeneration_points
		GameManager.show_tooltip("Mana regen", str(regen_points) + " points per second", 200)
	)
	%ManaBallCircle.connect("mouse_exited", func(): GameManager.hide_tooltip())

func reset_gui() -> void:
	_hp_label.text = str(0)
	_mana_label.text = str(0)
	reseted_gui = true

func _process(_delta: float) -> void:
	# TODO: we should instance the gui when the game starts (and we can access the player)
	delta = _delta
	if not GameManager.MY_PLAYER:
		if not reseted_gui: reset_gui()
		return
	if reseted_gui: reseted_gui = false

	_update_panel_top_left()
	_update_panel_bottom_left() # 3388 a 3427
	_update_panel_bottom_right() # 3427 a 3453
	_update_auxiliary_labels(_delta)


# region	SETTERS
func init_scene(player: Player) -> void:
	_set_my_player_avatar_region(player)
	_set_skills(player.combat_data.skills)

func _set_skills(skills: Array[Skill]) -> void:
	if _player_skills.is_empty():
		_player_skills = GameManager.MY_PLAYER.combat_data.skills
	
	var skill_slots = _skill_slots_container.get_children() as Array[SkillSlot]
	for i in range(skill_slots.size()):
		if i >= _player_skills.size(): continue
		skill_slots[i].initialize(_player_skills[i], i + 1)

func _set_my_player_avatar_region(my_player: Player) -> void:
	var rects = HeroTypes.get_rect_frames(my_player.hero_type)
	_my_player_avatar.region_rect = rects[0]

func set_target_avatar_region(region_rect: Rect2) -> void:
	_panelTL_avatar.region_rect = region_rect

func add_effect_to_my_effects(effect: CombatEffect) -> void:
	print("Adding effect to my effects: ", effect)
	%MyEffects.add_effect(effect)
func add_effect_to_target_effects(effect: CombatEffect) -> void:
	%TargetEffects.add_effect(effect)

func _on_new_target_selected(_owner: Entity, _target: Entity) -> void:
	if not _owner.is_my_player(): return

	_update_panel_top_left(false)

	if _target:
		var region_rect = SpritesHelper.get_region_rect_of_sprite(_target.sprite)
		GameManager.my_main.gui_scene.set_target_avatar_region(region_rect)


# endregion SETTERS

# region 	INTERNAL AUXILIARY METHODS

func _update_panel_top_left(use_lerp: bool = true) -> void:
	if not GameManager.MY_PLAYER: return
	if not GameManager.MY_PLAYER.combat_data._target_entity:
		_panel_tl.visible = false
		return

	if _panel_tl.visible == false: _panel_tl.visible = true

	var target = GameManager.MY_PLAYER.combat_data._target_entity
	_label_target_level.text = str(target.level)

	var current_hp = target.combat_data.current_hp
	var max_hp = target.combat_data.get_total_hp()
	_target_rect_current_hp.size.x = _new_lerped_size(max_hp, current_hp, int(_RECT_TARGET_MAX_HP.size.x), _target_rect_current_hp.size.x, use_lerp)
	_label_target_current_hp.text = "%d/%d" % [current_hp, max_hp]

	var current_mana = target.combat_data.current_mana
	var max_mana = target.combat_data.get_total_mana()
	_target_rect_current_mana.size.x = _new_lerped_size(max_mana, current_mana, int(_RECT_TARGET_MAX_MANA.size.x), _target_rect_current_mana.size.x, use_lerp)
	_label_target_current_mana.text = "%d/%d" % [current_mana, max_mana]

func _new_lerped_size(max_value: int, current_value: int, full_size: int, current_size: int, use_lerp: bool = true) -> int:
	# Smooth interpolation (the 10.0 controls the speed, you can adjust it)
	var target_percent: float = clamp(current_value / float(max_value), 0.0, 1.0)
	var target_size := int(full_size * target_percent)

	if not use_lerp: return target_size
	return lerp(current_size, target_size, delta * 10.0)

func _update_panel_bottom_left() -> void:
	_hp_label.text = "%d/%d" % [GameManager.MY_PLAYER.combat_data.current_hp, GameManager.MY_PLAYER.combat_data.get_total_hp()]
	%LabelExp.text = "%d/%d" % [GameManager.MY_PLAYER.current_exp, Player.get_exp_per_level(GameManager.MY_PLAYER.level)]
	_update_hp_ball_sprite()
	_update_exp_bar()

	_hero_type.text = GameManager.MY_PLAYER.hero_type
	_hero_alias.text = GameManager.MY_PLAYER.json_data.alias
	_level.text = str(GameManager.MY_PLAYER.level)

	var total_stats = GameManager.MY_PLAYER.combat_data.get_total_stats()
	_stats1_lab1.text = str(total_stats.strength)
	_stats1_lab2.text = str(total_stats.agility)
	_stats1_lab3.text = str(total_stats.intelligence)
	_stats1_lab4.text = StringHelpers.format_float(total_stats.get_total_move_speed())
	_stats1_lab5.text = StringHelpers.format_float(total_stats.get_total_attack_speed())
	_stats1_lab6.text = StringHelpers.format_percent(total_stats.life_steal_percent)

	_stats2_lab1.text = StringHelpers.format_float(total_stats.physical_attack_power) + " / " + StringHelpers.format_float(total_stats.magic_attack_power)
	# _stats2_lab2.text = StringHelpers.format_float(total_stats.magic_attack_power)
	_stats2_lab3.text = StringHelpers.format_percent(total_stats.physical_defense_percent) + " / " + StringHelpers.format_percent(total_stats.magic_defense_percent)
	_stats2_lab4.text = StringHelpers.format_percent(total_stats.evasion)
	_stats2_lab5.text = StringHelpers.format_percent(total_stats.stun_chance)
	_stats2_lab6.text = StringHelpers.format_percent(total_stats.crit_chance) + " (*" + StringHelpers.format_float(total_stats.crit_multiplier) + ")"

func _update_panel_bottom_right() -> void:
	_mana_label.text = "%d/%d" % [GameManager.MY_PLAYER.combat_data.current_mana, GameManager.MY_PLAYER.combat_data.get_total_mana()]
	_update_mana_ball_sprite()

func _update_exp_bar() -> void:
	_current_exp_rect.size.x = _new_lerped_size(
		Player.get_exp_per_level(GameManager.MY_PLAYER.level),
		GameManager.MY_PLAYER.current_exp,
		EXP_BAR_FULL_SIZE.x,
		_current_exp_rect.size.x
	)
func _update_hp_ball_sprite():
	_update_ball_sprite(
		_hp_ball,
		GameManager.MY_PLAYER.combat_data.current_hp,
		GameManager.MY_PLAYER.combat_data.get_total_hp()
	)
func _update_mana_ball_sprite():
	_update_ball_sprite(
		_mana_ball,
		GameManager.MY_PLAYER.combat_data.current_mana,
		GameManager.MY_PLAYER.combat_data.get_total_mana()
	)
func _update_ball_sprite(ball_sprite: Sprite2D, current_value: int, max_value: int) -> void:
	var current_size = int(ball_sprite.region_rect.size.y)
	var visible_height: int = _new_lerped_size(max_value, current_value, int(_ORIGINAL_BALL_SIZE.y), current_size)
	var crop_from_top := _ORIGINAL_BALL_SIZE.y - visible_height

	ball_sprite.region_rect = Rect2(
		Vector2(ball_sprite.region_rect.position.x, _ORIGINAL_BALL_RECT_POS_Y + crop_from_top),
		Vector2(_ORIGINAL_BALL_SIZE.x, visible_height)
	)

	ball_sprite.position.y = _ORIGINAL_BALL_POS_Y + crop_from_top

func _update_auxiliary_labels(_delta: float) -> void:
	if not SHOW_DEBUG_DATA: return
	
	# var fps := int(1.0 / _delta)
	# if fps < 40: %LabelFPS.text = "FPS ⚠️: %d " % fps
	# else: %LabelFPS.text = "FPS: %d" % fps
	var mem_static_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	# var process_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var node_count = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var resource_count = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var vertices = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var video_mem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0)
	var tex_mem = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / (1024.0 * 1024.0)
	var buf_mem = Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / (1024.0 * 1024.0)

	var text := """
📊 Rendimiento:
🔹 Memoria (estática): %.2f MB
🔹 FPS: %.0f
🔹 Frame Time: %.4fs
🔹 Physics Time: %.4fs
🔹 Objetos: %d
🔹 Nodos: %d
🔹 Recursos: %d
🔹 Draw Calls: %d
🔹 Primitivas: %d
🔹 VRAM total: %.2f MB
🔹 Texturas VRAM: %.2f MB
🔹 Buffers VRAM: %.2f MB
""" % [
	mem_static_mb, fps, frame_time, physics_time,
	object_count, node_count, resource_count,
	draw_calls, vertices, video_mem, tex_mem, buf_mem
]

	%AuxiliaryLabel.text = text
# endregion INTERNAL AUXILIARY METHODS