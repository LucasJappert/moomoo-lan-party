class_name MultipleStrike

extends MyInitAuxiliary

var extra_targets: int
var hits_to_trigger: int
var current_hits: int = 0
var description: String

func _init(_extra_targets: int = 1, _hits_to_trigger: int = 1):
	super._init()
	extra_targets = _extra_targets
	hits_to_trigger = _hits_to_trigger
	description = str("- Extra targets: ", extra_targets, "\n") + str("- Hits to trigger: ", hits_to_trigger, "\n")

func increment_hits() -> bool:
	current_hits += 1
	print("Multiple strike: ", current_hits, " / ", hits_to_trigger)
	if current_hits < hits_to_trigger: return false

	current_hits = 0
	return true
