extends MultiplayerSynchronizer

@onready var player: CharacterBody2D = get_parent()

@export var target_position: Vector2 = Vector2.ZERO

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _input(event):
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Right mouse button clicked. Player id: " + player.name)
			target_position = player.get_global_mouse_position()

# func _physics_process(_delta: float):
# 	if nav_agent.is_navigation_finished():
# 		return

# 	var distance_to_target = player.global_position.distance_to(nav_agent.target_position)
# 	if distance_to_target <= player.collision_shape.shape.radius:
# 		nav_agent.set_target_position(player.global_position)
# 		player.velocity = Vector2.ZERO
# 		return
	
# 	var next_point = nav_agent.get_next_path_position()
# 	var dir = (next_point - player.global_position).normalized()
# 	player.velocity = dir * player.speed

# func _unhandled_input(event):
# 	# print("is_multiplayer_authority(): " + str(is_multiplayer_authority()))
# 	# if not is_multiplayer_authority():
# 	# 	return
# 	if event is InputEventMouseButton and event.button_index == F and event.pressed:
# 		print("Right mouse button clicked. Player id: " + player.name)
# 		print("is_multiplayer_authority(): " + str(is_multiplayer_authority()))
# 		if multiplayer.get_unique_id() != get_multiplayer_authority():
# 			return
# 		nav_agent.set_target_position(player.get_global_mouse_position())
