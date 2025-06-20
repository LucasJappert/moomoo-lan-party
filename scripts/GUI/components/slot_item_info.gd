class_name SlotItemInfo

var item: Item = null
var position: int = 0
var quantity: int = 1
var is_consumable: bool = false

func _init(p_item: Item = null, p_slot_number: int = 0, p_quantity: int = 1):
	item = p_item
	position = p_slot_number
	quantity = p_quantity
		
func use_item(_my_owner: Entity, _target: Entity = null) -> void:
	if not can_use(_my_owner): return print("Cannot use slot: ", position)

	var health_names = [Item.Names.HEALTH_POTION_I, Item.Names.HEALTH_POTION_II, Item.Names.HEALTH_POTION_III]
	if health_names.has(item.my_name):
		if not _my_owner.combat_data.current_hp < _my_owner.combat_data.get_total_hp(): return
		_my_owner.combat_data.update_current_hp(item.stats.get_total_stats_including_extras_by_attributes().hp)

	var mana_names = [Item.Names.MANA_POTION_I, Item.Names.MANA_POTION_II, Item.Names.MANA_POTION_III]
	if mana_names.has(item.my_name):
		if not _my_owner.combat_data.current_mana < _my_owner.combat_data.get_total_mana(): return
		_my_owner.combat_data.update_current_mana(item.stats.get_total_stats_including_extras_by_attributes().mana)


	_aux_after_use(_my_owner, _target)
		
func _aux_after_use(_my_owner: Entity, _target: Entity = null) -> void:
	if item.mana_cost > 0: _my_owner.combat_data.update_current_mana(-item.mana_cost)

	item.set_last_used_time()

	quantity -= 1
	if quantity <= 0:
		_clean_item()

	_my_owner.rpc_handler.send_item_updated(self)

func can_use(my_owner: Entity) -> bool:
	if item == null: return false
	if not is_consumable && item.type == SkillType.PASSIVE: return false
	if quantity <= 0: return false

	return item.can_use(my_owner)

func _clean_item() -> void:
	item = null
	quantity = 0

static func get_consumable_slot_item(p_item: Item, p_quantity: int = 1) -> SlotItemInfo:
	var slot_item_info = SlotItemInfo.new(p_item, 0, p_quantity)
	slot_item_info.is_consumable = true
	return slot_item_info
static func get_non_consumable_slot_item(p_item: Item) -> SlotItemInfo:
	return SlotItemInfo.new(p_item, 0, 1)