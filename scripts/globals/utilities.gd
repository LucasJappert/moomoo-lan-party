class_name Utilities


static func get_random_sample(full_array: Array, percent: float) -> Array:
	var total := full_array.size()
	var sample_size := int(ceil(total * percent))
	
	var shuffled := full_array.duplicate()
	shuffled.shuffle()

	return shuffled.slice(0, sample_size)