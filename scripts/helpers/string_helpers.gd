class_name StringHelpers

static func format_float(value: float) -> String:
	if value == int(value): return str(int(value))
	
	var formatted := "%.2f" % value
	return formatted.rstrip("0").rstrip(".")

static func format_percent(value: float) -> String:
	if value == 0: return "-"
	var percent := value * 100.0
	if percent == int(percent): return "%d%%" % int(percent)
	return "%.1f%%" % percent
