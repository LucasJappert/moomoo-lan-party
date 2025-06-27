class_name EntityState

enum StateEnum {IDLE, WALK, ATTACK}
	
static func process(entity: Entity) -> void:
	_verify_state_and_animation(entity)

static func _server_set_current_state(entity: Entity, new_state: StateEnum) -> void:
	if not GameManager.AM_I_HOST: return
	entity.current_state = new_state

static func _is_playing_attack_animation(entity: Entity) -> bool:
	if entity.sprite.animation != "attack": return false
	return entity.sprite.is_playing()

static func _update_state(entity: Entity, state: StateEnum) -> void:
	if entity is Moomoo: return
	if not entity.sprite: return

	match state:
		StateEnum.IDLE:
			entity.sprite.play("idle")
		StateEnum.WALK:
			entity.sprite.play("walk")
		StateEnum.ATTACK:
			entity.sprite.play("attack")
	
	_server_set_current_state(entity, state)

static func _verify_state_and_animation(entity: Entity) -> void:
	if not entity: return
	if entity is Moomoo: return
	if not entity.sprite: return

	if entity.combat_data.is_stunned: # we must call it before the attack animation to cut it off when we are stunned
		return _update_state(entity, StateEnum.IDLE)

	if _is_playing_attack_animation(entity): return
	
	var is_moving: bool = entity.velocity != Vector2.ZERO
	if is_moving: return _update_state(entity, StateEnum.WALK)

	_update_state(entity, StateEnum.IDLE)

static func change_to_attack(entity: Entity) -> void:
	_update_state(entity, StateEnum.ATTACK)
