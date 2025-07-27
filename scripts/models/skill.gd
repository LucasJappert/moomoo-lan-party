class_name Skill

extends MyInitAuxiliary

const Names = {
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

var item_skill_base: Array[ItemSkillBase] = []
var learned_level: int = 0

var region_rect: Rect2 = Rect2()
var skill_name: String = ""

func _init(_name: String = "", _type: String = SkillType.ACTIVE):
	super._init()
	item_skill_base = []
	for i in range(SkillBase.AVAILABLE_LEVELS):
		item_skill_base.append(ItemSkillBase.new())
		item_skill_base[i].my_name = _name
		item_skill_base[i].type = _type
	skill_name = _name


# region :::::::::::::::::::: GETTERs
	
func get_name() -> String:
	if item_skill_base.size() == 0: return ""
	return item_skill_base[0].my_name

func get_learned_skill() -> ItemSkillBase:
	if not learned_level: return null
	return item_skill_base[learned_level - 1]

func get_safe_learned_skill() -> ItemSkillBase:
	if not learned_level: return item_skill_base[0]

	return get_learned_skill()

func get_description(include_stats_description: bool = true) -> String:
	var result = ""

	var tag_color_1 = "[color=#D3C5AC]"; var tag_color_2 = "[color=#605A4F]";
	for index in range(item_skill_base.size()):
		if index > 0: result += "\n"
		var color = tag_color_1 if index + 1 == learned_level else tag_color_2
		result += color + "⚔ [u][b]Level " + str(index + 1) + ":[/b][/u] " + item_skill_base[index].get_description(include_stats_description) + "[/color]"

	return result

func can_use(my_owner: Entity) -> bool:
	if not learned_level: return false
	if my_owner.is_silenced: return false

	return item_skill_base[learned_level - 1].can_use(my_owner)

func get_remaining_cooldown() -> float:
	if not learned_level: return 0
	return get_learned_skill().get_remaining_cooldown()
# endregion ................. GETTERs


# region :::::::::::::::::::: SETTERs

func use(my_owner: Entity, target_entity: Entity) -> bool:
	var learned_skill := get_learned_skill()
	if not learned_skill: return false

	if not can_use(my_owner):
		print("Cannot use skill: ", learned_skill)
		return false

	# New way to use skills
	var was_used := false
	for skill_class in SkillBase.REGISTERED_SKILLS:
		was_used = skill_class.try_to_use(my_owner, learned_skill, target_entity)
		if was_used: break

	if not was_used: return false

	# for skill_class in SkillBase.REGISTERED_SKILLS:
	# 	skill_class.actions_before_cast_skill(my_owner, learned_skill)

	learned_skill.reset_last_used_time()

	my_owner.update_current_mana(-learned_skill.mana_cost)

	return my_owner.uncharge_skill()

func try_to_upgrade(my_owner: Entity, p_slot_number: int) -> void:
	if learned_level >= SkillBase.AVAILABLE_LEVELS: return

	# Keep the last used time
	item_skill_base[learned_level].set_last_used_time(item_skill_base[learned_level - 1].get_last_used_time())

	learned_level += 1
	my_owner.increment_skill_points_to_assign(-1)

	EventBus.emit_skill_upgraded(my_owner, self, p_slot_number)

	for registered_class in SkillBase.REGISTERED_SKILLS:
		registered_class.actions_after_skill_updated(my_owner, self)

# endregion ................. SETTERs


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
