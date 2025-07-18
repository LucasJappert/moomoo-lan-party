class_name EnemySpellCaster

var _enemy_owner: Entity
var cast_timer: float = 0.0
var next_cast_delay: float = 0.0
const MIN_DELAY = 1
const MAX_DELAY = 5

func _init(enemy: Entity):
	_enemy_owner = enemy
	randomize()
	_set_next_cast_delay()

func _process(delta):
	if not _enemy_owner: return
	if _enemy_owner._boss_level == 0: return
	if _enemy_owner.is_dead(): return
	if not _enemy_owner.can_attack: return

	cast_timer += delta
	if cast_timer < next_cast_delay: return

	_try_cast_random_skill()
	_set_next_cast_delay()
	cast_timer = 0.0

func _set_next_cast_delay() -> void:
	next_cast_delay = randf_range(MIN_DELAY, MAX_DELAY)

func _try_cast_random_skill() -> bool:
	if _enemy_owner.target_to_attack == null: return false

	var available_skills: Array[Skill] = _enemy_owner.get_skills().filter(func(skill):
		if skill.get_learned_skill() == null: return false
		if not skill.can_use(_enemy_owner): return false

		return true
	) as Array[Skill]

	if available_skills.size() == 0: return true

	var skill_to_cast: Skill = available_skills[randi() % available_skills.size()]

	if _try_cast_spell_to_an_ally(skill_to_cast): return true

	return _try_cast_spell_to_an_enemy(skill_to_cast)
	

func _try_cast_spell_to_an_enemy(skill_to_cast: Skill) -> bool:
	var learned_skill = skill_to_cast.get_safe_learned_skill()
	if not learned_skill.apply_to_enemy: return false

	return skill_to_cast.use(_enemy_owner, _enemy_owner.target_to_attack) # Apply to a player


func _try_cast_spell_to_an_ally(skill_to_cast: Skill) -> bool:
	if skill_to_cast.get_learned_skill().apply_to_enemy: return false

	if _try_cast_offensive_spell_to_an_ally(skill_to_cast): return true

	if _try_cast_defensive_spell_to_an_ally(skill_to_cast): return true

	return false

func _try_cast_offensive_spell_to_an_ally(skill_to_cast: Skill) -> bool:
	if skill_to_cast.get_learned_skill().stats.grants_attack_bonuses():
		if not _enemy_owner.effects_helper.get_effect_by_name(skill_to_cast.get_learned_skill().my_name):
			return skill_to_cast.use(_enemy_owner, _enemy_owner)

	return false

func _try_cast_defensive_spell_to_an_ally(skill_to_cast: Skill) -> bool:
	var near_allies = _enemy_owner.get_allies(true)
	var closest_allies := GlobalsEntityHelpers.get_closest_entities(_enemy_owner.global_position, near_allies, 6)
	if closest_allies.is_empty(): return false

	# Filtramos los que no recibieron daño hace mas de 5 segundos
	closest_allies = closest_allies.filter(func(ally): return ally.last_damage_received_time > 5.0)
	if closest_allies.is_empty(): return false

	# Ordena los aliados por el más reciente daño recibido (valor más alto)
	closest_allies.sort_custom(func(a, b):
		if a.last_damage_received_time != b.last_damage_received_time:
			return a.last_damage_received_time > b.last_damage_received_time

		return false
	)

	for ally in closest_allies:
		if ally.effects_helper.get_effect_by_name(skill_to_cast.get_learned_skill().my_name): continue
		return skill_to_cast.use(_enemy_owner, ally)

	return false
