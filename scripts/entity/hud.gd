extends Node

@onready var _health_bar: ProgressBar = $HealthBar
@onready var _label: Label = $Label
var my_owner: Entity
var _is_moomoo = false

func initialize_on_ready(_entity: Entity):
	my_owner = _entity
	_is_moomoo = my_owner is Moomoo
	if _health_bar:
		_health_bar.size = Vector2(50, 5)
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Color(0, 0, 0) # black background
		_health_bar.add_theme_stylebox_override("background", bg_style)
		
		var fg_style = StyleBoxFlat.new()
		fg_style.bg_color = Color(0, 0.6, 0) # green foreground
		_health_bar.add_theme_stylebox_override("fill", fg_style)

		# _health_bar.value = randi() % 81 + 20
		_health_bar.position.x = - _health_bar.size.x / 2
		_health_bar.position.y = -80 if _is_moomoo else -60
	

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
	if not _health_bar.visible:
		return

	_health_bar.max_value = my_owner.combat_data.max_hp
	_health_bar.value = my_owner.combat_data.current_hp

func _try_update_label():
	if not _label.visible:
		return
		
	_label.text = my_owner.name
	pass

func increment_health_bar(value: int):
	_health_bar.value += value
	_health_bar.value = max(_health_bar.value, 0)
	
	if _health_bar.value <= 0:
		my_owner.die()
