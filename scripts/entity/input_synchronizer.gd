extends MultiplayerSynchronizer

@onready var player = get_parent()

@export var right_click_mouse_pos = null

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false) # 👈 ESTA LÍNEA FALTABA
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("---------------------------- INICIO _unhandled_input")
		print("RIGHT MOUSE BUTTON CLICKED. player id: " + str(player.name))
		print("multiplayer.is_server(): " + str(multiplayer.is_server()))
		print("get_multiplayer_authority: " + str(get_multiplayer_authority()))
		print("multiplayer.get_unique_id: " + str(multiplayer.get_unique_id()))
		print("---------------------------- FIN _unhandled_input")

	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		print("asd RIGHT MOUSE BUTTON CLICKED. player id: " + str(player.name))
		right_click_mouse_pos = player.get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	pass
