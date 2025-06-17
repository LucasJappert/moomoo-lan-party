class_name ItemSlotsContainer

extends Node2D

const _ITEMS_COUNT = 6
var _slots_items: Array[SlotItem] = [] # Shortcut to children

func _ready():
	for child in get_children():
		_slots_items.append(child as SlotItem)
	
	EventBus.connect(EventBus.ITEM_UPDATED, func(_owner: Entity, slot_item_info: SlotItemInfo, _target: Entity): _on_item_updated(_owner, slot_item_info, _target))

func _on_item_updated(_owner: Entity, slot_item_info: SlotItemInfo, _target: Entity) -> void:
	if not _owner.is_my_player(): return
	_slots_items[slot_item_info.position - 1].update(slot_item_info)
