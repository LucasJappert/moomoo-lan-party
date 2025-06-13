class_name HUD

extends Node

# @onready var _health_bar: ProgressBar = $HealthBar
@onready var _label_container: PanelContainer = $PanelContainer
@onready var _label: Label = $PanelContainer/Label
@onready var my_health_bar: Node2D = $MyHealthBar
const BAR_SIZE = 40.0
@onready var bg_black: Panel = $MyHealthBar/BgBlack
@onready var current_bar: Panel = $MyHealthBar/CurrentBar
@onready var damage_popup_container = $DamagePopupContainer
var my_owner: Entity
var _is_moomoo = false
const SHOW_DAMAGES_HEALS = true


func _post_ready(_entity: Entity):
	my_owner = _entity
	_is_moomoo = my_owner is Moomoo

	_label_container.visible = false
	_label_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.text = my_owner.name

	my_health_bar.position.y = my_owner.sprite.position.y - my_owner.sprite_heigth * 0.5
	if my_owner is Enemy: my_health_bar.position.y -= 10
	if my_owner is Player && my_owner.player_id == GameManager.MY_PLAYER_ID: my_health_bar.visible = false

	bg_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	current_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float):
	_try_update_label()
	_try_update_health_bar()

func _try_update_health_bar():
	if my_owner is Player && my_owner.player_id == GameManager.MY_PLAYER_ID: return
	
	if my_owner.combat_data.latest_attacker == null:
		if my_health_bar.visible: my_health_bar.visible = false
		return

	if not my_health_bar.visible: my_health_bar.visible = true

	current_bar.size.x = my_owner.combat_data.current_hp * BAR_SIZE / my_owner.combat_data.get_total_hp()

func _try_update_label():
	if not _label_container.visible: return
		
	_label.text = my_owner.combat_data.target_entity_name
	_label.text = str(my_owner.combat_data.get_effects().size())
	pass

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
