class_name DraggableSlot
extends Control

enum SlotType {INVENTORY_ITEM, SHOP_ITEM}
var slot_type: SlotType
var is_cloned := false

@onready var sprite: Sprite2D = %Sprite
var item: Item
var slot_number: int = 0

static var ghost: DraggableSlot
var drag_offset := Vector2.ZERO

func _ready() -> void:
	print("DraggableSlot ready")

func _gui_input(event):
	if slot_type != SlotType.INVENTORY_ITEM: return
	
	if event is InputEventMouseButton and event.pressed:
		print("InputEventMouseButton")
		if ghost: emit_drop()

		if item and event.button_index == MOUSE_BUTTON_RIGHT:
			drag_offset = get_local_mouse_position()
			ghost = _create_ghost()
			GUIScene.get_draggable_slots_container().add_child(ghost)
			on_drag_started(self)

func _process(_delta):
	if ghost: ghost.global_position = get_global_mouse_position() - Vector2(32, 32)

func _create_ghost() -> DraggableSlot:
	var _clone: DraggableSlot = duplicate()
	_clone.slot_number = slot_number
	_clone.is_cloned = true
	_clone.item = self.item
	_clone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clone.modulate = Color(0.9, 0.9, 0.9, 0.9)
	# _clone.z_index = 1000
	return _clone

func emit_drop():
	if ghost:
		on_drag_ended(ghost)
		ghost.queue_free()
		ghost = null

# Must be overriden
func on_drag_started(_slot: DraggableSlot) -> void:
	print("on_drag_started ", _slot.slot_type)
	pass

# Must be overriden
func on_drag_ended(_slot: DraggableSlot) -> void:
	print("on_drag_ended", _slot.slot_type)
	pass


static func verify_global_click(_event: InputEventMouseButton) -> bool:
	if not ghost: return false

	if _event is InputEventMouseButton and _event.pressed:
		# _event.button_index == MOUSE_BUTTON_LEFT
		ghost.emit_drop()
		print("Soltamos el item en el suelo o shop")

	return true

static func on_shop_interface_clicked(_event: InputEventMouseButton) -> void:
	if not ghost: return
	if not GameManager.MY_PLAYER: return

	print("Soltamos el item en el shop")
	GameManager.MY_PLAYER.increment_current_gold(int(ghost.item.buy_price * Item.SELL_PRICE_FACTOR * ghost.item.quantity))
	GameManager.MY_PLAYER.update_item(null, ghost.slot_number - 1)

	ghost.emit_drop()