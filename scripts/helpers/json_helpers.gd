class_name JsonHelpers

static func load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open file: %s" % path)
		return null
	
	var content := file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result == null:
		push_error("Error parsing JSON: %s" % content)
		return null
	
	return result
