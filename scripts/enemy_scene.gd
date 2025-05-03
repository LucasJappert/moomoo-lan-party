extends CharacterBody2D

func _ready():
    # No colisiona con su propia capa
    collision_layer = 1
    collision_mask = 1