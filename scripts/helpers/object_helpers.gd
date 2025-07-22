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
		var is_valid = (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0 or FUNDAMENTAL_PROPERTIES.has(name)
		if just_my_vars and (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		if not is_valid:
			continue

		var value = obj.get(name)
		match typeof(value):
			TYPE_OBJECT:
				if value != null and not (value is Entity): # evitamos recursividad infinita
					dict[name] = to_dict(value, just_my_vars)
				else:
					dict[name] = value
			TYPE_ARRAY:
				dict[name] = array_to_dict_array(value, just_my_vars)
			_:
				dict[name] = _serialize_variant(value)
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
									# Intentar detectar si es una variante serializada o un objeto complejo
				if value.has("_type"):
					original_obj.set(key, _deserialize_variant(value))
					continue

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
				
				# Si es un diccionario simple (por ejemplo Dictionary<String, float>), setear directamente
				var is_simple_dict := true
				for v in value.values():
					if typeof(v) == TYPE_DICTIONARY or typeof(v) == TYPE_OBJECT:
						is_simple_dict = false
						break
				if is_simple_dict:
					original_obj.set(key, value)
					continue

				print("❗ No se pudo determinar el script para '" + key + "'")
			TYPE_ARRAY:
				_from_dict_array(original_obj, key, value)
			_:
				original_obj.set(key, _deserialize_variant(value))

	return original_obj


static func _from_dict_array(obj: Object, key: String, value: Array) -> void:
	if not obj.has_method("get") or not obj.has_method("set"):
		return

	var target_array = obj.get(key)
	if typeof(target_array) != TYPE_ARRAY:
		target_array = []

	# Comprobamos si el array son tipos serializados simples (Rect2, etc.)
	if not value.is_empty() and typeof(value[0]) == TYPE_DICTIONARY and value[0].has("_type"):
		target_array.clear()
		for i in value.size():
			target_array.append(_deserialize_variant(value[i]))
		obj.set(key, target_array)
		return

	# Caso normal de array de objetos complejos
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
			TYPE_RECT2, TYPE_VECTOR2:
				result.append(_serialize_variant(item))
			TYPE_NIL:
				result.append({})
			_:
				continue
				# push_warning("array_to_dict_array: unsupported type: %s" % typeof(item))
	return result

static func _serialize_variant(value: Variant) -> Variant:
	match typeof(value):
		TYPE_RECT2:
			return {
				"_type": "Rect2",
				"position": value.position,
				"size": value.size
			}
		TYPE_VECTOR2:
			return {
				"_type": "Vector2",
				"x": value.x,
				"y": value.y
			}
		_:
			return value

static func _deserialize_variant(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY and value.has("_type"):
		match value["_type"]:
			"Rect2":
				return Rect2(value.get("position", Vector2.ZERO), value.get("size", Vector2.ZERO))
			"Vector2":
				return Vector2(value.get("x", 0), value.get("y", 0))
	return value

static func valid_instance(object) -> bool:
	if is_null(object): return false
	return true

static func get_safe_instance(object) -> Object:
	if is_null(object): return null
	return object

static func get_snapped_8_direction(dir: Vector2) -> Vector2:
	if dir == Vector2.ZERO:
		return Vector2.ZERO

	var angle_rad := atan2(dir.y, dir.x)
	var angle_deg := rad_to_deg(angle_rad)
	if angle_deg < 0:
		angle_deg += 360.0

	var octant := int(floor((angle_deg + 22.5) / 45.0)) % 8

	match octant:
		0: return Vector2(1, 0) # →
		1: return Vector2(1, 1) # ↘
		2: return Vector2(0, 1) # ↓
		3: return Vector2(-1, 1) # ↙
		4: return Vector2(-1, 0) # ←
		5: return Vector2(-1, -1) # ↖
		6: return Vector2(0, -1) # ↑
		7: return Vector2(1, -1) # ↗
		_: return Vector2.ZERO
