class_name SkillBurningPresence

extends SkillBase

const NAME = "Burning Presence"
var _my_owner: Entity
var _current_effects: Array[GPUParticles2D] = []
var _current_cell: Vector2i = Vector2i.ZERO + Vector2i(999, 999)

var _damage_interval := 0.1 # segundos
var time_accumulator := _damage_interval # To start applying damage instantly
var _damage_residue := 0.0
var _total_damage: int = 0


static func create_and_add_instance(_SKILLS: Dictionary[String, Skill]) -> void:
	_SKILLS[NAME] = Skill.new(NAME, SkillType.ACTIVE)
	_SKILLS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 8, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)

	aux_array[0] = [10, 20, 40] # magic_damage_per_second
	aux_array[1] = [120, 200, 320] # mana cost
	aux_array[2] = [14, 10, 6] # cooldown
	aux_array[3] = [14, 20, 26] # duration
	for i in Skill.AVAILABLE_LEVELS:
		_SKILLS[NAME].item_skill_base[i].instant_use = false
		_SKILLS[NAME].item_skill_base[i].create_effect = true
		_SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		_SKILLS[NAME].item_skill_base[i].effect_radius_in_tiles = 3
		_SKILLS[NAME].item_skill_base[i].float_dict["magic_damage_per_second"] = aux_array[0][i]
		_SKILLS[NAME].item_skill_base[i].damage_type = DamageType.MAGIC
		_SKILLS[NAME].item_skill_base[i].mana_cost = aux_array[1][i]
		_SKILLS[NAME].item_skill_base[i].cooldown = aux_array[2][i]
		_SKILLS[NAME].item_skill_base[i].duration_in_seconds = aux_array[3][i]
		_SKILLS[NAME].item_skill_base[i].description = "Unleashes a blazing aura that ignites the ground around the owner, burning nearby enemies for " + StringHelpers.format_float(aux_array[0][i]) + " magic damage per second over " + str(aux_array[3][i]) + " seconds."

static func try_to_use(_caster: Entity, _learned_skill: ItemSkillBase, _target: Entity) -> bool:
	if _learned_skill.my_name != NAME: return true

	if not super.try_to_use(_caster, _learned_skill, _target): return false

	_target.add_active_skill(SkillBurningPresence.new(_caster, _learned_skill))

	return true

func _init(_owner: Entity, p_learned_skill: ItemSkillBase) -> void:
	super._init(p_learned_skill, true)
	_my_owner = _owner

var aux = 0
func process_skill(_owner: Entity, _delta: float) -> void:
	super.process_skill(_owner, _delta)

	if not active: return _try_to_remove_all_effects()
	if _owner.current_hp <= 0:
		active = false
		return _try_to_remove_all_effects()

	# Try to update the animation
	_try_update_effects_to_new_cell(_owner)

	# Try to apply damage
	time_accumulator += _delta
	while time_accumulator >= _damage_interval:
		time_accumulator -= _damage_interval
		aux += 1
		var _float_damage: float = learned_skill.float_dict["magic_damage_per_second"] * _damage_interval + _damage_residue
		var integer_damage := int(_float_damage)
		_damage_residue = _float_damage - integer_damage

		_total_damage += integer_damage
		_apply_damage_to_enemies(integer_damage)

func _apply_damage_to_enemies(damage: int) -> void:
	if ObjectHelpers.is_null(_my_owner): return
	var _di = DamageInfo.get_instance()
	_di.total_damage = damage
	_di.attacker_name = _my_owner.name
	_di.damage_type = learned_skill.damage_type

	var radius = learned_skill.effect_radius_in_tiles
	var targets = GlobalsEntityHelpers.get_closest_entities(_my_owner.global_position, _my_owner.get_my_enemies(), radius)
	for target in targets:
		target.server_receive_damage(_di, _my_owner)

func _remove_effects() -> void:
	_try_to_remove_all_effects()

func _try_update_effects_to_new_cell(_owner: Entity) -> void:
	if _owner.movement_helper.current_cell == _current_cell: return

	_current_cell = _owner.movement_helper.current_cell

	_try_to_remove_all_effects()

	var radius = learned_skill.effect_radius_in_tiles
	var neighbors_cells = MapManager.get_cells_in_radius(_current_cell, radius, false)
	for neighbor_cell in neighbors_cells:
		var fixed_position := MapManager.cell_to_world(neighbor_cell) + Vector2(MapManager.TILE_SIZE_FLOAT / 4, MapManager.TILE_SIZE_FLOAT / 4)
		var fire_effect = FireEffect.spawn_fire_effect(
			GameManager.game_world.over_terrain_layer,
			fixed_position,
			learned_skill.duration_in_seconds
		)
		_current_effects.append(fire_effect)

func _try_to_remove_all_effects() -> void:
	for effect in _current_effects:
		FireEffect.stop_effect(effect)
	_current_effects.clear()