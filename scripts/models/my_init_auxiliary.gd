class_name MyInitAuxiliary

var script_path: String

func _init():
	# We need this property for when we want to use deep_clone (cases where the source is null but the destination from where to copy it is not)
	script_path = get_script().resource_path
