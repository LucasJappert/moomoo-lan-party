extends Node2D

@onready var player: Player = get_parent()

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var mouse_position = player.get_global_mouse_position()
			_on_right_click(mouse_position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = player.get_global_mouse_position()
			print("Client left_click_mouse_pos: ", mouse_position)

	# if event is InputEventMouseMotion:
	# 	var mouse_position = player.get_global_mouse_position()
	# 	MapManager.set_hovered_cell(MapManager.world_to_cell(mouse_position))


func _on_right_click(mouse_position: Vector2):
	if AreaHovered.hovered_entity is Enemy:
		rpc_id(1, "try_to_attack", AreaHovered.hovered_entity.name)
		return

	var _target_cell = MapManager.world_to_cell(mouse_position)
	rpc_id(1, "try_to_move", _target_cell)


@rpc("authority", "call_local")
func try_to_move(_target_cell: Vector2i):
	player._update_path(_target_cell)

@rpc("authority", "call_local")
func try_to_attack(_target_entity_name: String):
	var target_entity = GameManager.entities[_target_entity_name]
	print("Implementing try_to_attack: ", target_entity)
	Projectile.launch(player, target_entity, 50)
