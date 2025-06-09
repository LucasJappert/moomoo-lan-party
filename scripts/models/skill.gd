class_name Skill

extends CombatStats

enum Type {ACTIVE, PASSIVE}

const Names = {
	SHIELDED_CORE = "Shielded Core", # ✅
	BLESSING_OF_POWER = "Blessing of Power", # ✅
	LIFESTEAL = "Lifesteal", # ✅
	MIRROR_DEMISE = "Mirror Demise", # ✅
	FROZEN_TOUCH = "Frozen Touch", # ✅
	STUNNING_STRIKE = "Stunning Strike", # ✅
	MANA_SCORCHER = "Mana Scorcher",
	DIVINE_SHIELD = "Divine Shield",
	ENERGY_ABSORPTION = "Energy Absorption",
	VOID_STEP = "Void Step",
	TOXIC_SPORES = "Toxic Spores",
	HELLFIRE_STORM = "Hellfire Storm",
	BONE_CAGE = "Bone Cage",
	FLAME_BURST = "Flame Burst",
	FROST_NOVA = "Frost Nova",
	SHADOW_STEP = "Shadow Step",
	STUNNING_BLOW = "Stunning Blow",
	MULTI_SHOT = "Multi Shot",
	FINAL_EXPLOSION = "Final Explosion",
	RAGE_BOOST = "Rage Boost",
	KAMIKAZE_CHARGE = "Kamikaze Charge",
	ARCANE_SHIELD = "Arcane Shield",
	PIERCING_ARROW = "Piercing Arrow",
	BURNING_WEAPON = "Burning Weapon",
	EVASIVE_DASH = "Evasive Dash",
	NECROTIC_PULSE = "Necrotic Pulse",
	GUARDIANS_PRESENCE = "Guardian's Presence",
	CURSE_OF_THORNS = "Curse of Thorns",
	STORMLASH_REFLEX = "Stormlash Reflex",
	STATIC_RETALIATION = "Static Retaliation",
	ECHOING_WRATH = "Echoing Wrath",
	REVERBERATING_PAIN = "Reverberating Pain",
	PHANTOM_REPRISAL = "Phantom Reprisal",
}

static var _SKILLS: Dictionary[String, Skill]
const frame_size = 64
const _ATLAS_START_POS = Vector2(0, 1632)

var type: Type = Type.ACTIVE
var cooldown: float = 0
var mana_cost: float = 0
var description: String = ""
var is_learned: bool = true
var apply_to_owner: bool = true

var region_rect: Rect2 = Rect2()

func _init(_name: String, _type: Type):
	name = _name
	type = _type

static func initialize_skills() -> void:
	var skill_name = Names.SHIELDED_CORE
	var aux_text: String
	var aux_text1: String
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(0 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].magic_defense_percent = 0.3
	_SKILLS[skill_name].physical_defense_percent = 0.3
	_SKILLS[skill_name].apply_to_owner = true
	_SKILLS[skill_name].max_stacks = 1
	aux_text = StringHelpers.format_percent(_SKILLS[skill_name].magic_defense_percent)
	_SKILLS[skill_name].description = "Reduces magic and physical defense by " + aux_text

	skill_name = Names.BLESSING_OF_POWER
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(1 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].physical_attack_power_percent = 0.25
	_SKILLS[skill_name].apply_to_owner = true
	_SKILLS[skill_name].max_stacks = 1
	aux_text = StringHelpers.format_percent(_SKILLS[skill_name].physical_attack_power_percent)
	_SKILLS[skill_name].description = "Increases physical attack power by " + aux_text

	skill_name = Names.MIRROR_DEMISE
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(2 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].description = "Upon death, splits into 4 copies with half the original HP."

	skill_name = Names.FROZEN_TOUCH
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(3 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].attack_speed_percent = -0.1
	_SKILLS[skill_name].move_speed_percent = -0.1
	_SKILLS[skill_name].freeze_duration = 4
	_SKILLS[skill_name].apply_to_owner = false
	_SKILLS[skill_name].max_stacks = 5
	aux_text = StringHelpers.format_percent(_SKILLS[skill_name].attack_speed_percent)
	aux_text1 = StringHelpers.format_float(_SKILLS[skill_name].freeze_duration)
	_SKILLS[skill_name].description = "The attacker's icy touch partially freezes the target, reducing their movement and attack speed by " + aux_text + " for " + aux_text1 + " seconds."

	skill_name = Names.STUNNING_STRIKE
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(4 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].stun_duration = 2
	_SKILLS[skill_name].stun_chance = 0.25
	_SKILLS[skill_name].apply_to_owner = false
	_SKILLS[skill_name].max_stacks = 1
	aux_text = StringHelpers.format_percent(_SKILLS[skill_name].stun_chance)
	aux_text1 = StringHelpers.format_float(_SKILLS[skill_name].stun_duration)
	_SKILLS[skill_name].description = "Has a " + aux_text + " chance to stun the target for " + aux_text1 + " seconds."

	skill_name = Names.LIFESTEAL
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].region_rect = Rect2(5 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].life_steal_percent = 0.2
	_SKILLS[skill_name].apply_to_owner = true
	aux_text = StringHelpers.format_percent(_SKILLS[skill_name].life_steal_percent)
	_SKILLS[skill_name].description = "Steals " + aux_text + " of dealt damage as life."

# region :::::::::::::::::::: GETTERs

static func get_skill(skill_name: String) -> Skill:
	if _SKILLS.is_empty(): initialize_skills()
	
	return _SKILLS[skill_name]

