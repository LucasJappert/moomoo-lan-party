class_name Player

extends Entity

@export var player_id: int = 0

func set_player_id(value: int) -> void:
	player_id = value

func get_client_inputs(): return %ClientInputs


func _ready():
	super._ready()
	global_position = MapManager.cell_to_world(MapManager.PLAYER_CELL_SPAWN)
	combat_data.max_hp = 5000
	combat_data.current_hp = combat_data.max_hp
	combat_data.attack_type = AttackTypes.RANGED
	combat_data.attack_range = 300
	combat_data.attack_speed = 200
	combat_data.crit_chance = 0.5
	combat_data.physical_attack_power = 20
	combat_data.projectile_type = Projectile.TYPES.ARROW
	combat_data.move_speed = 5
	combat_data.skills.append_array([
		Skill.get_shielded_core(),
		Skill.get_lifesteal(),
		# Skill.get_frozen_touch(),
		# Skill.get_stunning_strike()s
	])

	# We need to update the radius of the attack area node here as it enters the scene
	_set_area_attack_shape_radius()

	if player_id == multiplayer.get_unique_id():
		MyCamera.update_camera_position(global_position)
		Main.MY_PLAYER = self

func _update_path(_target_cell: Vector2i):
	var from_cell = MapManager.world_to_cell(target_pos if target_pos != null else global_position)
	current_path = MapManager.find_path(from_cell, _target_cell)
