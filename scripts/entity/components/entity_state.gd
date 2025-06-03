class_name EntityState

enum StateEnum {IDLE, WALK}


static func _process(entity: Entity) -> void:
	_server_update(entity)

	_play_animation(entity)

static func _server_update(entity: Entity) -> void:
	if not entity.multiplayer.is_server(): return
	
	if entity.combat_data.is_stunned(): return _server_set_current_state(entity, StateEnum.IDLE)

	var is_moving := entity.velocity != Vector2.ZERO

	var new_state = StateEnum.WALK if is_moving else StateEnum.IDLE

	_server_set_current_state(entity, new_state)

static func _play_animation(entity: Entity) -> void:
	if entity is Moomoo: return
	if not entity.sprite: return

	match entity.current_state:
		StateEnum.IDLE:
			if entity.sprite.animation != "idle":
				entity.sprite.play("idle")
		StateEnum.WALK:
			if entity.sprite.animation != "walk":
				entity.sprite.play("walk")

static func _server_set_current_state(entity: Entity, new_state: StateEnum) -> void:
	entity.current_state = new_state

static func try_to_change_state(entity: Entity, new_state: StateEnum) -> void:
	if entity.current_state != new_state:
		_server_set_current_state(entity, new_state)
