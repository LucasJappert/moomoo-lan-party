class_name CombatEffect

extends CombatAttributes

@export var _duration: float # In seconds
var _elapsed: float = 0.0

# Only executed on the server
func initialize(combat_attributes: CombatAttributes, duration: float) -> void:
	super.initialize_from_combat_attributes(combat_attributes)
	_duration = duration

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		if multiplayer.is_server(): queue_free() # Only executed on the server

static func get_instance(duration: float, combat_attributes: CombatAttributes = CombatAttributes.new()) -> CombatEffect:
	const SCENE = preload("res://scenes/entity/combat_data/combat_effect.tscn")
	var combat_effect = SCENE.instantiate()
	combat_effect.initialize(combat_attributes, duration)
	return combat_effect
