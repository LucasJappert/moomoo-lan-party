class_name HeroFrostbaneArcanist

extends HeroBase

const LONG_NAME = "Frostbane Arcanist" # (Arcanista de Escarcha)
const ALIAS = "Zareth"

static func try_to_init_from_name(_name: String, player: Player, stats: CombatStats) -> void:
	if _name != LONG_NAME: return
	
	player.extra_info = ExtraInfo.new(LONG_NAME, get_rect_frames(Vector2i(2, 0)), ALIAS)
	player.projectile_type = Projectile.TYPES.ARROW
	stats.attack_range = 200
	stats.agility = 45
	stats.strength = 38
	stats.intelligence = 40
	player._skills = [
		Skill.get_skill(Skill.Names.MANA_SCORCHER),
		Skill.get_skill(Skill.Names.FRENZIED_SILENCE),
		Skill.get_skill(Skill.Names.FROZEN_TOUCH),
		Skill.get_skill(Skill.Names.MULTIPLE_STRIKE)
	]