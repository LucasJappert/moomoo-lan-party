class_name StringHelpers

static func format_float(value: float, max_decimals: int = 2) -> String:
	if value == int(value):
		return str(int(value))
	
	var format_string := "%." + str(max_decimals) + "f"
	var formatted := format_string % value
	return formatted.rstrip("0").rstrip(".")


static func format_percent(value: float) -> String:
	if value == 0: return "-"
	var percent := value * 100.0
	if percent == int(percent): return "%d%%" % int(percent)
	return "%.1f%%" % percent

static func unique_id() -> String:
	var timestamp := Time.get_unix_time_from_system()
	var microsec := Time.get_ticks_usec() % 1000000
	var random_part := randi() % 100000
	return "%d-%d-%05d" % [timestamp, microsec, random_part]