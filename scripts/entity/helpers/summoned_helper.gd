class_name SummonedHelper
extends Node2D

signal expired

var script_path: String
var _owner: Entity
var summoned_by_name: String
@export var lifetime_sec: float = 10.0

var _spawned_at_sec: float = 0.0
var _despawn_at_sec: float = -1.0
var _expired := false

func _init(p_owner: Entity = null, p_summoned_by_name: String = "", p_lifetime_sec: float = 10.0) -> void:
	script_path = get_script().resource_path
	_owner = p_owner
	summoned_by_name = p_summoned_by_name
	lifetime_sec = p_lifetime_sec
	name = "SummonedHelper"

func _ready() -> void:
	_spawned_at_sec = MainScene.get_elapsed_time_in_sec()
	if lifetime_sec > 0.0:
		_despawn_at_sec = _spawned_at_sec + lifetime_sec

func get_age_sec() -> float:
	var now := MainScene.get_elapsed_time_in_sec()
	return max(now - _spawned_at_sec, 0.0)

func summoned_by() -> Entity: return GameManager.get_entity(summoned_by_name)

func _process(_delta: float) -> void:
	if _despawn_at_sec < 0.0: return
	var now := MainScene.get_elapsed_time_in_sec()
	if now < _despawn_at_sec: return
	if not _expired:
		_expired = true
		_on_expire()

func _on_expire() -> void:
	emit_signal("expired")
	_owner.global_die(null, true)
	# Invocamos al global_die()
