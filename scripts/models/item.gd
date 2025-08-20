class_name Item

extends ItemSkillBase
static var REGISTERED_ITEMS: Array = [
	ItemDeadeye,
	ItemSkeletonSummonersRing,
	ItemSkywrath,
	ItemBloodQuake,
	ItemTitanGuard,
	ItemTrinityBoost,
	ItemGhostplate,
	ItemSwiftMirage,
	ItemSoulPact,
	ItemPhantomEdge,
	ItemMultiShot,
	ItemStunningEdge,
	ItemGhostplume,
	ItemBruteheart,
	ItemMindcore,
	ItemCleaveEdge,
	ItemBloodEdge,
	ItemPowerCore,
]

const Names = {
	HEALTH_POTION_I = "Health Potion I",
	HEALTH_POTION_II = "Health Potion II",
	HEALTH_POTION_III = "Health Potion III",
	MANA_POTION_I = "Mana Potion I",
	MANA_POTION_II = "Mana Potion II",
	MANA_POTION_III = "Mana Potion III",
}

static var _ITEMS: Dictionary[String, Item]
const _ATLAS_START_POS = Vector2(0, 1504)
static var aux_array: Array = [[], [], [], [], [], [], [], [], [], [], [], []]

var quantity: int = 1
var buy_price: int = 0
const SELL_PRICE_FACTOR = 0.7
var region_rect: Rect2 = Rect2()

func _init(_name: String = "", _type: String = SkillType.PASSIVE):
	super._init()
	my_name = _name
	type = _type

	
# region :::::::::::::::::::: SETTERs
static func initialize_items() -> void:
	var aux_item_name = ""
	var _item: Item

	for item_class in REGISTERED_ITEMS: item_class.create_and_add_instance()

	# region ITEM HEALTH_POTION_I
	aux_item_name = Names.HEALTH_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.set_hp(500)
	_item.cooldown = 0.5
	_item.buy_price = 5
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(500) + " HP."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(500) + " HP."
	# endregion
	
	# region ITEM HEALTH_POTION_II
	aux_item_name = Names.HEALTH_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.set_hp(2000)
	_item.cooldown = 0.5
	_item.buy_price = 10
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(2000) + " HP."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(2000) + " HP."
	# endregion

	# region ITEM HEALTH_POTION_III
	aux_item_name = Names.HEALTH_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.set_hp(10000)
	_item.cooldown = 0.5
	_item.buy_price = 30
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(10000) + " HP."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(10000) + " HP."
	# endregion

	
	# region ITEM MANA_POTION_I
	aux_item_name = Names.MANA_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.set_mana(500)
	_item.cooldown = 0.5
	_item.buy_price = 5
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(500) + " mana."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(500) + " mana."
	# endregion

	# region ITEM MANA_POTION_II
	aux_item_name = Names.MANA_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.set_mana(2000)
	_item.cooldown = 0.5
	_item.buy_price = 10
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(2000) + " mana."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(2000) + " mana."
	# endregion

	# region ITEM MANA_POTION_III
	aux_item_name = Names.MANA_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.set_mana(10000)
	_item.cooldown = 0.5
	_item.buy_price = 30
	_item.is_consumable = true
	_item.en_description = "Restores " + StringHelpers.format_float_compact(10000) + " mana."
	_item.es_description = "Restaura " + StringHelpers.format_float_compact(10000) + " mana."
	# endregion

func use_item(_slot_number: int, _my_owner: Entity, _target: Entity = null) -> void:
	if not can_use(_my_owner): return print("Cannot use slot: ", my_name)

	var health_names = [Item.Names.HEALTH_POTION_I, Item.Names.HEALTH_POTION_II, Item.Names.HEALTH_POTION_III]
	if health_names.has(my_name):
		if not _my_owner.current_hp < _my_owner.get_full_health(): return
		_my_owner.update_current_hp(get_hp())
		if _my_owner.is_my_player(): SoundsHelper.play_random_drink()

	var mana_names = [Item.Names.MANA_POTION_I, Item.Names.MANA_POTION_II, Item.Names.MANA_POTION_III]
	if mana_names.has(my_name):
		if not _my_owner.current_mana < _my_owner.get_full_mana(): return
		_my_owner.update_current_mana(get_mana())
		if _my_owner.is_my_player(): SoundsHelper.play_random_drink()


	_aux_after_use(_slot_number, _my_owner, _target)
		
func _aux_after_use(_slot_number: int, _my_owner: Entity, _target: Entity = null) -> void:
	if mana_cost > 0: _my_owner.update_current_mana(-mana_cost)

	reset_last_used_time()

	quantity -= 1
	if quantity < 0: quantity = 0

	_my_owner.update_item(self, _slot_number - 1)

# endregion ................. SETTERs


# region :::::::::::::::::::: GETTERs
static func get_items_by_consumable(_is_consumable: bool) -> Array[Item]:
	if _ITEMS.is_empty():
		initialize_items()
	
	var filtered_items: Array[Item] = _ITEMS.values().filter(
		func(item: Item): return item.is_consumable == _is_consumable
	)
	
	filtered_items.sort_custom(func(a: Item, b: Item):
		if a.buy_price == b.buy_price: return a.my_name < b.my_name
		return a.buy_price < b.buy_price
	)
	
	return filtered_items

static func get_item(_item_name: String, p_quantity: int = 1, new_copy: bool = true) -> Item:
	if _ITEMS.is_empty(): initialize_items()
	
	if not new_copy: return _ITEMS[_item_name]
	
	var new_item: Item = ObjectHelpers.deep_clone(_ITEMS[_item_name])
	new_item.quantity = p_quantity
	return new_item

func get_description(include_stats_description: bool = true, show_buy_price: bool = true) -> String:
	var result = super.get_description(include_stats_description)

	if buy_price > 0:
		result += "\n"
		if show_buy_price: result += str("- Buy price: ", StringHelpers.format_float(buy_price), "\n")
		if not show_buy_price: result += str("- Sell price: ", StringHelpers.format_float(buy_price * SELL_PRICE_FACTOR), "\n")
	
	return result

func can_use(my_owner: Entity) -> bool:
	if not is_consumable && type == SkillType.PASSIVE: return false
	if quantity <= 0: return false

	return super.can_use(my_owner)

func get_sell_price() -> int:
	return int(buy_price * SELL_PRICE_FACTOR * quantity)
# endregion ................. GETTERs

# Must be overriden
static func static_actions_after_execute_physical_attack(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void: pass

# Must be overriden
static func static_actions_before_receive_damage(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool: return false

# Must be overriden
static func static_actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool: return false

# Must be overriden
static func static_actions_after_interval_trigger(_effect: CombatEffect) -> bool: return false

# Must be overriden
static func static_actions_before_execute_physical_attack(_attacker: Entity, _target: Entity) -> void: pass

# Must be overriden
static func static_actions_after_update_item(_owner: Entity, _item: Item, _slot_number: int) -> void: pass