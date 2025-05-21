class_name MyTree

extends Node2D

const SAMPLE_TREES_PERCENTAGE = 0.07
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum TreeType {
	WEEPING_WILLOW = 1,
	PALM_TREE = 2,
	BROADLEAF_TREE = 3,
	CONIFER_TREE = 4
}

var tree_type: int = TreeType.WEEPING_WILLOW

func set_tree_type(new_tree_type: int) -> void:
	tree_type = new_tree_type

func _ready():
	sprite.frames = load("res://assets/trees/" + str(tree_type) + ".tres")
	pass

func _enter_tree() -> void:
	pass

static func spawn_tree(cell: Vector2i, p_tree_type: int = TreeType.WEEPING_WILLOW) -> void:
	var my_tree: MyTree = MyTreeFactory.get_my_tree_instance(cell, p_tree_type)
	GameManager.add_my_tree(my_tree)

static func spawn_trees() -> void:
	var grass_cells = MapManager.get_grass_cells()

	var random_sample = Utilities.get_random_sample(grass_cells, SAMPLE_TREES_PERCENTAGE)
	
	for cell in random_sample: spawn_tree(cell, _get_random_tree_type())


static func _get_random_tree_type() -> int:
	return randi_range(1, TreeType.keys().size())
