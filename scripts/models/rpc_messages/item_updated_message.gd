class_name ItemUpdatedMessage

extends MyInitAuxiliary

var _item: Item
var _slot_number: int

func _init(p_item: Item = null, p_slot_number: int = 0):
	_item = p_item
	_slot_number = p_slot_number
	
	super._init()