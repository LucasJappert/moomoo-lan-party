class_name ServerMessage

var message: String
var color: Vector3

func to_dict() -> Dictionary:
	return {
		"message": message,
		"color": color
	}

func from_dict(data: Dictionary) -> void:
	message = data.get("message", "")
	color = data.get("color", Vector3(1, 1, 1))

static func get_instance() -> ServerMessage:
	var server_message = ServerMessage.new()
	return server_message