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
		if name == "script":
			continue

		var usage = prop.usage
		var is_script_var = (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0
		var is_explicit = FUNDAMENTAL_PROPERTIES.has(name)

		if just_my_vars and not is_script_var: continue
		if not (is_script_var or is_explicit):
			continue

		var value = obj.get(name)

		match typeof(value):
			TYPE_OBJECT:
				if value == null or value is Entity:
					continue
				dict[name] = to_dict(value, just_my_vars)
			TYPE_ARRAY:
				dict[name] = array_to_dict_array(value, just_my_vars)
			_:
				dict[name] = value

	return dict

static func from_dict(obj: Object, data: Dictionary) -> Object:
	if obj == null: return obj

	var prop_names := obj.get_property_list().map(func(p): return p.name)

	for key in data.keys():
		if key == "script" or not prop_names.has(key):
			continue

		var value = data[key]

		match typeof(value):
			TYPE_DICTIONARY:
				var sub_obj = obj.get(key)
				if sub_obj != null:
					from_dict(sub_obj, value)
			TYPE_ARRAY:
				from_dict_array(obj, key, value)
			_:
				if key == "name" and not value: continue
				obj.set(key, value)

	return obj

static func from_dict_array(obj: Object, key: String, value: Array) -> void:
	if not obj.has_method("get") or not obj.has_method("set"):
		return

	var target_array = obj.get(key)
	if typeof(target_array) != TYPE_ARRAY:
		target_array = []

	# Crear instancias faltantes
	if target_array.size() < value.size():
		var expected_script = _resolve_script_for_array(value)
		if expected_script == null:
			# Shold never happen
			push_error("❗ No se pudo determinar el script para instanciar elementos del array '" + key + "'")
			return
		target_array.clear()
		for i in range(value.size()):
			target_array.append(expected_script.new())

	for i in range(value.size()):
		if i < target_array.size() and typeof(value[i]) == TYPE_DICTIONARY:
			from_dict(target_array[i], value[i])

	obj.set(key, target_array)

static func _resolve_script_for_array(value: Array) -> Script:
	if value.is_empty(): return null
	if typeof(value[0]) != TYPE_DICTIONARY: return null

	if value[0].has("script"):
		var path = value[0]["script"]
		if typeof(path) == TYPE_STRING: return load(path)

	if value[0].has("script_path"):
		var path = value[0]["script_path"]
		if typeof(path) == TYPE_STRING: return load(path)

	return null

static func array_to_dict_array(array: Array, just_my_vars: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for obj in array:
		if obj == null:
			continue
		if typeof(obj) == TYPE_DICTIONARY:
			result.append(obj)
		elif typeof(obj) == TYPE_OBJECT:
			result.append(to_dict(obj, just_my_vars))
	return result
