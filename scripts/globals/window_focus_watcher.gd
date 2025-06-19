class_name WindowFocusWatcher

static var _last_focused := true

static func _process(_delta: float) -> void:
	var current_focus = DisplayServer.window_is_focused()

	if current_focus == _last_focused: return

	_last_focused = current_focus
	if current_focus: return EventBus.emit_window_focused()
	EventBus.emit_window_unfocused()
