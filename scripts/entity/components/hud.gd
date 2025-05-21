extends Node

# @onready var _health_bar: ProgressBar = $HealthBar
@onready var _label: Label = $Label
@onready var my_health_bar = $MyHealthBar
const BAR_SIZE = 60.0
@onready var current_bar = $MyHealthBar/CurrentBar
var my_owner: Entity
var _is_moomoo = false

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
	if not my_health_bar.visible:
		return

	current_bar.size.x = my_owner.combat_data.current_hp * BAR_SIZE / my_owner.combat_data.max_hp

func _try_update_label():
	if not _label.visible:
		return
		
	_label.text = my_owner.name
	# _label.text += " - " + str(MapManager.world_to_cell(my_owner.global_position))
	pass
