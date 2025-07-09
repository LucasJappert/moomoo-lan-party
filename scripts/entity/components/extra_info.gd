class_name ExtraInfo

extends MyInitAuxiliary

var key_type: String
var rects: Array[Rect2] = []
var alias: String
var description_en: String
var description_es: String

func _init(_key_type: String = "", _rects: Array[Rect2] = [], _alias: String = ""):
	super._init()
	key_type = _key_type
	rects = _rects
	alias = _alias

func get_name_and_alias() -> String:
	return key_type + " (" + alias + ")"