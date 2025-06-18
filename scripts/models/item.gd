class_name Item
#TODO: We could improve this module by using a shared class with Skill module
const Names = {
	HEALTH_POTION_I = "Health Potion I",
	HEALTH_POTION_II = "Health Potion II",
	HEALTH_POTION_III = "Health Potion III",
	MANA_POTION_I = "Mana Potion I",
	MANA_POTION_II = "Mana Potion II",
	MANA_POTION_III = "Mana Potion III"
}

static var _ITEMS: Dictionary[String, Item]
const FRAME_SIZE = 64
const _ATLAS_START_POS = Vector2(0, 1504)

var item_name: String
var type: String = SkillType.ACTIVE
var cooldown: float = 0 # In seconds
var mana_cost: int = 0
var description: String = ""
var apply_to_owner: bool = true
var max_stacks: int = 1
var stats: CombatStats = CombatStats.new()
var damage_type: String = DamageType.NONE
var max_targets: int = 1
var cost: int = 0

var region_rect: Rect2 = Rect2()
var _last_used_time: float = - INF

func _init(_name: String = "", _type: String = SkillType.PASSIVE):
	item_name = _name
	type = _type

	
# region :::::::::::::::::::: SETTERs
static func initialize_items() -> void:
	var aux_item_name = ""
	# var aux_text: String
	# var aux_text1: String
	var _item: Item

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

func set_last_used_time(last_used_time: float) -> void:
	_last_used_time = last_used_time
# endregion ................. SETTERs


# region :::::::::::::::::::: GETTERs
static func get_item(_item_name: String, new_copy: bool = true) -> Item:
	if _ITEMS.is_empty(): initialize_items()
	
	if not new_copy: return _ITEMS[_item_name]

	return ObjectHelpers.deep_clone(_ITEMS[_item_name]) as Item

func get_description() -> String:
	var result = description + "\n"

	if cost > 0:
		result += str("- Cost: ", cost, "\n")
		result += str("- Sell: ", int(cost * 0.7), "\n")
	
	if mana_cost > 0:
		result += str("- Mana cost: ", mana_cost, "\n")

	if cooldown > 0.0:
		result += str("- Cooldown: ", StringHelpers.format_float(cooldown), "s\n")

	if max_targets > 1:
		result += "- Max targets: " + str(max_targets) + "\n"

	if max_stacks > 1:
		result += "- Max stacks: " + str(max_stacks) + "\n"

	if damage_type != DamageType.NONE:
		result += "- Damage type: " + str(damage_type) + "\n"

	return result

func can_use(my_owner: Entity) -> bool:
	if mana_cost > 0:
		if my_owner.combat_data.current_mana < mana_cost: return false

	var now := Time.get_ticks_msec() / 1000.0
	return (now - _last_used_time) >= cooldown

func get_remaining_cooldown() -> float:
	var now := Time.get_ticks_msec() / 1000.0
	var elapsed := now - _last_used_time
	return max(0.0, cooldown - elapsed)

# endregion ................. GETTERs