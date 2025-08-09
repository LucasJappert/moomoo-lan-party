class_name ShopItem
extends DraggableSlot

const SCENE = preload("res://scenes/GUI/shop/components/shop_item.tscn")

@onready var panel: NinePatchRect = %Panel
@onready var texture_rect: TextureRect = %TextureRect

static func get_instance(_item: Item) -> ShopItem:
	var instance: ShopItem = SCENE.instantiate()
	instance.item = _item
	return instance
	

func _ready() -> void:
	slot_type = SlotType.SHOP_ITEM
	super._ready()
	if not item: return
	
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

	sprite.region_rect = item.region_rect
	
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = SpritesHelper._ATLAS1
	atlas_texture.region = item.region_rect
	texture_rect.texture = atlas_texture


func _on_mouse_entered():
	MyTooltip.show_tooltip(item.my_name, item.get_description(true, true), 20)

func _on_mouse_exited():
	MyTooltip.hide_tooltip()

func _gui_input(event):
	super._gui_input(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_try_apply_shop()

func _try_apply_shop() -> void:
	if not item: return
	if not GameManager.MY_PLAYER: return

	return GameManager.MY_PLAYER.shopping_helper.try_shop_item(item)
