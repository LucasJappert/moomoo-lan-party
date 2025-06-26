class_name MyInitAuxiliary

var script_path: String
var subscribers_to_changes: Array = []

func _init():
	# We need this property for when we want to use deep_clone (cases where the source is null but the destination from where to copy it is not)
	script_path = get_script().resource_path

func subscribe_to_changes(callback: Callable) -> void:
	if subscribers_to_changes.has(callback): return
	subscribers_to_changes.append(callback)
	
func notify_changes_to_subscribers() -> void:
	for callback in subscribers_to_changes: callback.call()
