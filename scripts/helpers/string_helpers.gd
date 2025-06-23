class_name StringHelpers

static func format_float(value: float, max_decimals: int = 2) -> String:
	var int_str := str(abs(int(value)))
	var formatted := ""
	while int_str.length() > 3:
		formatted = "." + int_str.substr(int_str.length() - 3, 3) + formatted
		int_str = int_str.substr(0, int_str.length() - 3)
	formatted = int_str + formatted

	var decimals := ("%." + str(max_decimals) + "f") % abs(value - int(value))
	decimals = decimals.strip_edges().substr(1).rstrip("0").rstrip(".")
	if decimals != "":
		formatted += "," + decimals

	if value < 0:
		formatted = "-" + formatted
	return formatted


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