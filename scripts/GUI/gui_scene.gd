class_name GUIScene

extends CanvasLayer

static var SHOW_DEBUG_DATA = false

var _ORIGINAL_BALL_SIZE: Vector2
var _ORIGINAL_BALL_POS_Y: float
var _ORIGINAL_BALL_RECT_POS_Y: float
var reseted_gui := false
@onready var text_ip = %TextIP
@onready var countdown_scene: CountdownScene = %CountdownScene

var _top_left_target: Entity
var _bottom_target: Entity
@onready var in_game_statistics: InGameStatistics = %InGameStatisticsScene

# region Panel TOP LEFT
const _RECT_TARGET_MAX_HP = Rect2(81, 27, 189, 21)
const _RECT_TARGET_MAX_MANA = Rect2(80, 51, 183, 15)
const EXP_BAR_FULL_SIZE = Vector2i(612, 27)
@onready var _sprite_target_avatar = $PanelTL/TargetAvatar
@onready var _panel_tl = $PanelTL
@onready var _target_rect_current_hp = $PanelTL/TargetRectCurrentHP
@onready var _target_rect_current_mana = $PanelTL/TargetRectCurrentMana
@onready var _label_target_level = $PanelTL/TargetLevel
@onready var _label_target_current_hp = $PanelTL/TargetCurrentHp
@onready var _label_target_current_mana = $PanelTL/TargetCurrentMana
@onready var target_effects = $PanelTL/TargetEffects
# endregion

# region Panel BOTTOM LEFT
static var GREEN_BALL_COLOR := Color.from_string("#00da45ff", Color.WHITE)
static var RED_BALL_COLOR := Color.from_string("#cd0000ff", Color.WHITE)
@onready var my_effects: GuiEffects = $PanelBL/MyEffects
@onready var _label_exp = $PanelBL/LabelExp
@onready var _my_player_avatar = $PanelBL/MyPlayerAvatar
@onready var _hp_ball = %HpBall
@onready var _hp_label = $PanelBL/LabelHP
@onready var _current_exp_rect = $PanelBL/CurrentExpRect
@onready var _level = $PanelBL/Level
@onready var _str_value = $PanelBL/StatsContainer/Panel2/VBoxContainer2/StrValue
@onready var _agi_value = $PanelBL/StatsContainer/Panel2/VBoxContainer2/AgiValue
@onready var _int_value = $PanelBL/StatsContainer/Panel2/VBoxContainer2/IntValue
@onready var _move_speed_value = $PanelBL/StatsContainer/Panel2/VBoxContainer2/MoveSpeedValue
@onready var _attack_speed_value = $PanelBL/StatsContainer/Panel2/VBoxContainer2/AttackSpeedValue

@onready var _damage_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/DamageValue
@onready var _magic_power_multiplier_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/MagicPowerMultiplierValue
@onready var _defense_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/DefenseValue
@onready var _evasion_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/EvasionValue
@onready var _stun_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/StunValue
@onready var _critic_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/CriticValue
@onready var _lifesteal_value = $PanelBL/StatsContainer/Panel1/VBoxContainer2/LifeStealValue
@onready var _hero_type = $PanelBL/HeroType
@onready var _hero_alias = $PanelBL/HeroAlias
# endregion

# region Panel BOTTOM RIGHT
@onready var shop_interface: ShopInterface = %ShopInterface
@onready var tutorial_button = %TutorialButton
@onready var _mana_ball = $PanelBR/ManaBall
@onready var _mana_label = $PanelBR/LabelMana
@onready var _skill_slots_container = $PanelBR/SkillSlotsContainer
@onready var _item_slots_container: ItemSlotsContainer = $PanelBR/ItemSlotsContainer
@onready var _current_gold = $PanelBR/CurrentGold
# endregion

var delta: float

func _ready() -> void:
	GUIStatsHelper._ready(self)
	text_ip.text = "127.0.0.1"
	# tailscale IP = 100.99.208.97
	if multiplayer.is_server() && not GameWorld.HOSTED_GAME: return

	%JoinAsPlayerButton.connect("pressed", _on_join_as_player_pressed)
	tutorial_button.hide_mouse_message_label()
	# _hp_ball.modulate = Color.from_string("#00832a", Color.WHITE)
	_ORIGINAL_BALL_SIZE = _hp_ball.region_rect.size
	_ORIGINAL_BALL_POS_Y = _hp_ball.position.y
	_ORIGINAL_BALL_RECT_POS_Y = _hp_ball.region_rect.position.y

	_current_exp_rect.size.y = EXP_BAR_FULL_SIZE.y
	_current_gold.text = ""
	
	_panel_tl.visible = false

	%HpBallCircle.connect("mouse_entered", func():
		if not _bottom_target: return
		var regen_points = _bottom_target.cache_total_stats.get_hp_regeneration_points()
		MyTooltip.show_tooltip("HP regen", str(regen_points) + " points per second", 7)
	)
	%HpBallCircle.connect("mouse_exited", func(): MyTooltip.hide_tooltip())

	%ManaBallCircle.connect("mouse_entered", func():
		if not _bottom_target: return
		var regen_points = _bottom_target.cache_total_stats.get_mana_regeneration_points()
		MyTooltip.show_tooltip("Mana regen", str(regen_points) + " points per second", 7)
	)
	%ManaBallCircle.connect("mouse_exited", func(): MyTooltip.hide_tooltip())
	
	EventBus.connect_to_new_target_view_selected(func(_owner: Entity, _viewed_target: Entity): _on_new_target_view_selected(_owner, _viewed_target))

	
