class_name UniqueIdGenerator

const MAX_ID := 1_000_000_000
static var _counter: int = 0

static func get_id() -> int:
	_counter += 1
	if _counter > MAX_ID:
		_counter = 1
	return _counter
