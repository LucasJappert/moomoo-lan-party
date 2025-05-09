class_name Entity

extends CharacterBody2D

@onready var hud = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack/CollisionShape2D
@export var id: int:
	set(value):
		id = value
		print("ID: " + str(id))
		name = str(id)

func _ready():
	print("_ready entity")
	collision_layer = 1
	collision_mask = 1
	hud.initialize(self)

func _process(delta: float) -> void:
	hud._process(delta)
