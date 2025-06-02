class_name Skill

extends CombatAttributes

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
var is_learned: bool = false

var rect_region: Rect2 = Rect2()

static func initialize_skills() -> void:
	var skill_name = Names.SHIELDED_CORE
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(0 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].magic_defense_percent = 0.3
	_SKILLS[skill_name].physical_defense_percent = 0.3
	_SKILLS[skill_name].description = "Reduces magic and physical defense by " + str(_SKILLS[skill_name].magic_defense_percent * 100) + "%"

	skill_name = Names.BLESSING_OF_POWER
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(1 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].physical_attack_power_percent = 0.5
	_SKILLS[skill_name].description = "Increases physical attack power by " + str(_SKILLS[skill_name].physical_attack_power_percent * 100) + "%"

	skill_name = Names.MIRROR_DEMISE
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(2 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].description = "Upon death, splits into 4 copies with half the original HP."

	skill_name = Names.FROZEN_TOUCH
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(3 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].attack_speed_percent = -0.1
	_SKILLS[skill_name].move_speed_percent = -0.1
	_SKILLS[skill_name].freeze_duration = 4
	_SKILLS[skill_name].description = "The attacker's icy touch partially freezes the target, reducing their movement and attack speed by " + \
	str(abs(_SKILLS[skill_name].attack_speed_percent) * 100) + "% for " + str(_SKILLS[skill_name].freeze_duration) + " seconds."

	skill_name = Names.STUNNING_STRIKE
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(4 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].stun_duration = 2
	_SKILLS[skill_name].stun_chance = 0.25
	_SKILLS[skill_name].description = "Has a " + str(_SKILLS[skill_name].stun_chance * 100) + "% chance to stun the target for " + str(_SKILLS[skill_name].stun_duration) + " seconds."

	skill_name = Names.LIFESTEAL
	_SKILLS[skill_name] = Skill.new(skill_name, Skill.Type.PASSIVE)
	_SKILLS[skill_name].rect_region = Rect2(5 * frame_size + _ATLAS_START_POS.x, _ATLAS_START_POS.y, frame_size, frame_size)
	_SKILLS[skill_name].life_steal_percent = 0.2
	_SKILLS[skill_name].description = "Steals " + str(_SKILLS[skill_name].life_steal_percent * 100) + "% of dealt damage as life."

static func get_skill(skill_name: String) -> Skill:
	if _SKILLS.is_empty(): initialize_skills()
	
	return _SKILLS[skill_name]

func _init(_name: String, _type: Type):
	name = _name
	type = _type


static func get_mana_scorcher() -> Skill:
	var skill = Skill.new(Names.MANA_SCORCHER, Skill.Type.ACTIVE)
	skill.description = "Burns 50% of the target's mana, dealing 25% of that as physical damage."
	return skill

# region :::::::::::::::::::: SKILLS LOGICS

static func actions_before_entity_death(_dead_entity: Entity, _attacker_entity: Entity) -> void:
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
			var new_enemy = EnemyFactory.get_enemy_instance(_dead_entity.enemy_type)
			new_enemy.replicated = true
			new_enemy.position = _dead_entity.position + target_tiles[i]
			GameManager.add_enemy(new_enemy)

			# We need set combat_data props after the enemy is added to the scene
			new_enemy.combat_data.max_hp = new_enemy.combat_data.get_total_max_hp() * 0.5
			new_enemy.combat_data.current_hp = new_enemy.combat_data.max_hp

static func actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	# Should be called only on the server
	# Freeze verification
	var _attacker_frozen_skill = _attacker.combat_data.get_skill(Names.FROZEN_TOUCH)
	if _attacker_frozen_skill:
		var attr = _attacker_frozen_skill.get_combat_attributes()
		var effect = CombatEffect.get_instance(attr.freeze_duration, attr)
		_target.combat_data.add_effect(effect)
	
	# Stun verification, we need it after the evasion check
	if GlobalsEntityHelpers.roll_chance(_attacker.combat_data.get_total_stun_chance()):
		var _attacker_stun_skill = _attacker.combat_data.get_skill(Names.STUNNING_STRIKE)
		if _attacker_stun_skill:
			var attr = _attacker_stun_skill.get_combat_attributes()
			var effect = CombatEffect.get_instance(_attacker_stun_skill.stun_duration, attr)
			_target.combat_data.add_effect(effect)

	# Lifesteal verification
	if _attacker.combat_data.current_hp < _attacker.combat_data.max_hp:
		var _attacker_lifesteal_skill = _attacker.combat_data.get_skill(Names.LIFESTEAL)
		if _attacker_lifesteal_skill:
			var total_heal = int(_di.total_damage_heal * _attacker_lifesteal_skill.life_steal_percent)
			if total_heal > 0:
				var new_di = DamageInfo.get_instance()
				new_di.total_damage_heal = - total_heal
				_attacker.rpc("rpc_receive_damage_or_heal", new_di.to_dict())
				_attacker.combat_data.update_current_hp_for_damage(-total_heal)

	return

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
