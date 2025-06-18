class_name SlotItem

extends Control

@onready var sprite = $Sprite
@onready var hotkey = $Hotkey
@onready var label_cool_down = $LabelCoolDown
@onready var label_amount = $LabelAmount

var info := SlotItemInfo.new()

const HOTKEY_BY_SLOT = ["1", "2", "3", "4", "5", "6"]

func _ready():
	label_cool_down.text = "0"
	label_cool_down.visible = false
	connect("mouse_entered", func(): _on_mouse_entered())
	connect("mouse_exited", func(): _on_mouse_exited())

func _process(_delta: float) -> void:
	if not info.item: return

	var remaining_cooldown := info.item.get_remaining_cooldown()
	if remaining_cooldown > 0:
		label_cool_down.visible = true
		label_cool_down.text = StringHelpers.format_float(remaining_cooldown, 1)
	else:
		label_cool_down.visible = false

func _on_mouse_entered():
	if not info.item: return
	GameManager.show_tooltip(info.item.item_name, info.item.get_description())

func _on_mouse_exited():
	if not info.item: return
	GameManager.hide_tooltip()

func set_info(slot_item_info: SlotItemInfo):
	info = slot_item_info

	update()

func update():
	_update_sprite()
	hotkey.text = HOTKEY_BY_SLOT[info.position - 1]
	if info.item && info.quantity > 1:
		label_amount.text = str(info.quantity)
	else: label_amount.text = ""

func _update_sprite():
	if not info.item:
		sprite.visible = false
		return

	sprite.visible = true
	sprite.region_rect = info.item.region_rect
	sprite.scale = size / sprite.region_rect.size
