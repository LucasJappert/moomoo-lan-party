class_name Skill

enum Type {ACTIVE, PASSIVE}

var name: String = ""
var type: Type = Type.ACTIVE
var cooldown: float = 0
var mana_cost: float = 0
var description: String = ""

func _init(_name: String, _type: Type, _cooldown: float, _mana_cost: float, _description: String):
	name = _name
	type = _type
	cooldown = _cooldown
	mana_cost = _mana_cost
	description = _description

static func get_stun_charge() -> Skill:
	return new(SkillNames.STUN_CHARGE, Type.ACTIVE, 5, 0, "Charges at the target, stunning it for 1 second.")

static func get_fireball() -> Skill:
	return new(SkillNames.FIREBALL, Type.ACTIVE, 4, 20, "Casts a fireball that deals area magic damage.")

static func get_frost_slam() -> Skill:
	return new(SkillNames.FROST_SLAM, Type.ACTIVE, 6, 0, "Slams the ground and slows nearby enemies.")

static func get_drain_life() -> Skill:
	return new(SkillNames.DRAIN_LIFE, Type.ACTIVE, 8, 25, "Drains life from the target and heals the caster.")

static func get_phase_shift() -> Skill:
	return new(SkillNames.PHASE_SHIFT, Type.PASSIVE, 10, 0, "Ignores the first incoming attack every 10 seconds.")

static func get_self_destruct() -> Skill:
	return new(SkillNames.SELF_DESTRUCT, Type.ACTIVE, 0, 0, "Ignores the first incoming attack every 10 seconds.")
