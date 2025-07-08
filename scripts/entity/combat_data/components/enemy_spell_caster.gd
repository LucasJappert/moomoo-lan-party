class_name EnemySpellCaster

var _enemy: Entity
var cast_timer: float = 0.0
var next_cast_delay: float = 0.0

func _init(enemy: Entity):
	_enemy = enemy
	randomize()
	_set_next_cast_delay()

func _process(delta):
	if not _enemy: return
	if _enemy._boss_level == 0: return
	if _enemy.is_dead(): return
	if not _enemy.can_attack: return

	cast_timer += delta
	if cast_timer < next_cast_delay: return

	_try_cast_random_skill()
	_set_next_cast_delay()
	cast_timer = 0.0

func _set_next_cast_delay() -> void:
	var factor = clamp(float(_enemy.level - 1) / EnemiesWavesController.TOTAL_WAVES, 0.0, 1.0) # Normalize level 1-30 to 0-1
	var min_delay = lerp(6.0, 2.0, factor)
	var max_delay = lerp(12.0, 5.0, factor)
	next_cast_delay = randf_range(min_delay, max_delay)

func _try_cast_random_skill() -> bool:
	if _enemy.target_to_attack == null: return false

	var available_skills: Array[Skill] = _enemy.get_skills().filter(func(skill):
		if skill.get_learned_skill() == null: return false
		if not skill.can_use(_enemy): return false

		return true
	)

	if available_skills.size() == 0: return true

	var skill_to_cast: Skill = available_skills[randi() % available_skills.size()]
	skill_to_cast.use(_enemy, _enemy.target_to_attack)

	return true
