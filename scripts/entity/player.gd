class_name Player

extends Entity

@export var player_id: int = 0

func set_player_id(value: int) -> void:
	player_id = value
	name = str(player_id)

func get_input_synchronizer(): return %InputSynchronizer

func _ready():
	super._ready()
	global_position = AStarGridManager.cell_to_world(Vector2i(0, 0))
	mov_speed = 200
	if player_id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)
		MultiplayerManager.MY_PLAYER = self

func _load_sprite():
	sprite.frames = load("res://assets/heros/hero1.tres")
	pass

func _update_path(_click_position: Vector2):
	var from_cell = AStarGridManager.world_to_cell(target_pos if target_pos != null else global_position)
	var to_cell = AStarGridManager.world_to_cell(_click_position)
	current_path = AStarGridManager.find_path(from_cell, to_cell)
