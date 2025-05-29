class_name EntityState

enum StateEnum {IDLE, WALK}


static func _process(entity: Entity) -> void:
	_server_update(entity)

	_play_animation(entity)

static func _server_update(entity: Entity):
	if not entity.multiplayer.is_server(): return

	var is_moving := entity.velocity != Vector2.ZERO

	var new_state = StateEnum.WALK if is_moving else StateEnum.IDLE

	if new_state != entity.current_state:
		_server_set_current_state(entity, new_state)

static func _play_animation(entity: Entity) -> void:
	if entity is Moomoo: return
	if not entity.sprite: return

	match entity.current_state:
		StateEnum.IDLE:
			if entity.sprite.animation != "idle":
				print("entity.current_state: ", entity.current_state)
				entity.sprite.play("idle")
		StateEnum.WALK:
			if entity.sprite.animation != "walk":
				print("entity.current_state: ", entity.current_state)
				entity.sprite.play("walk")

static func _server_set_current_state(entity: Entity, new_state: StateEnum) -> void:
	entity.current_state = new_state
