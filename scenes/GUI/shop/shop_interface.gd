extends Control
class_name ShopInterface

@onready var _container_of_container_item_by_types: VBoxContainer = %ContainerOfContainerItemByTypes
@onready var _container_item_by_types_model: VBoxContainer = %ContainerItemByTypesModel
@onready var _main_container_items: NinePatchRect = %MainContainerItems
@onready var _shop_button: MyButton = %ShopButton

var _items_visible := true
const ORIGINAL_WIDTH = 430

func _ready() -> void:
	_main_container_items.gui_input.connect(_on_main_container_gui_input)
	_main_container_items.position.x = ORIGINAL_WIDTH
	_container_item_by_types_model.visible = false

	close_shop()
	_shop_button.on_pressed = _toggle_shop

	var titles := ["Consumables:", "Equipment:"]
	var filtered_items := [Item.get_items_by_consumable(true), Item.get_items_by_consumable(false)]
	for i in range(titles.size()):
		var container_item_by_types_clone := _container_item_by_types_model.duplicate()
		container_item_by_types_clone.visible = true
		var label_title = container_item_by_types_clone.get_node("LabelTitle") as Label
		label_title.text = titles[i]
		var items_container = container_item_by_types_clone.get_node("ItemsContainer") as GridContainer
		for child in items_container.get_children():
			items_container.remove_child(child)
			child.queue_free()
		_container_of_container_item_by_types.add_child(container_item_by_types_clone)

		for item in filtered_items[i]:
			var shop_item = ShopItem.get_instance(item)
			items_container.add_child(shop_item)


func _on_main_container_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed: _on_shop_interface_clicked(event)

func _toggle_shop() -> void:
	if _items_visible: close_shop()
	else: open_shop()
const TWEEN_DURATION := 0.2
func close_shop() -> bool:
	if not _items_visible: return false
	_items_visible = false
	_shop_button.text = "Shop"
	
	var custom_tween := MyCustomTween.new(_main_container_items)
	custom_tween.tween_property(_main_container_items, "position:x", ORIGINAL_WIDTH, TWEEN_DURATION)
	custom_tween.start()

	return true
func open_shop():
	_items_visible = true
	_shop_button.text = "Hide"
	
	var custom_tween := MyCustomTween.new(_main_container_items)
	custom_tween.tween_property(_main_container_items, "position:x", 0, TWEEN_DURATION)
	custom_tween.start()

static func static_close_shop() -> bool:
	return GameManager.game_world.gui_scene.shop_interface.close_shop()

static func _on_shop_interface_clicked(_event: InputEventMouseButton) -> void:
	if not DraggableSlot.ghost: return
	if not GameManager.MY_PLAYER: return

	GameManager.MY_PLAYER.increment_current_gold(int(DraggableSlot.ghost.item.get_sell_price()))
	GameManager.MY_PLAYER.update_item(null, DraggableSlot.ghost.slot_number - 1)

	DraggableSlot.ghost.emit_drop(false)
