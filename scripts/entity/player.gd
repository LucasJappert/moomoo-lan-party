class_name Player

extends Entity

func _ready():
	super._ready()
	mov_speed = 200
	%InputSynchronizer.set_multiplayer_authority(id)
	if id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)


func _unhandled_input(event):
	print("_unhandled_input, id: " + name)
	if not multiplayer.is_server():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var from_cell = AStarGridManager.world_to_cell(target_pos if target_pos != null else global_position)
		var to_cell = AStarGridManager.world_to_cell(mouse_pos)

		current_path = AStarGridManager.find_path(from_cell, to_cell)
