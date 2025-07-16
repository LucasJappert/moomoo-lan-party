class_name ItemSlotsContainer

extends Node2D

const _ITEMS_COUNT = 6
var _slots_items: Array[SlotItem] = [] # Shortcut to children

func _ready():
	for child in get_children():
		_slots_items.append(child as SlotItem)
	
	EventBus.connect_to_item_updated(func(_owner: Entity, _item: Item, _slot_number: int): _on_item_updated(_owner, _item, _slot_number))

func _on_item_updated(_owner: Entity, _item: Item, _slot_number: int) -> void:
	if _owner != GameManager.game_world.gui_scene._bottom_target: return
	_slots_items[_slot_number - 1].item_updated(_item)
