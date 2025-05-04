extends MultiplayerSynchronizer

@onready var player: CharacterBody2D = get_parent()
@onready var nav_agent: NavigationAgent2D = player.get_node("NavigationAgent2D")

@export var direction: Vector2 = Vector2.ZERO
@export var velocity: Vector2 = Vector2.ZERO

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	nav_agent.radius = 32
	nav_agent.target_desired_distance = 32
	nav_agent.path_desired_distance = 32
	nav_agent.max_speed = player.speed
	direction = Vector2.ZERO
	velocity = Vector2.ZERO


func _physics_process(_delta: float):
	if not is_multiplayer_authority():
		return
	if nav_agent.is_navigation_finished():
		player.velocity = Vector2.ZERO
	else:
		var next_point = nav_agent.get_next_path_position()
		var dir = (next_point - player.global_position).normalized()
		player.velocity = dir * player.speed

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		nav_agent.set_target_position(player.get_global_mouse_position())
