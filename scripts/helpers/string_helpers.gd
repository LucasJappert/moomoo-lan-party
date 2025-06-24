class_name StringHelpers

static func format_float(value: float, max_decimals: int = 2) -> String:
	var rounded := snappedf(value, 0.1 ** max_decimals)
	var base := String.num(rounded, max_decimals) # Solo 2 args
	var parts := base.split(".")
	var int_part := parts[0]
	var dec_part := parts[1] if parts.size() > 1 else ""

	# Separador de miles
	var out := ""
	while int_part.length() > 3:
		out = "." + int_part.substr(int_part.length() - 3, 3) + out
		int_part = int_part.substr(0, int_part.length() - 3)
	out = int_part + out

	if dec_part.strip_edges() != "" and int(dec_part) != 0:
		out += "," + dec_part.rstrip("0")

	if value < 0 and rounded != 0.0:
		out = "-" + out

	return out


static func format_float_compact(value: float, max_decimals: int = 2) -> String:
	var abs_value = abs(value)
	var suffix := ""
	var divisor := 1.0

	if abs_value >= 1_000_000:
		suffix = "M"
		divisor = 1_000_000.0
	elif abs_value >= 1_000:
		suffix = "K"
		divisor = 1_000.0

	var compact_value := value / divisor
	var format_str := "%." + str(max_decimals) + "f"
	var formatted := format_str % abs(compact_value)
	formatted = formatted.rstrip("0").rstrip(".").replace(".", ",")

	if value < 0:
		formatted = "-" + formatted

	return formatted + suffix


static func format_percent(value: float, include_percent_sign: bool = true, decimals: int = 0) -> String:
	if value == 0: return "-"
	var percent := value * 100.0
	var result = "%d" % int(percent)

	if decimals: result = format_float(percent, decimals)

	if include_percent_sign: result += "%"

	return result

static func unique_id() -> String:
	var timestamp := Time.get_unix_time_from_system()
	var microsec := Time.get_ticks_usec() % 1000000
	var random_part := randi() % 100000
	return "%d-%d-%05d" % [timestamp, microsec, random_part]