class_name AreaHovered

extends Area2D

static var hovered_entity: Entity
static var _currently_hovered_entities: Array[Entity] = []
var my_owner: Entity
const HOVERED_SHADER_NAME: String = "Hovered"

func _ready() -> void:
	my_owner = get_parent()

	if multiplayer.get_unique_id() != GameManager.MY_PLAYER_ID:
		return set_process(false)

	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())
	connect("input_event", func(_view, event, _shape_idx): _on_input_event(_view, event, _shape_idx))

func _on_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		# var hovered_control = get_viewport().get_window().gui_get_hovered_control()
		# print("Hovered control: ", hovered_control) # ⚠️ Puede ser null
		if _event.button_index == MOUSE_BUTTON_RIGHT:
			if GameManager.MY_PLAYER and not KeyboardController.SHIFT_PRESSED:
				if my_owner.is_my_player(): return
				if my_owner.is_enemy_of_player(): GameManager.MY_PLAYER.set_target_to_attack(my_owner)
				GameManager.MY_PLAYER.movement_helper.set_target_entity(my_owner, MovementHelper.AttackMoveType.PhysicalAttack)

func _process(_delta: float) -> void:
	if not is_instance_valid(hovered_entity):
		hovered_entity = null

	_update_hovered_entity()

func _on_mouse_entered():
	if not _currently_hovered_entities.has(my_owner):
		_currently_hovered_entities.append(my_owner)

func _on_mouse_exited():
	_currently_hovered_entities.erase(my_owner)
	if my_owner.is_enemy_of_player():
		ShadersHelper.clear_border_shader(my_owner, HOVERED_SHADER_NAME)

static func _update_hovered_entity():
	if KeyboardController.SHIFT_PRESSED:
		if not ObjectHelpers.is_null(hovered_entity):
			ShadersHelper.clear_border_shader(hovered_entity, HOVERED_SHADER_NAME)
			hovered_entity = null
		return

	# Clean up invalid entities first
	_currently_hovered_entities = _currently_hovered_entities.filter(func(e): return is_instance_valid(e))

	if _currently_hovered_entities.is_empty():
		hovered_entity = null
		return

	var best_entity := _currently_hovered_entities[0]
	for e in _currently_hovered_entities:
		if e.global_position.y > best_entity.global_position.y:
			if best_entity.is_enemy_of_player():
				ShadersHelper.clear_border_shader(best_entity, HOVERED_SHADER_NAME)
			best_entity = e

	if best_entity.is_enemy_of_player():
		ShadersHelper.apply_border_shader(best_entity, HOVERED_SHADER_NAME, false, Color(1, 0, 0, 1))
	hovered_entity = best_entity
