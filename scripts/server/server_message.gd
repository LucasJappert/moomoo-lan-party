class_name ServerMessage

var message: String
var color: Vector3

func _init(_message: String = "", _color: Vector3 = Vector3.ZERO) -> void:
	message = _message
	color = _color

func get_color() -> Color:
	return Color(color.x, color.y, color.z)