class_name CombatEffect

extends CombatStats

@export var _duration: float # In seconds
var _elapsed: float = 0.0

# Only executed on the server
func initialize(stats: CombatStats, duration: float) -> void:
	super.accumulate_combat_stats(stats)
	_duration = duration

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		if multiplayer.is_server(): queue_free() # Only executed on the server

static func get_instance(duration: float, stats: CombatStats = CombatStats.new()) -> CombatEffect:
	const SCENE = preload("res://scenes/entity/combat_data/combat_effect.tscn")
	var combat_effect = SCENE.instantiate()
	combat_effect.initialize(stats, duration)
	return combat_effect
