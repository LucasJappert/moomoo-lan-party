class_name EntityState

const States = {
	IDLE = "idle",
	WALK = "walk",
	ATTACK = "attack",
}
	
static func server_process(entity: Entity) -> void:
	if not GameManager.AM_I_HOST: return
	_verify_state_and_animation(entity)

static func _server_set_current_state(entity: Entity, new_state: String) -> void:
	if not GameManager.AM_I_HOST: return
	entity.current_state = new_state

static func _is_playing_attack_animation(entity: Entity) -> bool:
	if entity.body_sprite.animation != "attack": return false
	return entity.body_sprite.is_playing()

static func _verify_state_and_animation(entity: Entity) -> void:
	if not entity: return
	if not entity.body_sprite: return

	if entity.is_stunned or entity.current_hp <= 0: # we must call it before the attack animation to cut it off when we are stunned
		return _update_state(entity, States.IDLE)

	if _is_playing_attack_animation(entity): return
	
	var is_moving: bool = entity.velocity != Vector2.ZERO
	if is_moving: return _update_state(entity, States.WALK)

	_update_state(entity, States.IDLE)

static func _update_state(entity: Entity, state: String) -> void:
	if not entity.body_sprite: return
	
	if entity.current_state == state: return

	entity.current_state = state

static func change_to_attack(entity: Entity) -> void:
	_update_state(entity, States.ATTACK)

static func server_and_client_on_state_changed(entity: Entity) -> void:
	if not entity.is_inside_tree(): return
	match entity.current_state:
		States.IDLE:
			entity.tween_effects.start_idle_effect()

	if entity.body_sprite.animation == entity.current_state and entity.body_sprite.is_playing(): return
	entity.body_sprite.play(entity.current_state)

static func paused_game(entity: Entity) -> void:
	if MainScene.PAUSED: entity.body_sprite.pause()
	else: entity.body_sprite.play()