func _on_join_as_player_pressed() -> void:
	MultiplayerManager.become_client()


func reset_gui() -> void:
	_hp_label.text = str(0)
	_mana_label.text = str(0)
	reseted_gui = true

func _process(_delta: float) -> void:
	# TODO: we should instance the gui when the game starts (and we can access the player)
	delta = _delta
	if not _bottom_target:
		if not reseted_gui: reset_gui()
		return
	if reseted_gui: reseted_gui = false

	# _update_panel_top_left()
	_update_panel_bottom_left() # 3388 a 3427
	_update_panel_bottom_right() # 3427 a 3453
	_update_auxiliary_labels(_delta)


# region	SETTERS
func _on_shop_button_pressed() -> void:
	print("Shop button pressed")
func init_scene(entity: Entity) -> void:
	_bottom_target = entity
	if entity is Enemy: _hp_ball.modulate = RED_BALL_COLOR
	else: _hp_ball.modulate = GREEN_BALL_COLOR
	_set_my_player_avatar_region(entity)
	_set_skills()
	_set_items()

func _set_skills() -> void:
	var _slots := get_skill_slots()
	for i in range(_slots.size()):
		var _skill: Skill = _bottom_target._skills[i] if i < _bottom_target._skills.size() else null
		_slots[i]._skill_updated(_skill, _bottom_target, i + 1)

func _set_items() -> void:
	var _slots := get_item_slots()

	for i in range(SlotItem.HOTKEY_BY_SLOT.size()):
		_slots[i].slot_number = i + 1
		_slots[i].item_updated(_bottom_target._items[i])

func _set_my_player_avatar_region(_entity: Entity) -> void:
	if _entity is Moomoo: return # TODO: fix
	_my_player_avatar.region_rect = _entity.extra_info.rects[0]

func set_target_avatar_region(region_rect: Rect2) -> void:
	_sprite_target_avatar.region_rect = region_rect

func _on_new_target_view_selected(_owner: Entity, _viewed_target: Entity) -> void:
	_bottom_target = _viewed_target
	if not _bottom_target: _bottom_target = GameManager.MY_PLAYER
	init_scene(_bottom_target)

	# Actions for the top left panel. TODO: refactor
	if not ObjectHelpers.is_my_player(_owner): return
	_top_left_target = _viewed_target
	# _update_panel_top_left(false)
	if not _viewed_target: return
	var region_rect = SpritesHelper.get_region_rect_of_sprite(_viewed_target.body_sprite)
	set_target_avatar_region(region_rect)
# endregion SETTERS

# region	GETTERs
func get_skill_slots() -> Array[SkillSlot]:
	var result: Array[SkillSlot] = []

	for child in _skill_slots_container.get_children():
		if child is SkillSlot:
			result.append(child as SkillSlot)

	return result
func get_item_slots() -> Array[SlotItem]:
	var result: Array[SlotItem] = []

	for child in _item_slots_container.get_children():
		if child is SlotItem:
			result.append(child as SlotItem)

	return result
func get_items() -> Array[SlotItem]:
	return _item_slots_container.get_children() as Array[SlotItem]
# endregion GETTERs


# region 	INTERNAL AUXILIARY METHODS

func _update_panel_top_left(use_lerp: bool = true) -> void:
	if not _top_left_target:
		_panel_tl.visible = false
		return

	if _panel_tl.visible == false: _panel_tl.visible = true

	_label_target_level.text = str(_top_left_target.level)

	var current_hp = _top_left_target.current_hp
	var max_hp = _top_left_target.get_full_health()
	_target_rect_current_hp.size.x = _new_lerped_size(max_hp, current_hp, int(_RECT_TARGET_MAX_HP.size.x), _target_rect_current_hp.size.x, use_lerp)
	_label_target_current_hp.text = "%s / %s" % [StringHelpers.format_float_compact(current_hp), StringHelpers.format_float_compact(max_hp)]

	var current_mana = _top_left_target.current_mana
	var max_mana = _top_left_target.get_full_mana()
	_target_rect_current_mana.size.x = _new_lerped_size(max_mana, current_mana, int(_RECT_TARGET_MAX_MANA.size.x), _target_rect_current_mana.size.x, use_lerp)
	_label_target_current_mana.text = "%s / %s" % [StringHelpers.format_float_compact(current_mana), StringHelpers.format_float_compact(max_mana)]

