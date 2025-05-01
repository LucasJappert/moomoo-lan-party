extends CharacterBody2D

# Velocidad de movimiento del jugador (píxeles por segundo)
@export var speed: float = 300.0

# Dirección de movimiento actual
var direction: Vector2 = Vector2.ZERO

@export var peer_id = 0:
	set(value):
		peer_id = value
		name = str(value)
	

func _physics_process(_delta):
	# Reiniciar dirección cada frame
	direction = Vector2.ZERO

	# Leer teclas específicas
	if Input.is_key_pressed(Key.KEY_W): # Arriba
		direction.y -= 1
	if Input.is_key_pressed(Key.KEY_S): # Abajo
		direction.y += 1
	if Input.is_key_pressed(Key.KEY_A): # Izquierda
		direction.x -= 1
	if Input.is_key_pressed(Key.KEY_D): # Derecha
		direction.x += 1

	# Normalizar dirección para evitar movimiento más rápido en diagonal
	velocity = direction.normalized() * speed

	# Aplicar movimiento
	move_and_slide()
