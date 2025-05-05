class_name Moomoo

extends StaticBody2D

@onready var collision_shape = $CollisionShape2D

func _ready():
	collision_layer = 1
	collision_mask = 1
