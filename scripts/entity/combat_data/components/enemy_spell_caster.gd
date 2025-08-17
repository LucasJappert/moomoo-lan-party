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
	# if _enemy_owner._boss_level == 0: return
	if _enemy_owner.is_dead(): return
	if not _enemy_owner.can_attack: return
	if _enemy_owner.is_spawning: return

	cast_timer += delta
	if cast_timer < next_cast_delay: return

	if not _try_cast_random_skill(): return

	# If a spell was cast successfully, reset the timer
	_set_next_cast_delay()
	cast_timer = 0.0

func _set_next_cast_delay() -> void:
	next_cast_delay = randf_range(MIN_DELAY, MAX_DELAY)

func _try_cast_random_skill() -> bool:
	if _enemy_owner.target_to_attack == null: return false

	var available_skills: Array[Skill] = _enemy_owner.get_skills().filter(func(skill):
		if not skill: return false
		if skill.get_learned_skill() == null: return false
		if not skill.can_use(_enemy_owner): return false

		return true
	) as Array[Skill]

	if available_skills.size() == 0: return false

	var skill_to_cast: Skill = available_skills[randi() % available_skills.size()]
	var learned_skill = skill_to_cast.get_learned_skill()

	if learned_skill.instant_use:
		for reg_skill in SkillBase.REGISTERED_SKILLS:
			if reg_skill.try_use_skill_efficiently(_enemy_owner, _enemy_owner.target_to_attack, skill_to_cast): return true
		return false

	if _try_cast_spell_to_an_ally(skill_to_cast): return true

	return _try_cast_spell_to_an_enemy(skill_to_cast)
	

func _try_cast_spell_to_an_enemy(skill_to_cast: Skill) -> bool:
	var learned_skill = skill_to_cast.get_safe_learned_skill()
	if not learned_skill.target_to_enemy: return false

	return skill_to_cast.use(_enemy_owner, _enemy_owner.target_to_attack) # Apply to a player


func _try_cast_spell_to_an_ally(skill_to_cast: Skill) -> bool:
	if skill_to_cast.get_learned_skill().target_to_enemy: return false

	if _try_cast_offensive_bonus_to_an_ally(skill_to_cast): return true

	if _try_cast_defensive_bonus_to_an_ally(skill_to_cast): return true

	return false

func _try_cast_offensive_bonus_to_an_ally(skill_to_cast: Skill) -> bool:
	if skill_to_cast.get_learned_skill().grants_attack_bonuses():
		if not _enemy_owner.effects_helper.get_effect_by_name(skill_to_cast.get_learned_skill().my_name):
			return skill_to_cast.use(_enemy_owner, _enemy_owner)

	return false

func _try_cast_defensive_bonus_to_an_ally(skill_to_cast: Skill) -> bool:
	var near_allies = _enemy_owner.get_allies(true)
	var closest_allies := GlobalsEntityHelpers.get_closest_entities(_enemy_owner.global_position, near_allies, 6)
	if closest_allies.is_empty(): return false

	# Filtramos los que no recibieron daño hace mas de 5 segundos
	closest_allies = closest_allies.filter(func(ally: Entity): return ally.last_damage_received_time_in_ms > 5.0)
	if closest_allies.is_empty(): return false

	# Ordena los aliados por el más reciente daño recibido (valor más alto)
	closest_allies.sort_custom(func(a: Entity, b: Entity):
		if a.last_damage_received_time_in_ms != b.last_damage_received_time_in_ms:
			return a.last_damage_received_time_in_ms > b.last_damage_received_time_in_ms

		return false
	)

	for ally in closest_allies:
		if ally.effects_helper.get_effect_by_name(skill_to_cast.get_learned_skill().my_name): continue
		return skill_to_cast.use(_enemy_owner, ally)

	return false
