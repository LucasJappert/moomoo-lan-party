class_name RpcHandler

extends Node

var _my_owner: Entity
var _combat_data: CombatData
var _hud: HUD

# func _init(my_owner: Entity):
# 	_my_owner = my_owner
# 	_combat_data = _my_owner.combat_data
# 	_hud = _my_owner.hud
func initialize() -> void:
	_my_owner = GlobalsEntityHelpers.get_owner(self)
	_combat_data = _my_owner.combat_data
	_hud = _my_owner.hud

# region 	SERVER MESSAGES RECEIVED FROM CLIENT

# endregion SERVER MESSAGES RECEIVED FROM CLIENT


# region 	CLIENTS MESSAGES RECEIVED FROM SERVER
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
	_combat_data.global_receive_damage_or_heal(di)

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
	var data = ObjectHelpers.to_dict(message)
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
	_my_owner.combat_data.item_updated_by_rpc(slot_item_info)
# endregion CLIENTS MESSAGES RECEIVED FROM SERVER
