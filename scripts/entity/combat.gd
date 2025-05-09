extends Node

# Variables para la vida
@export var max_health: int = 200
@export var physical_attack_range: float = 30.0
@onready var physical_attack: Node = $PhysicalAttack
var current_health: int
var entity: Entity

var damage: int = 5


func initialize(_entity: Entity):
    entity = _entity
    if entity.entity_type == Enums.EntityType.PLAYER:
        max_health = 1000
        damage = 50
    if entity.entity_type == Enums.EntityType.MOOMOO:
        max_health = 25000

    current_health = max_health
    physical_attack.initialize(self)

func process(_delta: float):
    physical_attack.process(_delta)

func try_physical_attack(attacker: Entity):
    physical_attack.try_attack(attacker)

func take_damage(amount: int):
    entity.ui_overlay.increment_health_bar(-amount)
