class_name HeroLightningWarden

extends HeroBase

const LONG_NAME = "Lightning Warden" # (Guardián del Rayo)
const ALIAS = "Voltrix"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return

	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(2, 1)), ALIAS)
	
	player.projectile_type = ProjectileArcLightning.NAME
	stats.set_attack_range(250)
	stats.set_agility(35)
	stats.set_strength(30)
	stats.set_intelligence(70)
	player._skills = [
		SkillBase.get_skill(SkillShockSpear.NAME),
		SkillBase.get_skill(SkillArcLightningStorm.NAME),
		SkillBase.get_skill(SkillStaticDischarge.NAME),
		SkillBase.get_skill(SkillStormWrath.NAME),
	]