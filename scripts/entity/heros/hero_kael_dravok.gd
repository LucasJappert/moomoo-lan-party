class_name HeroKaelDravok

extends HeroBase

const LONG_NAME = "Kael Dravok" # (Kael del Juramento de Guerra)
const ALIAS = "Kael"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return
	
	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(0, 0)), ALIAS)
	stats.evasion = 0.1
	stats.agility = 40
	stats.strength = 50
	stats.intelligence = 30
	player._skills = [
		Skill.get_skill(Skill.Names.FRENZIED_SILENCE),
		Skill.get_skill(Skill.Names.EARTHSHATTER),
		Skill.get_skill(Skill.Names.ABSORB_AND_RELEASE),
		Skill.get_skill(Skill.Names.UNBREAKABLE),
	]