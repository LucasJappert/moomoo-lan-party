class_name Item

extends ItemSkillBase
static var REGISTERED_ITEMS: Array = [
	ItemBloodEdge,
]

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
static var aux_array: Array = [[], [], [], [], [], [], [], [], [], [], [], []]

var quantity: int = 1
var is_consumable: bool = false
var buy_price: int = 0
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
	
	# region ITEM CLEAVE_EDGE
	aux_item_name = Names.CLEAVE_EDGE
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.PASSIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 4, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)
	_item.stats.cleave_effect = CleaveEffect.new(0.3, 2)
	_item.buy_price = 3300
	_item.description = "Grants a " + StringHelpers.format_percent(_item.stats.cleave_effect.percent) + " extra damage to enemies around " + str(_item.stats.cleave_effect.radius_in_tiles) + " tiles."
	# endregion

	# region ITEM STUNNING_EDGE
	aux_item_name = Names.STUNNING_EDGE
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.PASSIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 3, _ATLAS_START_POS.y + FRAME_SIZE * 0, FRAME_SIZE, FRAME_SIZE)
	_item.stats.stun_chance = 0.2
	_item.stats.stun_duration = 1.5
	_item.buy_price = 2400
	_item.description = "Grants a " + StringHelpers.format_percent(_item.stats.stun_chance) + " chance to stun the target for " + StringHelpers.format_float_compact(_item.stats.stun_duration) + " seconds."
	# endregion

	# region ITEM HEALTH_POTION_I
	aux_item_name = Names.HEALTH_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 500
	_item.cooldown = 0.5
	_item.buy_price = 10
	_item.is_consumable = true
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion
	
	# region ITEM HEALTH_POTION_II
	aux_item_name = Names.HEALTH_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 2000
	_item.cooldown = 0.5
	_item.buy_price = 20
	_item.is_consumable = true
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion

	# region ITEM HEALTH_POTION_III
	aux_item_name = Names.HEALTH_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 10000
	_item.cooldown = 0.5
	_item.buy_price = 50
	_item.is_consumable = true
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.hp) + " HP."
	# endregion

	
	# region ITEM MANA_POTION_I
	aux_item_name = Names.MANA_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 500
	_item.cooldown = 0.5
	_item.buy_price = 10
	_item.is_consumable = true
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_II
	aux_item_name = Names.MANA_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 2000
	_item.cooldown = 0.5
	_item.buy_price = 20
	_item.is_consumable = true
	_item.description = "Restores " + StringHelpers.format_float_compact(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_III
	aux_item_name = Names.MANA_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.cast_range_in_tiles = 0
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 10000
	_item.cooldown = 0.5
	_item.buy_price = 50
	_item.is_consumable = true
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

func get_description(include_stats_description: bool = true) -> String:
	var result = super.get_description(include_stats_description)

	if buy_price > 0:
		result += "\n"
		result += str("- Buy price: ", StringHelpers.format_float(buy_price), "\n")
		result += str("- Sell price: ", StringHelpers.format_float(buy_price * 0.7), "\n")
	
	return result

func can_use(my_owner: Entity) -> bool:
	if not is_consumable && type == SkillType.PASSIVE: return false
	if quantity <= 0: return false

	return super.can_use(my_owner)

# endregion ................. GETTERs


# region :::::::::::::::::::: ITEMs LOGICS

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not ObjectHelpers.valid_instance(_attacker): return
	
	# Cleave verification
	var cleave_items := _attacker.get_items_by_name(Names.CLEAVE_EDGE)
	if cleave_items.is_empty(): return
	var total_stats := CombatStats.new()
	for _item in cleave_items:
		total_stats.accumulate_combat_stats(_item.stats)
	if total_stats.cleave_effect:
		CleaveEffect.auxiliary_actions_after_hit(total_stats, _attacker, _target, _di)
	
	# var cleave_stats := CombatStats.new()
	# for _item in cleave_items:
	# 	cleave_stats.accumulate_combat_stats(_item.stats)
	# CleaveEffect.auxiliary_actions_after_hit(_item.stats, _attacker, _target, _di)

# endregion ................. SKILLS LOGICS