func _new_lerped_size(max_value: int, current_value: int, full_size: int, current_size: int, use_lerp: bool = true) -> int:
	# Smooth interpolation (the 10.0 controls the speed, you can adjust it)
	var target_percent: float = clamp(current_value / float(max_value), 0.0, 1.0)
	var target_size := int(full_size * target_percent)
	if target_percent == 1.0:
		target_size = full_size
		return target_size

	if not use_lerp: return target_size
	return lerp(current_size, target_size, delta * 10.0)

func _update_panel_bottom_left() -> void:
	if not GameManager.MY_PLAYER: return
	var current_hp = StringHelpers.format_float_compact(_bottom_target.current_hp)
	var max_hp = StringHelpers.format_float_compact(_bottom_target.get_full_health())
	_hp_label.text = "%s / %s" % [current_hp, max_hp]

	var current_exp = StringHelpers.format_float_compact(GameManager.MY_PLAYER.current_exp)
	var max_exp = StringHelpers.format_float_compact(Player.get_exp_per_level(GameManager.MY_PLAYER.level))
	_label_exp.text = "%s / %s" % [current_exp, max_exp]

	_update_hp_ball_sprite()
	_update_exp_bar()

	_hero_type.text = _bottom_target.extra_info.key_type
	_hero_alias.text = _bottom_target.extra_info.alias
	_level.text = str(_bottom_target.level)

	var total_stats = _bottom_target.cache_total_stats
	_str_value.text = StringHelpers.format_float_compact(total_stats.get_strength())
	_agi_value.text = StringHelpers.format_float_compact(total_stats.get_agility())
	_int_value.text = StringHelpers.format_float_compact(total_stats.get_intelligence())
	_move_speed_value.text = StringHelpers.format_float_compact(total_stats.get_total_move_speed())
	_attack_speed_value.text = StringHelpers.format_float_compact(total_stats.get_total_attack_speed())
	_lifesteal_value.text = StringHelpers.format_percent(total_stats.get_life_steal_percent())

	_damage_value.text = StringHelpers.format_float_compact(total_stats.get_physical_attack_power())
	_magic_power_multiplier_value.text = "+" + StringHelpers.format_percent(total_stats.get_magic_power_multiplier() - 1)
	_defense_value.text = StringHelpers.format_percent(total_stats.get_physical_defense_percent(), false) + "-" + StringHelpers.format_percent(total_stats.get_magic_defense_percent(), false) + " %"
	_evasion_value.text = StringHelpers.format_percent(total_stats.get_evasion())
	_stun_value.text = StringHelpers.format_percent(total_stats.get_stun_chance())
	_critic_value.text = total_stats.get_critic_description()

func _update_panel_bottom_right() -> void:
	if _bottom_target is Player: _current_gold.text = _bottom_target.current_gold_string
	var current_mana = StringHelpers.format_float_compact(_bottom_target.current_mana)
	var max_mana = StringHelpers.format_float_compact(_bottom_target.get_full_mana())
	_mana_label.text = "%s / %s" % [current_mana, max_mana]
	_update_mana_ball_sprite()

func _update_exp_bar() -> void:
	_current_exp_rect.visible = _bottom_target is Player # TODO: Update visibility on new target change
	_current_exp_rect.size.x = _new_lerped_size(
		Player.get_exp_per_level(GameManager.MY_PLAYER.level),
		GameManager.MY_PLAYER.current_exp,
		EXP_BAR_FULL_SIZE.x,
		_current_exp_rect.size.x
	)
func _update_hp_ball_sprite():
	_update_ball_sprite(
		_hp_ball,
		_bottom_target.current_hp,
		_bottom_target.get_full_health()
	)
func _update_mana_ball_sprite():
	_update_ball_sprite(
		_mana_ball,
		_bottom_target.current_mana,
		_bottom_target.get_full_mana()
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
	# %LabelFPS.text = "FPS: %d" % Performance.get_monitor(Performance.TIME_FPS)
	if not SHOW_DEBUG_DATA:
		if %AuxiliaryLabel.visible: %AuxiliaryLabel.hide()
		return

	if not %AuxiliaryLabel.visible: %AuxiliaryLabel.show()
	
	var mem_static_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)
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
	📊 Debug info:
	🔹 My position: %s
	🔹 Memory (static): %.2f MB
	🔹 Frame Time: %.4fs
	🔹 Physics Time: %.4fs
	🔹 Objects: %d
	🔹 Nodes: %d
	🔹 Resources: %d
	🔹 Draw Calls: %d
	🔹 Primitives: %d
	🔹 Total VRAM: %.2f MB
	🔹 Textures VRAM: %.2f MB
	🔹 Buffers VRAM: %.2f MB
	""" % [
		MapManager.world_to_cell(GameManager.MY_PLAYER.global_position),
		mem_static_mb, frame_time, physics_time,
		object_count, node_count, resource_count,
		draw_calls, vertices, video_mem, tex_mem, buf_mem
	]


	%AuxiliaryLabel.text = text
# endregion INTERNAL AUXILIARY METHODS