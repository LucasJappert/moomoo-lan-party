class_name AreaHovered
extends Area2D

static var hovered_entity: Entity
static var _currently_hovered_entities: Array[Entity] = []

var my_owner: Entity
const HOVERED_SHADER_NAME := "Hovered"

func _ready() -> void:
	my_owner = get_parent()

	if multiplayer.get_unique_id() != GameManager.MY_PLAYER_ID:
		set_process(false)
		return

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if Player.get_my_player() and not KeyboardController.SHIFT_PRESSED:
			if my_owner.is_my_player(): return
			if my_owner.is_enemy_of_player(): GameManager.MY_PLAYER.set_target_to_attack(my_owner)

func _process(_delta: float) -> void:
	if not is_instance_valid(hovered_entity):
		hovered_entity = null
	_update_hovered_entity()

func _on_mouse_entered() -> void:
	if not _currently_hovered_entities.has(my_owner):
		_currently_hovered_entities.append(my_owner)

func _on_mouse_exited() -> void:
	_currently_hovered_entities.erase(my_owner)
	if my_owner.is_enemy_of_player():
		ShadersHelper.clear_border_shader(my_owner, HOVERED_SHADER_NAME)

static func _update_hovered_entity() -> void:
	# SHIFT presionado => limpiar hover y avisar con new_entity=null
	if KeyboardController.SHIFT_PRESSED:
		if hovered_entity != null:
			var prev := hovered_entity
			if is_instance_valid(prev) and prev.is_enemy_of_player():
				ShadersHelper.clear_border_shader(prev, HOVERED_SHADER_NAME)
			hovered_entity = null
			EventBus.emit_hovered_entity_changed(null, prev)
		return

	# Limpiar inválidos (sin lambdas)
	var cleaned: Array[Entity] = []
	for e in _currently_hovered_entities:
		if is_instance_valid(e):
			cleaned.append(e)
	_currently_hovered_entities = cleaned

	# Si no hay ninguno, emitir cambio a null si antes había algo
	if _currently_hovered_entities.is_empty():
		if hovered_entity != null:
			var prev2 := hovered_entity
			if is_instance_valid(prev2) and prev2.is_enemy_of_player():
				ShadersHelper.clear_border_shader(prev2, HOVERED_SHADER_NAME)
			hovered_entity = null
			EventBus.emit_hovered_entity_changed(null, prev2)
		return

	# Elegir el de mayor Y (frontal)
	var best := _currently_hovered_entities[0]
	for e in _currently_hovered_entities:
		if e.global_position.y > best.global_position.y:
			if best.is_enemy_of_player():
				ShadersHelper.clear_border_shader(best, HOVERED_SHADER_NAME)
			best = e

	# Si no cambió, no emitir
	if best == hovered_entity:
		return

	# Cambió: limpiar previo, aplicar shader al nuevo (si es enemigo), y emitir
	var prev_hover := hovered_entity
	if prev_hover != null and is_instance_valid(prev_hover) and prev_hover.is_enemy_of_player():
		ShadersHelper.clear_border_shader(prev_hover, HOVERED_SHADER_NAME)

	if best.is_enemy_of_player():
		ShadersHelper.apply_border_shader(best, HOVERED_SHADER_NAME, false, Color(1, 0, 0, 1))

	hovered_entity = best
	EventBus.emit_hovered_entity_changed(best, prev_hover)
