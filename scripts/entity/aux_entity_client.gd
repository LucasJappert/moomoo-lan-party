class_name AuxEntityClient

static func _process(_entity: Entity, _delta: float) -> void:
	pass

static func _phisics_process(_entity: Entity, _delta: float) -> void:
	if _entity.multiplayer.is_server() && not MultiplayerManager.HOSTED_GAME:
		return

	_entity.sprite.flip_h = _entity.direction.x < 0

	pass