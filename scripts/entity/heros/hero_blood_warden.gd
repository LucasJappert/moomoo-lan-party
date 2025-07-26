class_name HeroBloodWarden

extends HeroBase

const LONG_NAME = "Blood Warden" # (Guardián de Sangre)
const ALIAS = "Skar"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return
	
	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(3, 0)), ALIAS)
	stats.set_evasion(0.1)
	stats.set_agility(50)
	stats.set_strength(40)
	stats.set_intelligence(35)
	player._skills = [
		# SkillBase.get_skill(SkillTrueStrike.NAME),
		SkillBase.get_skill(SkillLifesteal.NAME),
		SkillBase.get_skill(SkillCleaveStrike.NAME),
		SkillBase.get_skill(SkillStunningStrike.NAME),
		SkillBase.get_skill(SkillBloodFury.NAME),
	]