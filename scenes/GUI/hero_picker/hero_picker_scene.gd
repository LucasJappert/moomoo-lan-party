extends CanvasLayer
class_name HeroPickerScene

const HERO_BOX_SCENE: PackedScene = preload("res://scenes/GUI/hero_picker/hero_box.tscn")

@onready var grid_heros_container: GridContainer = %GridHerosContainer


func _ready() -> void:
	_clean_grid_heros_container()

	for hero_class in HeroBase.REGISTERED_HEROS:
		var hero_box = HERO_BOX_SCENE.instantiate()
		hero_box.set_hero_type(hero_class.LONG_NAME)
		grid_heros_container.add_child(hero_box)


# region	GETTERS
func get_hero_options() -> Array[HeroBox]:
	var result: Array[HeroBox] = []
	for child in grid_heros_container.get_children():
		result.append(child)
	return result

func get_selected_hero() -> HeroBox:
	for hero_box in get_hero_options():
		if hero_box.is_selected: return hero_box
	return null
# endregion GETTERS

# region	SETTERS

func _clean_grid_heros_container() -> void:
	for child in grid_heros_container.get_children():
		grid_heros_container.remove_child(child)
		child.queue_free()
# endregion SETTERS