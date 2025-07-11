class_name EnemySpellCaster

var _enemy_owner: Entity
var cast_timer: float = 0.0
var next_cast_delay: float = 0.0
const MIN_DELAY = 3
const MAX_DELAY = 6

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
	var friendly_effect = skill_to_cast.get_safe_learned_skill()

	if friendly_effect.stats.is_owner_friendly: # Apply to an ally
		var near_allies = _enemy_owner.get_allies(true)
		var closest_allies := GlobalsEntityHelpers.get_closest_entities(_enemy_owner.global_position, 20, near_allies, 6, [])
		if closest_allies.is_empty(): return false

		closest_allies.shuffle()
		for ally in closest_allies:
			if ally.effects_helper.get_effect_by_name(friendly_effect.my_name): continue
			return skill_to_cast.use(_enemy_owner, ally)
	
	return skill_to_cast.use(_enemy_owner, _enemy_owner.target_to_attack) # Apply to a player
