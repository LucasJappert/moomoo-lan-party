class_name EntityState

enum StateEnum {IDLE, WALK}


static func _update(entity: Entity) -> void:
	_server_update(entity)

static func _server_update(entity: Entity):
	if not entity.multiplayer.is_server():
		return

	var is_moving := entity.velocity != Vector2.ZERO

	var new_state = StateEnum.WALK if is_moving else StateEnum.IDLE

	if new_state != entity.current_state:
		_server_set_current_state(entity, new_state)

static func _play_animation(entity: Entity) -> void:
	if not entity.sprite:
		return

	match entity.current_state:
		StateEnum.IDLE:
			entity.sprite.play("idle")
		StateEnum.WALK:
			entity.sprite.play("walk")

static func _server_set_current_state(entity: Entity, new_state: StateEnum) -> void:
	entity.current_state = new_state
	
	if MultiplayerManager.HOSTED_GAME:
		_play_animation(entity)

	# We notify the new state to all clients
	for peer_id in entity.multiplayer.get_peers():
		entity.rpc_id(peer_id, "rpc_set_state", entity.current_state)
