class_name HUD

extends Node2D

var _last_damage_to_my_player: float = - INF

# @onready var _health_bar: ProgressBar = $HealthBar
@onready var _label_container: PanelContainer = $PanelContainer
@onready var _label: Label = $PanelContainer/Label
const BAR_SIZE = 40.0
const HIDE_BARS_AFTER_MILLISECONDS = 3000

@onready var bars_container: Node2D = $BarsContainer
@onready var _health_bg_black: Panel = $BarsContainer/MyHealthBar/BgBlack
@onready var _health_current_bar: Panel = $BarsContainer/MyHealthBar/CurrentBar
@onready var _mana_bg_black: Panel = $BarsContainer/MyManaBar/BgBlack
@onready var _mana_current_bar: Panel = $BarsContainer/MyManaBar/CurrentBar
@onready var damage_popup_container = $DamagePopupContainer

var my_owner: Entity
var _is_moomoo = false
const SHOW_DAMAGES_HEALS = true


func _post_ready(_entity: Entity):
	my_owner = _entity
	_is_moomoo = my_owner is Moomoo

	_label_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.text = my_owner.name

	var percent := 0.7
	var scale_diff := my_owner.sprite.scale.y - 1.0
	bars_container.position.y = bars_container.position.y - (my_owner.sprite_heigth * percent * scale_diff)

	bars_container.visible = false

	_health_bg_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_current_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mana_bg_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mana_current_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float):
	_try_update_label()
	_try_update_bars_visibility()

func _try_update_bars_visibility():
	if my_owner.is_my_player(): return
	
	if ClientInputs.ALT_PRESSED: bars_container.visible = true; return

	var show_by_last_damage_to_my_player = Time.get_ticks_msec() - _last_damage_to_my_player < HIDE_BARS_AFTER_MILLISECONDS
	if show_by_last_damage_to_my_player: bars_container.visible = true; return

	var show_by_last_damage_received = Time.get_ticks_msec() - my_owner.last_damage_received_time < HIDE_BARS_AFTER_MILLISECONDS
	if show_by_last_damage_received: bars_container.visible = true; return

	bars_container.visible = false

func _try_update_label():
	_label_container.visible = _label.text != ""
		
	_label.text = str(my_owner.current_state)
	# _label.text = str(GameManager.current_enemies_in_scene)

func update_health_bar():
	_health_current_bar.size.x = my_owner.current_hp * BAR_SIZE / my_owner.get_total_hp()

func update_mana_bar():
	_mana_current_bar.size.x = my_owner.current_mana * BAR_SIZE / my_owner.get_total_mana()

func show_damage_heal_popup(text: String, color: Color = Color.RED):
	if not SHOW_DAMAGES_HEALS: return
	show_popup(text, color)

func show_popup(text: String, color: Color = Color.RED):
	var popup = DamagePopupPool.get_popup()
	if not popup: return
	
	damage_popup_container.add_child(popup, true)

	# Posición aleatoria leve (ruido)
	var _aux = int(MapManager.TILE_SIZE.x / 2)
	var offset := Vector2(0, randi_range(-_aux, _aux))
	popup.position = Vector2(0, -MapManager.TILE_SIZE.x * 2) + offset

	popup.show_damage(text, color)

func set_last_damage_to_my_player():
	_last_damage_to_my_player = Time.get_ticks_msec()