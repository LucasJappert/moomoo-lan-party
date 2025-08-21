class_name ShoppingHelper
extends MyInitAuxiliary

const MAX_STACK := 99
var _owner: Entity

func _init(p_owner: Entity):
	super._init()
	_owner = p_owner

func try_shop_item(_item: Item) -> bool:
	if _owner.current_gold < _item.buy_price:
		_owner.hud.show_message_popup(LanguageManager.translate("Not enough gold"), Color(1, 0, 0))
		return false

	var can_add_item = _try_add_equipable_item(_item) or _try_add_consumable_item(_item)
	if not can_add_item:
		_owner.hud.show_message_popup(LanguageManager.translate("Not enough space"), Color(1, 0, 0))
		return false
		
	_owner.increment_current_gold(-_item.buy_price, false, true)

	return true

func _try_add_equipable_item(_item: Item) -> bool:
	if not _item.is_consumable:
		for i in range(_owner.get_items().size()):
			if _owner.get_items()[i]: continue

			return _owner.update_item(Item.get_item(_item.my_name, 1, true), i)
		return false
	
	return false

func _try_add_consumable_item(_item: Item) -> bool:
	if _item.is_consumable:
		for i in range(_owner.get_items().size()):
			var current_item = _owner.get_items()[i]
			if current_item == null: continue
			if current_item.my_name != _item.my_name: continue
			if current_item.quantity >= MAX_STACK: continue

			var new_quantity = min(current_item.quantity + _item.quantity, MAX_STACK)
			return _owner.update_item(Item.get_item(_item.my_name, new_quantity, true), i)

		for i in range(_owner.get_items().size()):
			if _owner.get_items()[i]: continue

			return _owner.update_item(Item.get_item(_item.my_name, _item.quantity, true), i)
	
	return false