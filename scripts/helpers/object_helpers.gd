class_name ObjectHelpers

static func is_null(object):
	return object == null or not is_instance_valid(object)

static func is_enemy(_entity) -> bool:
	if is_null(_entity): return false
	
	return _entity is Enemy

static func deep_clone(original: Object) -> Object:
	if original == null or original.get_script() == null:
		push_error("❗ deep_clone: The object is not a valid instance or has no associated script.")
		return null

	var target = original.get_script().new()

	return from_dict(target, to_dict(original))

static func to_dict(obj: Object, just_my_vars: bool = false) -> Dictionary:
	if not obj:
		return {}

	var dict := {}
	for prop in obj.get_property_list():
		var name = prop.name
		if name == "script":
			continue

		var usage = prop.usage
		var is_script_var: bool = (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0
		if just_my_vars and not is_script_var:
			continue

		var is_storage: bool = (usage & PROPERTY_USAGE_STORAGE) != 0
		var is_explicit: bool = name == "name"
		if is_storage or is_script_var or is_explicit:
			var value = obj.get(name)

			if typeof(value) == TYPE_OBJECT and value != null:
				if value is Entity: continue # Ignore entities to prevent infinite loops
				dict[name] = to_dict(value, just_my_vars) # Recursive call
				continue
			if typeof(value) == TYPE_ARRAY:
				dict[name] = array_to_dict_array(value, just_my_vars)
				continue
			dict[name] = value

	return dict

static func from_dict(obj: Object, data: Dictionary) -> Object:
	var prop_names := obj.get_property_list().map(func(p): return p.name)
	for key in data:
		if key == "script": continue
		if not key in prop_names: continue

		var value = data[key]
		if typeof(value) == TYPE_DICTIONARY:
			from_dict(obj.get(key), value)
			continue

		if typeof(value) == TYPE_ARRAY:
			for i in range(value.size()):
				from_dict(obj.get(key)[i], value[i])
			continue

		obj.set(key, data[key])

	return obj

static func array_to_dict_array(array: Array, just_my_vars: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for obj in array:
		if obj == null: continue
		result.append(to_dict(obj, just_my_vars))
	return result
