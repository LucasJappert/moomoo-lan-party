class_name DefensesHelper

# --- Per-point gains ---
const DEFENSE_POINTS_PER_AGI: float = 0.6
const MAGIC_DEFENSE_POINTS_PER_INT: float = 0.6

# --- Curve params ---
const ARMOR_K_PHYS: float = 100.0 # 100 AGI → 37.5%, 200 AGI → 54.5%, 400 AGI → 70.6%, 800 AGI → 82.8%, 1000 AGI → 85.7%
const ARMOR_K_MAGIC: float = 100.0
const MAX_DR: float = 0.95 # hard cap

# ===== internal =====
static func _dr_fraction_from_points(points: float, k: float, cap: float = MAX_DR) -> float:
    if points <= 0.0:
        return 0.0
    if k <= 0.0:
        return cap
    var dr: float = points / (points + k)
    if dr > cap:
        return cap
    return dr

static func defense_points_from_agility(agility: int) -> float:
    return agility * DEFENSE_POINTS_PER_AGI

static func defense_points_from_intelligence(intelligence: int) -> float:
    return intelligence * MAGIC_DEFENSE_POINTS_PER_INT

# ===== public =====
static func physical_defense_percent(agility: int, points: int) -> float:
    var pts: float = defense_points_from_agility(agility) + points
    return _dr_fraction_from_points(pts, ARMOR_K_PHYS, MAX_DR)

static func magic_defense_percent(intelligence: int, points: int) -> float:
    var pts: float = defense_points_from_intelligence(intelligence) + points
    return _dr_fraction_from_points(pts, ARMOR_K_MAGIC, MAX_DR)
