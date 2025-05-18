extends Node2D

@onready var player: Player = get_parent()

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var right_click_mouse_pos = player.get_global_mouse_position()
		rpc_id(1, "receive_right_click_position", right_click_mouse_pos)
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var left_click_mouse_pos = player.get_global_mouse_position()
		print("Client left_click_mouse_pos: ", left_click_mouse_pos)
		rpc_id(1, "receive_left_click_position", left_click_mouse_pos)


@rpc("authority", "call_local")
func receive_right_click_position(_right_click_position: Vector2):
	player._update_path(_right_click_position)

@rpc("authority", "call_local")
func receive_left_click_position(_left_click_position: Vector2):
	var start_cell = AStarGridManager.world_to_cell(player.global_position)
	var target_cell = AStarGridManager.world_to_cell(_left_click_position)
	Projectile.launch(AStarGridManager.cell_to_world(start_cell), AStarGridManager.cell_to_world(target_cell))
