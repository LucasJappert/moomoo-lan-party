class_name Item

extends ItemSkillBase

const Names = {
	HEALTH_POTION_I = "Health Potion I",
	HEALTH_POTION_II = "Health Potion II",
	HEALTH_POTION_III = "Health Potion III",
	MANA_POTION_I = "Mana Potion I",
	MANA_POTION_II = "Mana Potion II",
	MANA_POTION_III = "Mana Potion III",
	STUNNING_EDGE = "Stunning Edge"
}

static var _ITEMS: Dictionary[String, Item]
const _ATLAS_START_POS = Vector2(0, 1504)

var cost: int = 0

var region_rect: Rect2 = Rect2()

func _init(_name: String = "", _type: String = SkillType.PASSIVE):
	my_name = _name
	type = _type

	
# region :::::::::::::::::::: SETTERs
static func initialize_items() -> void:
	var aux_item_name = ""
	var _item: Item

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
	_item.stats.hp = 200
	_item.cooldown = 0.5
	_item.cost = 10
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.hp) + " HP."
	# endregion
	
	# region ITEM HEALTH_POTION_II
	aux_item_name = Names.HEALTH_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 500
	_item.cooldown = 0.5
	_item.cost = 20
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.hp) + " HP."
	# endregion

	# region ITEM HEALTH_POTION_III
	aux_item_name = Names.HEALTH_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y, FRAME_SIZE, FRAME_SIZE)
	_item.stats.hp = 2000
	_item.cooldown = 0.5
	_item.cost = 50
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.hp) + " HP."
	# endregion

	
	# region ITEM MANA_POTION_I
	aux_item_name = Names.MANA_POTION_I
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 0, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 100
	_item.cooldown = 0.5
	_item.cost = 10
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_II
	aux_item_name = Names.MANA_POTION_II
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 1, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 500
	_item.cooldown = 0.5
	_item.cost = 20
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.mana) + " mana."
	# endregion

	# region ITEM MANA_POTION_III
	aux_item_name = Names.MANA_POTION_III
	_ITEMS[aux_item_name] = Item.new(aux_item_name, SkillType.ACTIVE)
	_item = _ITEMS[aux_item_name]
	_item.region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * 2, _ATLAS_START_POS.y + FRAME_SIZE * 1, FRAME_SIZE, FRAME_SIZE)
	_item.stats.mana = 2000
	_item.cooldown = 0.5
	_item.cost = 50
	_item.description = "Restores " + StringHelpers.format_float(_item.stats.mana) + " mana."
	# endregion

# endregion ................. SETTERs


# region :::::::::::::::::::: GETTERs
static func get_item(_item_name: String, new_copy: bool = true) -> Item:
	if _ITEMS.is_empty(): initialize_items()
	
	if new_copy: return ObjectHelpers.deep_clone(_ITEMS[_item_name])
	
	return _ITEMS[_item_name]

func get_description() -> String:
	var result = super.get_description()

	if cost > 0:
		result += str("- Cost: ", cost, "\n")
		result += str("- Sell: ", int(cost * 0.7), "\n")
	
	return result


# endregion ................. GETTERs