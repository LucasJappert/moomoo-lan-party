class_name Player

extends Entity

@export var player_id: int = 0

func set_player_id(value: int) -> void:
	player_id = value

func get_client_inputs(): return %ClientInputs


func _ready():
	super._ready()
	global_position = MapManager.cell_to_world(MapManager.PLAYER_CELL_SPAWN)
	mov_speed = 200
	combat_data.max_hp = 15000
	combat_data.current_hp = combat_data.max_hp
	combat_data.attack_type = AttackTypes.RANGED
	combat_data.attack_range = 500
	combat_data.attack_speed = 2.5
	combat_data.crit_chance = 0.5
	combat_data.projectile_type = ProjectileTypes.ARROW
	combat_data.skills.append(Skill.get_shielded_core())

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	if player_id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)
		MultiplayerManager.MY_PLAYER = self

func _update_path(_target_cell: Vector2i):
	var from_cell = MapManager.world_to_cell(target_pos if target_pos != null else global_position)
	current_path = MapManager.find_path(from_cell, _target_cell)
