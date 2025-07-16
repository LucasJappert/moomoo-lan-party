extends Control
class_name ShopItem

const SCENE = preload("res://scenes/GUI/shop/components/shop_item.tscn")

@onready var sprite: Sprite2D = %Sprite
@onready var panel: NinePatchRect = %Panel
@onready var texture_rect: TextureRect = %TextureRect

var _item: Item
var _is_hovering := false

static func get_instance(item: Item) -> ShopItem:
	var instance: ShopItem = SCENE.instantiate()
	instance._item = item
	return instance
	

func _ready() -> void:
	if not _item: return
	
	connect("child_exiting_tree", _on_child_exiting_tree)
	texture_rect.connect("mouse_entered", _on_mouse_entered)
	texture_rect.connect("mouse_exited", _on_mouse_exited)
	texture_rect.connect("gui_input", _on_button_click)

	sprite.region_rect = _item.region_rect
	
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = SpritesHelper._ATLAS1
	atlas_texture.region = _item.region_rect
	texture_rect.texture = atlas_texture


func _on_child_exiting_tree(_child) -> void:
	if _is_hovering: MyTooltip.hide_tooltip()

func _on_mouse_entered():
	_is_hovering = true
	MyTooltip.show_tooltip(_item.my_name, _item.get_description(false))

func _on_mouse_exited():
	_is_hovering = false
	MyTooltip.hide_tooltip()

func _on_button_click(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("Buy item: ", _item.my_name)
		_try_apply_shop(_item)

func _try_apply_shop(item: Item) -> void:
	if not GameManager.MY_PLAYER: return

	return GameManager.MY_PLAYER.shopping_helper.try_shop_item(item)
