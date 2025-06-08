class_name ObjectHelpers

static func is_null(object):
	return object == null or not is_instance_valid(object)

static func is_enemy(_entity) -> bool:
	if is_null(_entity): return false
	
	return _entity is Enemy

static func deep_clone(source: Object) -> Object:
	if source == null or source.get_script() == null:
		push_error("❗ deep_clone: The object is not a valid instance or has no associated script.")
		return null

	var target = source.get_script().new()
	var props = source.get_property_list()

	for prop in props:
		var name = prop.name
		if name == "script":
			print("❗Cannot clone the 'script' property")
			continue

		if prop.has("name") and prop.has("usage"):
			var usage = prop.usage

			if usage & PROPERTY_USAGE_STORAGE != 0 or usage & PROPERTY_USAGE_SCRIPT_VARIABLE != 0: # We only clone script variables (my properties) and godot properties like name
				if name != "script" and target.has_method("set"):
					# print("Cloning property: ", name, " usage: ", usage)
					var value = source.get(name)
					target.set(name, _clone_value(value))

	return target

static func _clone_value(value):
	match typeof(value):
		TYPE_OBJECT:
			if value != null and value.has_method("get_script"):
				return deep_clone(value)
			else:
				return value
		TYPE_DICTIONARY:
			var clone = {}
			for k in value:
				clone[k] = _clone_value(value[k])
			return clone
		TYPE_ARRAY:
			var clone = []
			for v in value:
				clone.append(_clone_value(v))
			return clone
		_:
			return value