class_name ObjectHelpers

static func is_null(object):
	return object == null or not is_instance_valid(object)

static func is_enemy(_entity) -> bool:
	if is_null(_entity): return false
	
	return _entity is Enemy

static func is_my_player(_entity) -> bool:
	if is_null(_entity): return false
	
	return _entity is Player and _entity.is_my_player()

const FUNDAMENTAL_PROPERTIES := ["position", "global_position", "rotation", "scale", "name"]

static func deep_clone(original: Object) -> Object:
	if original == null or original.get_script() == null:
		push_error("❗ deep_clone: Invalid object or missing script.")
		return null

	var new_instance = original.get_script().new()
	var data := to_dict(original)
	return from_dict(new_instance, data)

static func to_dict(obj: Object, just_my_vars: bool = false) -> Dictionary:
	if obj == null:
		return {}

	var dict := {}
	for prop in obj.get_property_list():
		var name = prop.name
		if name == "script": continue

		var usage = prop.usage
		var is_valid = (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0 or FUNDAMENTAL_PROPERTIES.has(name)
		if just_my_vars and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0: continue
		if not is_valid: continue

		var value = obj.get(name)
		match typeof(value):
			TYPE_OBJECT:
				if value != null and not (value is Entity):
					dict[name] = to_dict(value, just_my_vars)
			TYPE_ARRAY:
				dict[name] = array_to_dict_array(value, just_my_vars)
			_:
				dict[name] = value
	return dict

static func from_dict(original_obj: Object, data: Dictionary) -> Object:
	if original_obj == null:
		return original_obj

	var prop_names := original_obj.get_property_list().map(func(p): return p.name)

	for key in data:
		if key == "script" or not prop_names.has(key):
			continue

		var value = data[key]
		match typeof(value):
			TYPE_DICTIONARY:
				var sub_obj = original_obj.get(key)
				if sub_obj:
					from_dict(sub_obj, value)
					continue

				var script := _get_expected_script(value)
				if script:
					sub_obj = script.new()
					from_dict(sub_obj, value)
					original_obj.set(key, sub_obj)
					continue

				print("❗ No se pudo determinar el script para '" + key + "'")
			TYPE_ARRAY:
				from_dict_array(original_obj, key, value)
			_:
				if key != "name" or value:
					original_obj.set(key, value)

	return original_obj

static func from_dict_array(obj: Object, key: String, value: Array) -> void:
	if not obj.has_method("get") or not obj.has_method("set"):
		return

	var target_array = obj.get(key)
	if typeof(target_array) != TYPE_ARRAY:
		target_array = []

	if target_array.size() < value.size():
		var script := _resolve_script_for_array(value)
		if script == null:
			return push_error("❗ No se pudo determinar el script del array '" + key + "'")
		target_array.clear()
		for _x in value.size():
			target_array.append(script.new())

	for i in range(value.size()):
		if i < target_array.size() and typeof(value[i]) == TYPE_DICTIONARY:
			from_dict(target_array[i], value[i])

	obj.set(key, target_array)

static func _resolve_script_for_array(value: Array) -> Script:
	return _get_expected_script(value[0]) if not value.is_empty() and typeof(value[0]) == TYPE_DICTIONARY else null

static func _get_expected_script(data: Dictionary) -> Script:
	for key in ["script", "script_path"]:
		if data.has(key) and typeof(data[key]) == TYPE_STRING:
			return load(data[key])
	return null

static func array_to_dict_array(array: Array, just_my_vars: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in array:
		match typeof(item):
			TYPE_DICTIONARY:
				result.append(item)
			TYPE_OBJECT:
				result.append(to_dict(item, just_my_vars))
	return result
