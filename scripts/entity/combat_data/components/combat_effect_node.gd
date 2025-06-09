extends Node2D

var _my_owner: Entity

func _ready():
	connect("child_entered_tree", Callable(self, "_on_child_added"))

func _on_child_added(effect: CombatEffect):
	if effect.freeze_duration > 0:
		my_owner().combat_data.apply_frost_hit_animation()

	if effect.stun_duration > 0:
		my_owner().combat_data.apply_stun_animation()

	effect.tree_exited.connect(func(): _on_child_removed(effect))

func _on_child_removed(effect: CombatEffect):
	if effect.stun_duration > 0:
		my_owner().combat_data.try_to_remove_obsolete_stun_animation()

func my_owner() -> Entity:
	if _my_owner: return _my_owner

	_my_owner = GlobalsEntityHelpers.get_owner(self)
	return _my_owner
