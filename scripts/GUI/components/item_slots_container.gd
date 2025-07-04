class_name ItemSlotsContainer

extends Node2D

const _ITEMS_COUNT = 6
var _slots_items: Array[SlotItem] = [] # Shortcut to children

func _ready():
	for child in get_children():
		_slots_items.append(child as SlotItem)
	
	EventBus.connect_to_item_updated(func(_owner: Entity, slot_item_info: SlotItemInfo, _target: Entity): _on_item_updated(_owner, slot_item_info, _target))

func _process(_delta: float) -> void:
	pass
	# if GlobalsEntityHelpers.get_owner().is_my_player():
	# 	for child in get_children():
	# 		child.update()

func _on_item_updated(_owner: Entity, slot_item_info: SlotItemInfo, _target: Entity) -> void:
	if not _owner.is_my_player(): return
	_slots_items[slot_item_info.position - 1].item_updated(slot_item_info)
