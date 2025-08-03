class_name IntervalTrigger

var interval_in_seconds: float
var last_trigger_time: float = 0.0
var trigger_count: int = 0
var trigger_on_start: bool = false
var _first_check_done: bool = false

func _init(_interval_in_seconds: float, _trigger_on_start: bool = false) -> void:
	interval_in_seconds = _interval_in_seconds
	trigger_on_start = _trigger_on_start

func should_trigger(elapsed_time: float) -> bool:
	if not _first_check_done:
		_first_check_done = true
		if trigger_on_start:
			last_trigger_time = elapsed_time
			trigger_count += 1
			return true
		return false

	var time_since_last = elapsed_time - last_trigger_time
	var intervals_passed = floor(time_since_last / interval_in_seconds)

	if intervals_passed < 1: return false

	last_trigger_time += interval_in_seconds * intervals_passed
	trigger_count += int(intervals_passed)
	return true
