class_name Player

extends Entity

var right_click_mouse_pos = null
@export var player_id: int = 0

func set_player_id(value: int) -> void:
	player_id = value
	name = str(player_id)

func _ready():
	super._ready()
	mov_speed = 200
	if player_id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)

func _server_verify_right_click_mouse_pos(_delta: float):
	if right_click_mouse_pos != %InputSynchronizer.right_click_mouse_pos:
		right_click_mouse_pos = %InputSynchronizer.right_click_mouse_pos
		var from_cell = AStarGridManager.world_to_cell(target_pos if target_pos != null else global_position)
		var to_cell = AStarGridManager.world_to_cell(right_click_mouse_pos)
		current_path = AStarGridManager.find_path(from_cell, to_cell)
