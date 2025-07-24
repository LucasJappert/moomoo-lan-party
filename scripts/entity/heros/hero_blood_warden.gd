class_name HeroBloodWarden

extends HeroBase

const LONG_NAME = "Blood Warden" # (Guardián de Sangre)
const ALIAS = "Skar"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return
	
	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(3, 0)), ALIAS)
	stats.evasion = 0.1
	stats.agility = 50
	stats.strength = 40
	stats.intelligence = 35
	player._skills = [
		Skill.get_skill(SkillLifesteal.NAME),
		Skill.get_skill(SkillCleaveStrike.NAME),
		Skill.get_skill(SkillStunningStrike.NAME),
		Skill.get_skill(SkillBloodFury.NAME),
	]