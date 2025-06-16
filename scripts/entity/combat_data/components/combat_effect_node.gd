extends Node2D

var _my_owner: Entity

func _ready():
	connect("child_entered_tree", Callable(self, "_on_child_added"))

func _on_child_added(effect: CombatEffect):
	if effect.stats.freeze_duration > 0:
		AnimationsHelper.apply_frost_hit_animation(my_owner())

	if effect.stats.stun_duration > 0:
		AnimationsHelper.apply_stun_animation(my_owner())

	effect.tree_exited.connect(func(): _on_child_removed(effect))

func _on_child_removed(effect: CombatEffect):
	if effect.stats.stun_duration > 0:
		AnimationsHelper.try_to_remove_obsolete_stun_animation(my_owner())

func my_owner() -> Entity:
	if _my_owner: return _my_owner

	_my_owner = GlobalsEntityHelpers.get_owner(self)
	return _my_owner
