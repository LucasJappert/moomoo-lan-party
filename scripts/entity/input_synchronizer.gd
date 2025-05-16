extends MultiplayerSynchronizer

@onready var player = get_parent()

@export var right_click_mouse_pos = null

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		right_click_mouse_pos = player.get_global_mouse_position()
