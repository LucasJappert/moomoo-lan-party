class_name Entity

extends CharacterBody2D

const CombatData = preload("res://scripts/models/combat_data.gd")

@onready var hud = $HUD
@onready var collision_shape = $CollisionShape2D
@onready var area_attack = $AreaAttack/CollisionShape2D
@export var id: int:
	set(value):
		id = value
		name = str(id)
var combat_data := CombatData.new()
var mov_speed: float = 100.0

func _ready():
	print("_ready entity")
	collision_layer = 1
	collision_mask = 1
	hud.initialize(self)

func _process(delta: float) -> void:
	hud._process(delta)

func die():
	queue_free()
