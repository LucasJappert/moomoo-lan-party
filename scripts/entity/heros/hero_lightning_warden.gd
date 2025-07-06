class_name HeroLightningWarden

extends HeroBase

const LONG_NAME = "Lightning Warden" # (Guardián del Rayo)
const ALIAS = "Voltrix"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return

	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(2, 1)), ALIAS)
	
	player.projectile_type = Projectile.TYPES.FIREBALL
	stats.attack_range = 220
	stats.agility = 35
	stats.strength = 30
	stats.intelligence = 70
	player._skills = [
		Skill.get_skill(Skill.Names.SHOCK_SPEAR),
		Skill.get_skill(Skill.Names.ARC_LIGHTNING_STORM),
		Skill.get_skill(Skill.Names.STATIC_DISCHARGE),
		# Skill.get_skill(Skill.Names.UNBREAKABLE),
	]