class_name RpcHandler

extends Node

var _my_owner: Entity
var _hud: HUD

func initialize() -> void:
	_my_owner = GlobalsEntityHelpers.get_owner(self)
	_hud = _my_owner.hud

# region 	MESSAGES RECEIVED FROM CLIENT
func key_pressed(keycode: int): rpc("_on_key_pressed", keycode)
@rpc("authority", "call_local")
func _on_key_pressed(keycode: int): _my_owner.key_pressed(keycode)

func skill_uppgrade_button_pressed(slot_number: int): rpc("_on_skill_uppgrade_button_pressed", slot_number)
@rpc("authority", "call_local")
func _on_skill_uppgrade_button_pressed(slot_number: int):
	_my_owner.upgrade_skill(slot_number)
# endregion MESSAGES RECEIVED FROM CLIENT


# region 	MESSAGES RECEIVED FROM SERVER

# func notify_effects_removed(data: Array): rpc("_on_notify_effects_removed", data)
# @rpc("authority", "call_local")
# func _on_notify_effects_removed(data: Array):
# 	_my_owner.notify_effects_removed(data)

func show_countdown_message(data: String): rpc("_on_show_countdown_message", data)
@rpc("authority", "call_local")
func _on_show_countdown_message(message: String):
	CountdownLabel.show_countdown_number(message)

func update_base_stats(new_stats_data: Dictionary): rpc("_on_update_base_stats", new_stats_data)
@rpc("authority", "call_local")
func _on_update_base_stats(new_stats_data: Dictionary):
	_my_owner.update_base_stats(CombatStats.get_instance_from_dict(new_stats_data))

func server_message(data: Dictionary): rpc("_on_server_message", data)
@rpc("authority", "call_local")
func _on_server_message(data: Dictionary):
	var sm = ServerMessage.new()
	ObjectHelpers.from_dict(sm, data)
	_hud.show_popup(sm.message, sm.get_color())

func receive_damage_or_heal(data: Dictionary): rpc("_on_receive_damage_or_heal", data)
@rpc("authority", "call_local")
func _on_receive_damage_or_heal(data: Dictionary):
	var di = DamageInfo.get_instance()
	ObjectHelpers.from_dict(di, data)
	_my_owner.global_receive_damage_or_heal(di)

func die(): rpc("_on_die")
@rpc("authority", "call_local")
func _on_die():
	print("⚔️ Entity died")
	print("Multiplayer: ", _my_owner.multiplayer.is_server())
	_my_owner._global_die()

func add_animation(anim_name: String, anim_speed: float = 25, repeat_count: int = 1) -> void:
	if not GameManager.AM_I_HOST: return print("Not host")

	var message = AddAnimationMessage.new()
	message.animation_name = anim_name
	message.animation_speed = anim_speed
	message.repeat_count = repeat_count
	var data = ObjectHelpers.to_dict(message, true)
	rpc("_on_add_animation", data)
@rpc("authority", "call_local")
func _on_add_animation(data: Dictionary):
	var message = AddAnimationMessage.new()
	ObjectHelpers.from_dict(message, data)
	AnimationsHelper.apply_animation(message, _my_owner)

func send_item_updated(slot_item_info: SlotItemInfo) -> void:
	if not GameManager.AM_I_HOST: return print("Not host")
	var data = ObjectHelpers.to_dict(slot_item_info, true)
	rpc("_on_slot_item_info_updated", data)
@rpc("authority", "call_local")
func _on_slot_item_info_updated(data: Dictionary):
	var slot_item_info := SlotItemInfo.new()
	slot_item_info.item = Item.new()
	ObjectHelpers.from_dict(slot_item_info, data)
	_my_owner.item_updated_by_rpc(slot_item_info)
# endregion MESSAGES RECEIVED FROM SERVER


func notify_effect_added_to_clients(effect: CombatEffect) -> void:
	for peer_id in MultiplayerManager.multiplayer.get_peers():
		if peer_id == MultiplayerManager.multiplayer.get_unique_id(): continue
		rpc_id(peer_id, "_on_effect_added", ObjectHelpers.to_dict(effect, true))
@rpc("any_peer", "reliable")
func _on_effect_added(data: Dictionary) -> void:
	if GameManager.AM_I_HOST: return

	_my_owner.effects_helper.add_effect(CombatEffect.get_instance_from_dict(data))

func notify_effects_removed_to_clients(removed_ids: Array[int]) -> void:
	for peer_id in MultiplayerManager.multiplayer.get_peers():
		if peer_id == MultiplayerManager.multiplayer.get_unique_id(): continue
		rpc_id(peer_id, "_on_effects_removed", removed_ids)
@rpc("any_peer", "reliable")
func _on_effects_removed(removed_ids: Array[int]) -> void:
	if GameManager.AM_I_HOST: return

	_my_owner.effects_helper.remove_effect_by_ids(removed_ids)
