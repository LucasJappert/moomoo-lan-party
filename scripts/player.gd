extends CharacterBody2D

# Velocidad de movimiento del jugador (píxeles por segundo)
@export var speed: float = 300.0

# Dirección de movimiento actual
@export var direction: Vector2 = Vector2.ZERO

@export var peer_id := 1:
	set(id):
		peer_id = id
		name = str(id)
		%InputSynchronizer.set_multiplayer_authority(id)

func _ready():
	# No colisiona con su propia capa
	collision_layer = 1
	collision_mask = 2 # solo colisiona con obstáculos/enemigos, no con otros jugadores
	if multiplayer.get_unique_id() == peer_id:
		$Camera2D.enabled = true
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false
	

func _physics_process(_delta):
	_try_apply_movement_from_input(_delta)

func _try_apply_movement_from_input(_delta):
	if not multiplayer.is_server(): return

	direction = %InputSynchronizer.direction

	# Normalizar dirección para evitar movimiento más rápido en diagonal
	velocity = direction.normalized() * speed

	# Aplicar movimiento
	move_and_slide()
