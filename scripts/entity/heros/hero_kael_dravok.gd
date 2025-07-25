class_name HeroKaelDravok

extends HeroBase

const LONG_NAME = "Kael Dravok" # (Kael del Juramento de Guerra)
const ALIAS = "Kael"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return
	
	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(0, 0)), ALIAS)
	stats.set_evasion(0.1)
	stats.set_agility(40)
	stats.set_strength(50)
	stats.set_intelligence(30)
	player._skills = [
		SkillBase.get_skill(SkillBlessingOfPower.NAME),
		SkillBase.get_skill(SkillEarthshatter.NAME),
		SkillBase.get_skill(SkillAbsorbAndRelease.NAME),
		SkillBase.get_skill(SkillUnbreakable.NAME),
	]