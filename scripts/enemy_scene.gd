class_name Enemy

extends CharacterBody2D

static var enemy_scene = preload("res://scenes/enemy_scene.tscn")
var speed: float = 50
var is_movement_paused := false
var movement_pause_timer: Timer

@export var id: int:
    set(id):
        id = id
        name = str(id)
        set_multiplayer_authority(1)

func _ready():
    collision_layer = 1
    collision_mask = 1

    movement_pause_timer = Timer.new()
    movement_pause_timer.one_shot = true
    movement_pause_timer.wait_time = 2.0
    add_child(movement_pause_timer)
    movement_pause_timer.timeout.connect(_on_movement_pause_timer_timeout)

func _process(_delta):
    if not is_multiplayer_authority():
        return

    if is_movement_paused:
        velocity = Vector2.ZERO
        return move_and_slide()

    var direction_to_center = (GameManager.moomoo.position - position).normalized()

    velocity = direction_to_center * speed

    move_and_slide()
    
    if get_slide_collision_count() > 0 and movement_pause_timer.is_stopped():
        is_movement_paused = true
        print("MOVEMENT PAUSED")
        movement_pause_timer.start()

func _on_movement_pause_timer_timeout():
    is_movement_paused = false


static func spawn_enemy(moomoo_position = Vector2.ZERO):
    var TILES_DISTANCE = 10
    var ENEMIES_BY_ZONE = 4

    var counter = 0
    for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
        for i in range(ENEMIES_BY_ZONE):
            counter += 1
            var enemy = enemy_scene.instantiate()
            enemy.id = counter
            var random_noise = Vector2(randi_range(-64, 64), randi_range(-64, 64))
            enemy.position = moomoo_position + direction * TILES_DISTANCE * 64 + random_noise
            GameManager.enemies_node.add_child(enemy)
