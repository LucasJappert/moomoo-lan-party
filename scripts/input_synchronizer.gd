extends MultiplayerSynchronizer

@export var direction: Vector2 = Vector2.ZERO

func _ready():
    if get_multiplayer_authority() != multiplayer.get_unique_id():
        set_process(false)
        set_physics_process(false)
        
    direction = Vector2.ZERO


func _physics_process(_delta: float):
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
