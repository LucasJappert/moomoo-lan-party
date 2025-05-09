class_name Player

extends CharacterBody2D

@export var speed: float = 200.0
@onready var collision_shape = $CollisionShape2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var direction: Vector2 = Vector2.ZERO
var target_position = null

@export var peer_id := 1:
	set(id):
		peer_id = id
		name = str(id)
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	collision_layer = 1
	collision_mask = 1

	if peer_id == multiplayer.get_unique_id():
		MyCamera.create_camera(self)
	
func _process(_delta):
	$HUD/Label.text = "peer_id: " + str(peer_id) + "\nAuthority: " + str(is_multiplayer_authority()) + "\ntarget_position: " + str(target_position)

func _physics_process(_delta):
	_try_apply_movement_from_input(_delta)

func _try_apply_movement_from_input(_delta):
	if not multiplayer.is_server():
		return

	if target_position != %InputSynchronizer.target_position:
		print("Target position changed: " + str(target_position))
		target_position = %InputSynchronizer.target_position
		nav_agent.set_target_position(target_position)

	if nav_agent.is_navigation_finished():
		return

	var next_point = nav_agent.get_next_path_position()
	direction = (next_point - global_position).normalized()
	velocity = direction * speed

	move_and_slide()
