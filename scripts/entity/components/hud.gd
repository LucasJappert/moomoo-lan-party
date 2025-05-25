extends Node

# @onready var _health_bar: ProgressBar = $HealthBar
@onready var _label: Label = $Label
@onready var my_health_bar = $MyHealthBar
const BAR_SIZE = 40.0
@onready var current_bar = $MyHealthBar/CurrentBar
@onready var damage_popup_container = $DamagePopupContainer
var my_owner: Entity
var _is_moomoo = false
const SHOW_DAMAGES = false


func _post_ready(_entity: Entity):
	my_owner = _entity
	_is_moomoo = my_owner is Moomoo

	var lb_style = StyleBoxFlat.new()
	lb_style.bg_color = Color(0, 0, 0, 0.2)
	_label.add_theme_stylebox_override("normal", lb_style)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.visible = my_owner is Player
	_label.text = my_owner.name

func _process(_delta: float):
	_try_update_label()
	_try_update_health_bar()

func _try_update_health_bar():
	# Hide health bar if we don't receive damage for 5 seconds
	var now = Time.get_ticks_msec()
	if now - my_owner.combat_data.last_damage_received_time > 5000:
		if my_health_bar.visible: my_health_bar.visible = false
		return

	if not my_health_bar.visible: my_health_bar.visible = true

	current_bar.size.x = my_owner.combat_data.current_hp * BAR_SIZE / my_owner.combat_data.max_hp

func _try_update_label():
	if not _label.visible:
		return
		
	_label.text = my_owner.name
	# _label.text += " - " + str(MapManager.world_to_cell(my_owner.global_position))
	pass

func show_damage_popup(amount: int, color: Color = Color.RED):
	if not SHOW_DAMAGES: return
	
	var popup = DamagePopupPool.get_popup()
	damage_popup_container.add_child(popup)

	# Posición aleatoria leve (ruido)
	var _aux = int(MapManager.TILE_SIZE.x / 2)
	var offset := Vector2(0, randi_range(-_aux, _aux))
	popup.position = Vector2(0, -MapManager.TILE_SIZE.x * 2) + offset

	if amount < 0: color = Color.RED
	if amount > 0: color = Color.GREEN
	popup.show_damage(amount, color)
