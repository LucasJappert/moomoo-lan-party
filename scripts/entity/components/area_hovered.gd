class_name AreaHovered

extends Area2D

static var hovered_entity: Entity
static var _currently_hovered_entities: Array[Entity] = []
var my_owner: Entity

func _ready() -> void:
	my_owner = get_parent()

	if multiplayer.get_unique_id() != MultiplayerManager.MY_PLAYER_ID:
		set_process(false)
		return

	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _process(_delta: float) -> void:
	if not is_instance_valid(hovered_entity):
		hovered_entity = null

func _on_mouse_entered():
	if not _currently_hovered_entities.has(my_owner):
		_currently_hovered_entities.append(my_owner)
		_update_hovered_entity()

func _on_mouse_exited():
	_currently_hovered_entities.erase(my_owner)
	_update_hovered_entity()

static func _update_hovered_entity():
	# Clean up invalid entities first
	_currently_hovered_entities = _currently_hovered_entities.filter(func(e): return is_instance_valid(e))

	if _currently_hovered_entities.is_empty():
		hovered_entity = null
		return

	var best_entity := _currently_hovered_entities[0]
	for e in _currently_hovered_entities:
		if e.global_position.y > best_entity.global_position.y:
			best_entity = e

	hovered_entity = best_entity
