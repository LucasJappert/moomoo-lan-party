class_name Item

extends ItemSkillBase

const Names = {
	HEALTH_POTION_I = "Health Potion I",
	HEALTH_POTION_II = "Health Potion II",
	HEALTH_POTION_III = "Health Potion III",
	MANA_POTION_I = "Mana Potion I",
	MANA_POTION_II = "Mana Potion II",
	MANA_POTION_III = "Mana Potion III",
	STUNNING_EDGE = "Stunning Edge",
	CLEAVE_EDGE = "Cleave Edge",
}

static var _ITEMS: Dictionary[String, Item]
const _ATLAS_START_POS = Vector2(0, 1504)

var quantity: int = 1
var is_consumable: bool = false
var cost: int = 0
var region_rect: Rect2 = Rect2()

func _init(_name: String = "", _type: String = SkillType.PASSIVE):
	super._init()
	my_name = _name
	type = _type

	
# region :::::::::::::::::::: SETTERs
static func initialize_items() -> void:
	var aux_item_name = ""
	var _item: Item

	# region ITEM CLEAVE_EDGE
	aux_item_name = Names.CLEAVE_EDGE
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.PASSIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 4, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)
	_item.stats.cleave_effect = CleaveEffect.new(0.3, 2)
	# endregion

	# region ITEM STUNNING_EDGE
	aux_item_name = Names.STUNNING_EDGE
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.PASSIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 3, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)
	_item.stats.stun_chance = 0.2
	_item.stats.stun_duration = 1.5
	# endregion

	# region ITEM HEALTH_POTION_I
	aux_item_name = Names.HEALTH_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 500
	_item.cooldown = 0.5
	_item.cost = 10
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion
	
	# region ITEM HEALTH_POTION_II
	aux_item_name = Names.HEALTH_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 2000
	_item.cooldown = 0.5
	_item.cost = 20
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion

	# region ITEM HEALTH_POTION_III
	aux_item_name = Names.HEALTH_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 10000
	_item.cooldown = 0.5
	_item.cost = 50
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion

	
	# region ITEM MANA_POTION_I
	aux_item_name = Names.MANA_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 500
	_item.cooldown = 0.5
	_item.cost = 10
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_II
	aux_item_name = Names.MANA_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 2000
	_item.cooldown = 0.5
	_item.cost = 20
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_III
	aux_item_name = Names.MANA_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 10000
	_item.cooldown = 0.5
	_item.cost = 50
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.mana) + " mana."
	# endregion

func use_item(_slot_number: int, _my_owner: Entity, _target: Entity = null) -> void:
	if not can_use(_my_owner): return print("Cannot use slot: ", my_name)

	var health_names = [Item.Names.HEALTH_POTION_I, Item.Names.HEALTH_POTION_II, Item.Names.HEALTH_POTION_III]
	if health_names.has(my_name):
		if not _my_owner.current_hp < _my_owner.get_total_hp(): return
		_my_owner.update_current_hp(stats.get_total_stats_including_extras_by_attributes().hp)

	var mana_names = [Item.Names.MANA_POTION_I, Item.Names.MANA_POTION_II, Item.Names.MANA_POTION_III]
	if mana_names.has(my_name):
		if not _my_owner.current_mana < _my_owner.get_total_mana(): return
		_my_owner.update_current_mana(stats.get_total_stats_including_extras_by_attributes().mana)


	_aux_after_use(_slot_number, _my_owner, _target)
		
func _aux_after_use(_slot_number: int, _my_owner: Entity, _target: Entity = null) -> void:
	if mana_cost > 0: _my_owner.update_current_mana(-mana_cost)

	reset_last_used_time()

	quantity -= 1
	if quantity < 0: quantity = 0

	var _message = ItemUpdatedMessage.new(self, _slot_number)
	_my_owner.rpc_handler.send_item_updated(_message)

# endregion ................. SETTERs


# region :::::::::::::::::::: GETTERs
static func get_item(_item_name: String, p_quantity: int = 1, p_is_consumable: bool = false, new_copy: bool = true) -> Item:
	if _ITEMS.is_empty(): initialize_items()
	
	if not new_copy: return _ITEMS[_item_name]
	
	var new_item: Item = ObjectHelpers.deep_clone(_ITEMS[_item_name])
	new_item.quantity = p_quantity
	new_item.is_consumable = p_is_consumable
	return new_item

func get_description(include_stats_description: bool = true) -> String:
	var result = super.get_description(include_stats_description)

	if cost > 0:
		result += str("- Cost: ", cost, "\n")
		result += str("- Sell: ", int(cost * 0.7), "\n")
	
	return result

func can_use(my_owner: Entity) -> bool:
	if not is_consumable && type == SkillType.PASSIVE: return false
	if quantity <= 0: return false

	return super.can_use(my_owner)

# endregion ................. GETTERs


# region :::::::::::::::::::: ITEMs LOGICS

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	# Cleave verification
	var cleave_items := _attacker.get_items_by_name(Names.CLEAVE_EDGE)
	for _item in cleave_items:
		CleaveEffect.auxiliary_actions_after_hit(_item.stats, _attacker, _target, _di)

# endregion ................. SKILLS LOGICS