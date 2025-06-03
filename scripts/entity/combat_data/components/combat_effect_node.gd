extends Node2D

var my_owner: Entity # Use the safety _get_entity function

func _ready():
	connect("child_entered_tree", Callable(self, "_on_child_added"))

func _on_child_added(effect: CombatEffect):
	if effect.freeze_duration > 0:
		_get_entity().combat_data.apply_frost_hit_animation()

	if effect.stun_duration > 0:
		_get_entity().combat_data.apply_stun_animation()

	# Escuchamos cuando este hijo salga del árbol
	effect.tree_exited.connect(func(): _on_child_removed(effect))

func _on_child_removed(effect: CombatEffect):
	if effect.stun_duration > 0:
		_get_entity().combat_data.try_to_remove_obsolete_stun_animation()

func _get_entity() -> Entity:
	if my_owner: return my_owner

	var current = self
	var max_depth := 10
	while current and max_depth > 0:
		max_depth -= 1
		if current is Entity:
			my_owner = current
			return my_owner
		current = current.get_parent()

	print("⚠️ CombatEffectNode has no Entity owner")
	return null