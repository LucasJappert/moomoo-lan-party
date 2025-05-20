class_name MyTree

extends Node2D

const SAMPLE_TREES_PERCENTAGE = 0.3
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
	var grass_cell_type = Vector2i(0, 3)
	var grass_cells = get_cells_with_atlas_coords(grass_cell_type)

	# obtenemos un numero aleatorio de esas celdas
	var random_sample = get_random_sample(grass_cells, SAMPLE_TREES_PERCENTAGE)
	
	for cell_64 in random_sample:
		var cell_32 = cell_64 * 2
		print(cell_32)
		var random_cell = Vector2i(cell_32.x + randi() % 2, cell_32.y + randi() % 2)
		print(random_cell)
		spawn_tree(random_cell, _get_random_tree_type())
	pass

static func get_cells_with_atlas_coords(target_coords: Vector2i) -> Array[Vector2i]:
	var matching_cells: Array[Vector2i] = []

	# Obtener el área dibujada del GameManager.terrain (bounding box de todas las celdas usadas)
	var used_rect: Rect2i = GameManager.terrain.get_used_rect()
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var cell = Vector2i(x, y)

			if GameManager.terrain.get_cell_source_id(cell) == -1:
				continue # celda vacía

			var coords = GameManager.terrain.get_cell_atlas_coords(cell)
			if coords == target_coords:
				matching_cells.append(cell)

	return matching_cells

static func get_random_sample(cells: Array, percent: float) -> Array:
	var total := cells.size()
	var sample_size := int(ceil(total * percent))
	
	var shuffled := cells.duplicate()
	shuffled.shuffle()

	return shuffled.slice(0, sample_size)

static func _get_random_tree_type() -> int:
	return randi_range(1, TreeType.keys().size())
