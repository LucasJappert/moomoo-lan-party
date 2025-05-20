class_name MyTreeFactory

const TREE_SCENE = preload("res://scenes/general_objects/my_tree.tscn")

static func get_my_tree_instance(cell: Vector2i, tree_type: int) -> Node2D:
	var tree = TREE_SCENE.instantiate()
	tree.set_tree_type(tree_type)
	tree.global_position = MapManager.cell_to_world(cell)
	return tree