static func get_mana_scorcher() -> Skill:
	var skill = Skill.new(Names.MANA_SCORCHER, Skill.Type.ACTIVE)
	skill.description = "Burns 50% of the target's mana, dealing 25% of that as physical damage."
	return skill
# endregion ................. GETTERs

# region :::::::::::::::::::: SKILLS LOGICS

static func actions_before_entity_death(_dead_entity: Entity, _attacker: Entity) -> void:
	if not _dead_entity is Enemy: return
	if _dead_entity.replicated: return

	if _dead_entity.combat_data.get_skill(Names.MIRROR_DEMISE):
		var target_tiles = [
			Vector2(-MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
			Vector2(MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y),
			Vector2(-MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y)
		]
		for i in range(4):
			# var new_enemy = EnemyFactory.get_enemy_instance(_dead_entity.enemy_type)
			var new_enemy = Enemy.get_instance_from_dict(ObjectHelpers.to_dict(_dead_entity))
			new_enemy.replicated = true
			new_enemy.position = _dead_entity.position + target_tiles[i]
			# We need set combat_data props after the enemy is added to the scene
			new_enemy.combat_data.base_hp = new_enemy.combat_data.get_total_hp() * 0.5
			new_enemy.combat_data.current_hp = new_enemy.combat_data.base_hp
			GameManager.add_enemy(new_enemy)


static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	# Should be called only on the server
	# Freeze verification
	var _attacker_frozen_skill = _attacker.combat_data.get_skill(Names.FROZEN_TOUCH)
	if _attacker_frozen_skill:
		var attr = _attacker_frozen_skill.get_combat_stats_instance()
		var effect = CombatEffect.get_temporal_effect(Names.FROZEN_TOUCH, attr.freeze_duration, attr)
		effect.is_owner_friendly = false
		effect.set_region_rect(_attacker_frozen_skill.region_rect)
		_target.combat_data.add_effect(effect)
# endregion .................... SKILLS LOGICS

# Skill("Mana Scorcher", "Active", 40, 8, "Burns 50% of the target's mana, dealing 25% of that as physical damage."),
# Skill("Divine Shield", "Active", 60, 12, "Summons a divine shield making the caster immune to all damage for 5 seconds."),
# Skill("Energy Absorption", "Active", 50, 10, "Creates a shield that absorbs 25% of incoming damage and releases it in an area after 5 seconds."),
# Skill("Void Step", "Active", 20, 5, "Becomes intangible for 1 second, avoiding all physical damage."),
# Skill("Toxic Spores", "Passive", 0, 0, "Releases toxic spores when hit, poisoning nearby enemies."),
# Skill("Hellfire Storm", "Active", 60, 10, "Calls down a firestorm over an area for 3 seconds."),
# Skill("Bone Cage", "Active", 30, 6, "Traps a target in bone prison for 2 seconds."),
# Skill("Flame Burst", "Active", 25, 4, "A fiery explosion that deals area damage on impact."),
# Skill("Frost Nova", "Active", 30, 6, "Slows all nearby enemies for 3 seconds."),
# Skill("Shadow Step", "Active", 35, 7, "Teleports behind the target and lands a guaranteed critical hit."),
# Skill("Lifesteal Aura", "Passive", 0, 0, "Steals 20% of damage dealt as health."),
# Skill("Stunning Blow", "Passive", 0, 0, "Every 4th attack stuns the enemy for 1.5 seconds."),
# Skill("Multi Shot", "Passive", 0, 0, "Every 3rd attack fires 3 projectiles in a cone."),
# Skill("Final Explosion", "Passive", 0, 0, "Explodes upon death dealing magical area damage."),
# Skill("Rage Boost", "Passive", 0, 0, "Increases physical attack by 30% below 50% HP."),
# Skill("Kamikaze Charge", "Active", 50, 8, "Charges at the enemy and explodes on contact dealing area damage."),
# Skill("Arcane Shield", "Active", 40, 7, "Reduces magical damage taken by 40% for 5 seconds."),
# Skill("Piercing Arrow", "Passive", 0, 0, "Ignores 50% of the enemy's physical defense."),
# Skill("Burning Weapon", "Passive", 0, 0, "Applies a 3-second burn on hit."),
# Skill("Evasive Dash", "Passive", 0, 0, "Has a 20% chance to dodge incoming attacks."),
# Skill("Frozen Touch", "Passive", 0, 0, "20% chance to freeze the target for 1 second."),
# Skill("Necrotic Pulse", "Active", 30, 6, "Releases a dark pulse that reduces enemy attack."),
# Skill("Guardian's Presence", "Passive", 0, 0, "Grants an aura that increases allies' physical and magical defense by 10%."),
# Skill("Curse of Thorns", "Passive", 0, 0, "Enemies attacking the bearer have their attack speed reduced by 50% for 3 seconds."),
# Skill("Stormlash Reflex", "Passive", 0, 0, "10% chance on hit to fire 5 lightning bolts at different enemies."),
# Skill("Static Retaliation", "Passive", 0, 0, "10% chance on hit to unleash electricity on 3 enemies."),
# Skill("Echoing Wrath", "Passive", 0, 0, "10% chance on hit to stun all enemies within 3 tiles."),
# Skill("Reverberating Pain", "Passive", 0, 0, "Reflects 10% of total received damage to enemies within 3 tiles."),
# Skill("Phantom Reprisal", "Passive", 0, 0, "15% chance on hit to teleport to a free tile within 5 tiles and deal critical damage to adjacent enemies.")
