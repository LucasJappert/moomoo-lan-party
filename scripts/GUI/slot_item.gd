class_name SlotItem

extends Control

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
@onready var label_cool_down = $LabelCoolDown
@onready var label_amount = $LabelAmount

var item: Item = null
var slot_number: int = 0
var _is_my_player_owner: bool

const HOTKEY_BY_SLOT = ["1", "2", "3", "4", "5", "6"]
static var SLOTS_NUMBER: int = HOTKEY_BY_SLOT.size()

func _init(p_item: Item = null, p_slot_number: int = 0, p_quantity: int = 1, is_my_player_owner: bool = true):
	item = p_item
	slot_number = p_slot_number
	if item: item.quantity = p_quantity
	_is_my_player_owner = is_my_player_owner
	
func _ready():
	label_cool_down.text = "0"
	label_cool_down.visible = false
	
	hotkey.text = HOTKEY_BY_SLOT[get_index()]

	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())

func _process(_delta: float) -> void:
	if not GameManager.MY_PLAYER: return
	if not item: return

	if can_use(GameManager.MY_PLAYER):
		label_cool_down.visible = false
		sprite.modulate = ItemSkillBase.CAN_USE_COLOR
		return

	# Cant use
	sprite.modulate = ItemSkillBase.CANT_USE_COLOR
	var remaining_cooldown := item.get_remaining_cooldown()
	if remaining_cooldown > 0:
		label_cool_down.visible = true
		label_cool_down.text = StringHelpers.format_float_compact(remaining_cooldown, 1)
	else:
		label_cool_down.visible = false

func _on_mouse_entered():
	if not item: return
	MyTooltip.show_tooltip(item.my_name, item.get_description(false))

func _on_mouse_exited():
	if not item: return
	MyTooltip.hide_tooltip()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not GameManager.MY_PLAYER: return
		GameManager.MY_PLAYER.rpc_handler.notify_key_pressed_to_server(KeyboardHelper.INVENTORY_HOTKEYS[slot_number - 1])
		
# region	GETTERS

func can_use(my_owner: Entity) -> bool:
	if not item: return false
	return item.can_use(my_owner)
	
# endregion GETTERS

# region 	SETTERS
func item_updated(_item: Item):
	item = _item
	_update_controls()

func _update_sprite():
	if not item:
		sprite.visible = false
		return

	sprite.visible = true
	sprite.region_rect = item.region_rect
	sprite.scale = size / sprite.region_rect.size

func _update_controls():
	_update_sprite()
	hotkey.text = OS.get_keycode_string(KeyboardHelper.INVENTORY_HOTKEYS[slot_number - 1])
	if item && item.quantity > 1: label_amount.text = str(item.quantity)
	else: label_amount.text = ""
# endregion SETTERS
