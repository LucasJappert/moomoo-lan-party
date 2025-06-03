class_name DamagePopupPool

extends Node

const DAMAGE_POPUP_SCENE = preload("res://scenes/general_objects/damage_popup.tscn")

const MAX_POPUPS := 20
static var _pool: Array[DamagePopup] = []

static func preload_popups():
	for i in MAX_POPUPS:
		var popup := DAMAGE_POPUP_SCENE.instantiate()
		_pool.append(popup)

static func get_popup():
	if _pool.is_empty():
		print("No more popups")
		return
		# return DAMAGE_POPUP_SCENE.instantiate()

	return _pool.pop_back()

static func recycle(popup: DamagePopup):
	_pool.append(popup)
