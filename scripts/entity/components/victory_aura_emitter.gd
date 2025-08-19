# VictoryAuraEmitter.gd (versión por tasa)
class_name VictoryAuraEmitter
extends RefCounted

var active: bool = false

# --- Config mínima (todo interno) ---
const AURAS_PER_SECOND := 8.0 # ← 4 por segundo
const AURA_DURATION := 4.0 # ← cada aura dura 2s
const RADIUS := MapManager.TILE_SIZE_INT * 3
const INTENSITY_MIN := 0.4
const INTENSITY_MAX := 0.6

var _center_provider: Callable
var _budget: float = 0.0

func _init(center_provider: Callable) -> void:
	_center_provider = center_provider

func process(delta: float) -> void:
	# Auto-encendido/apagado según el estado de victoria
	if not GameManager.PLAYER_WIN:
		active = false
		return
	if not active:
		active = true
		_budget = 0.0

	# Acumulador por tasa
	_budget += AURAS_PER_SECOND * max(delta, 0.0)

	# Emite la parte entera (puede ser >1 si hubo hipo de FPS)
	var to_emit := int(_budget)
	if to_emit <= 0: return
	_budget -= float(to_emit)

	if not _center_provider.is_valid(): return

	var center: Vector2 = _center_provider.call()

	for i in to_emit:
		var angle := randf() * TAU
		var dist := randf() * RADIUS
		var pos := center + Vector2(cos(angle), sin(angle)) * dist
		var intensity := randf_range(INTENSITY_MIN, INTENSITY_MAX)
		SmokeHelper.attach_victory_aura(GameManager.game_world.over_terrain_layer_layer_2, pos, AURA_DURATION, intensity)
