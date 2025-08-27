class_name HUD

extends Node2D

var _last_damage_to_my_player: float = - INF
const MY_PROGRESS_BAR := preload("res://scenes/entity/my_progress_bar_scene.tscn")

# @onready var _health_bar: ProgressBar = $HealthBar
@onready var _label_container: PanelContainer = $PanelContainer
@onready var _label: Label = $PanelContainer/Label
const BAR_SIZE = 40.0
const HIDE_BARS_AFTER_MILLISECONDS = 3000

@onready var bars_container: VBoxContainer = $BarsContainer
@onready var _current_hp_bar: Panel = %CurrentHpBar
@onready var _current_mana_bar: Panel = %CurrentManaBar
@onready var damage_popup_container = $DamagePopupContainer
@onready var progress_bars_container: VBoxContainer = %ProgressBarsContainer

var my_owner: Entity
var _is_moomoo = false
const SHOW_DAMAGES_HEALS = true


func _post_ready(_entity: Entity):
	my_owner = _entity
	_is_moomoo = my_owner is Moomoo
	
	if my_owner.summoned_helper:
		add_lifetime_progress_bar(my_owner.summoned_helper.lifetime_sec)

	_label_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.text = ""

	var percent := 0.7
	var scale_diff := my_owner.body_sprite.scale.y - 1.0
	var diff_player = 24 if my_owner is Player else 0
	bars_container.position.y = bars_container.position.y - (my_owner.sprite_height * percent * scale_diff) - diff_player
	if my_owner is Moomoo:
		bars_container.position.y = bars_container.position.y - 40

	bars_container.visible = false
	_current_hp_bar.position = Vector2(1, 1)
	_current_mana_bar.position = Vector2(1, 1)
	if my_owner.is_ally_of_player():
		var base := _current_hp_bar.get_theme_stylebox("panel", "Panel")
		var sb := base.duplicate(true) as StyleBoxFlat # deep copy
		sb.bg_color = Color.from_string("#00ab36ff", Color.WHITE)
		# Si tu escena se instancia varias veces:
		sb.resource_local_to_scene = true
		_current_hp_bar.add_theme_stylebox_override("panel", sb)
		

func _process(_delta: float):
	_try_update_label()
	_try_update_bars_visibility()

func _try_update_bars_visibility():
	if my_owner.is_dead(): bars_container.visible = false; return
	if KeyboardController.ALT_PRESSED: bars_container.visible = true; return

	if my_owner.is_my_player(): bars_container.visible = true; return
	# var show_by_last_damage_to_my_player = Time.get_ticks_msec() - _last_damage_to_my_player < HIDE_BARS_AFTER_MILLISECONDS
	# if show_by_last_damage_to_my_player: bars_container.visible = true; return

	var show_by_last_damage_received = MainScene.get_elapsed_time_in_ms() - my_owner.last_damage_received_time_in_ms < HIDE_BARS_AFTER_MILLISECONDS
	if show_by_last_damage_received:
		bars_container.visible = true
		return

	bars_container.visible = false

func _try_update_label():
	# _label.text = str(my_owner.current_state)
	# _label.text = str(my_owner.effects_helper.get_effects().size())
	_label_container.visible = _label.text != ""
		 
	# _label.text = str(my_owner.is_enemy_of_player())

func update_health_bar():
	if not my_owner: return
	if my_owner.get_full_health() <= 0:
		_current_hp_bar.size.x = 0
		return
	_current_hp_bar.size.x = my_owner.current_hp * BAR_SIZE / my_owner.get_full_health()

func update_mana_bar():
	if not my_owner: return
	if my_owner.get_full_mana() <= 0:
		_current_mana_bar.size.x = 0
		return
		
	_current_mana_bar.size.x = (my_owner.current_mana * BAR_SIZE) / my_owner.get_full_mana()

func show_message_popup(text: String, color: Color = Color.RED, speed_scale: float = 1.0):
	if not SHOW_DAMAGES_HEALS: return
	show_popup(text, color, speed_scale)

func show_popup(text: String, color: Color = Color.RED, speed_scale: float = 1.0):
	var popup = DamagePopupPool.get_popup()
	if not popup: return
	
	damage_popup_container.add_child(popup, true)

	# Posición aleatoria leve (ruido)
	var _aux = int(MapManager.TILE_SIZE.x / 2)
	var offset := Vector2(0, randi_range(-_aux, _aux))
	popup.position = Vector2(0, -MapManager.TILE_SIZE.x * 2) + offset

	popup.show_damage(text, color, speed_scale)

func set_last_damage_to_my_player():
	_last_damage_to_my_player = Time.get_ticks_msec()

func add_stun_progress_bar(_lifetime_in_seconds: float) -> void:
	for child in progress_bars_container.get_children():
		if child is MyProgressBarScene:
			var current_bar := child as MyProgressBarScene
			if current_bar.my_name == CombatEffect.STUN_NAME:
				return current_bar.update_lifetime(_lifetime_in_seconds)

	var progress_bar: MyProgressBarScene = MY_PROGRESS_BAR.instantiate()
	progress_bar.init(CombatEffect.STUN_NAME, _lifetime_in_seconds, Color.from_string("#a38800ff", Color.WHITE))
	progress_bars_container.add_child(progress_bar)

func add_silence_progress_bar(_lifetime_in_seconds: float) -> void:
	for child in progress_bars_container.get_children():
		if child is MyProgressBarScene:
			var current_bar := child as MyProgressBarScene
			if current_bar.my_name == CombatEffect.SILENCE_NAME:
				return current_bar.update_lifetime(_lifetime_in_seconds)

	var progress_bar: MyProgressBarScene = MY_PROGRESS_BAR.instantiate()
	progress_bars_container.add_child(progress_bar)
	progress_bar.init(CombatEffect.SILENCE_NAME, _lifetime_in_seconds, Color.from_string("#82008efe", Color.WHITE))

func add_lifetime_progress_bar(_lifetime_in_seconds: float) -> void:
	const NAME := "LIFETIME"
	for child in progress_bars_container.get_children():
		if child is MyProgressBarScene:
			var current_bar := child as MyProgressBarScene
			if current_bar.my_name == NAME:
				return current_bar.update_lifetime(_lifetime_in_seconds)

	var progress_bar: MyProgressBarScene = MY_PROGRESS_BAR.instantiate()
	progress_bars_container.add_child(progress_bar)
	progress_bar.init(NAME, _lifetime_in_seconds, Color.from_string("#bababaff", Color.WHITE))