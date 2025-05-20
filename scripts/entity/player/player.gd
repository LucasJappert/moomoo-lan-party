class_name Player

extends Entity

@export var player_id: int = 0

func set_player_id(value: int) -> void:
	player_id = value

func get_client_inputs(): return %ClientInputs


func _ready():
	super._ready()
	global_position = MapManager.cell_to_world(Vector2i(0, 0))
	mov_speed = 200
	combat_data.max_hp = 5000
	combat_data.current_hp = combat_data.max_hp
	if player_id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)
		MultiplayerManager.MY_PLAYER = self

func _load_sprite():
	sprite.frames = load("res://assets/heros/hero1.tres")
	pass

func _update_path(_target_cell: Vector2i):
	var from_cell = MapManager.world_to_cell(target_pos if target_pos != null else global_position)
	current_path = MapManager.find_path(from_cell, _target_cell)
