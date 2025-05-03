class_name Player

extends CharacterBody2D

@export var speed: float = 300.0

@export var direction: Vector2 = Vector2.ZERO

@export var peer_id := 1:
	set(id):
		peer_id = id
		name = str(id)
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	collision_layer = 1
	collision_mask = 1

	$HUD/Label.text = str(peer_id)
	
func _process(_delta):
	$HUD/Label.text = "ID: " + str(peer_id)

func _physics_process(_delta):
	_try_apply_movement_from_input(_delta)

func _try_apply_movement_from_input(delta):
	if not multiplayer.is_server():
		return

	direction = %InputSynchronizer.direction

	velocity = direction.normalized() * speed

	# # 🔍 First, we check if we can move WITHOUT physically affecting others
	# var motion = velocity * delta
	# if test_move(get_transform(), motion):
	# 	# There is a collision → WE DO NOT move
	# 	return

	move_and_slide()
