# TileHazardManager.gd (GDScript 4)
class_name TileHazardManager

# ---------------------------
# Manager API (estático)
# ---------------------------
static var _tile_hazards: Array[TileHazard] = []

static func add_hazard(cell: Vector2i, lifetime: float, interval_in_seconds: float, on_tick: Callable) -> TileHazard:
	var h := TileHazard.new(cell, lifetime, interval_in_seconds, on_tick)
	_tile_hazards.append(h)
	return h

static func process(delta: float) -> void:
	for h in _tile_hazards: h.process(delta)
	# compactar eliminando terminados
	_tile_hazards = _tile_hazards.filter(func(x): return not x.is_finished())

static func clear() -> void: _tile_hazards.clear()

# Helpers opcionales y livianos
static func has_hazard_at(cell: Vector2i) -> bool:
	for h in _tile_hazards:
		if h.cell_position == cell and not h.is_finished():
			return true
	return false

static func remove_hazards_at(cell: Vector2i) -> void:
	_tile_hazards = _tile_hazards.filter(func(h):
		return not (h.cell_position == cell)
	)

const _PERC_HEALTH_DAMAGE := 0.05
static func on_hazard_tick_apply_damage_to_allies_of_player(_cell: Vector2i) -> void:
	var entities_to_apply_damages := GameManager.get_entities()
	for entity in entities_to_apply_damages:
		if entity is Moomoo: continue
		if entity.is_enemy_of_player(): continue
		if entity.is_spawning or entity.is_dead(): continue
		if entity.movement_helper.current_cell != _cell: continue

		var damage := int(entity.get_full_health() * _PERC_HEALTH_DAMAGE)
		if damage < 1: continue

		var _di := DamageInfo.new(damage, DamageType.PURE, "")
		entity.server_receive_damage(_di, null)

# ---------------------------
# Data class (solo lo necesario)
# ---------------------------
class TileHazard:
	var cell_position: Vector2i
	var lifetime: float # duración total (segundos)
	var interval_in_seconds: float # periodo entre ticks (segundos)
	var on_tick: Callable # (hazard: TileHazard) -> void

	var _age: float = 0.0
	var _elapsed_interval: float = 0.0
	var _finished: bool = false

	func _init(p_cell: Vector2i, p_lifetime: float, p_interval_in_seconds: float, p_on_tick: Callable) -> void:
		cell_position = p_cell
		lifetime = max(p_lifetime, 0.01)
		interval_in_seconds = max(p_interval_in_seconds, 0.01)
		on_tick = p_on_tick
		var pos := MapManager.cell_to_world(cell_position)
		SmokeHelper.attach_sulfur_layer(GameManager.game_world.over_terrain_layer_layer_2, pos, p_lifetime)
		SmokeHelper.spawn_smoke(GameManager.game_world.over_terrain_layer_layer_2, pos, p_lifetime)

	func process(delta: float) -> void:
		if _finished: return

		_age += delta
		_elapsed_interval += delta

		# Emitir todos los ticks pendientes (soporta picos de delta)
		while _elapsed_interval >= interval_in_seconds and not _finished:
			_elapsed_interval -= interval_in_seconds
			if on_tick.is_valid():
				on_tick.call() # ← antes pasabas self

		if _age >= lifetime: _finished = true

	func is_finished() -> bool: return _finished
