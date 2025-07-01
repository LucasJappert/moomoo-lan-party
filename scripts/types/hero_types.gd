class_name HeroTypes

# const BLOOD_WARDEN = "Blood Warden" # (Guardián de Sangre)
# const FROSTBANE_ARCANIST = "Frostbane Arcanist" # (Arcanista de Escarcha)
# const LIORA_SUNVEIL = "Liora Sunveil"
# const THARNOK_THE_VERDANT = "Tharnok the Verdant"
const Names = {
	BLOOD_WARDEN = "Blood Warden", # (Guardián de Sangre)
	FROSTBANE_ARCANIST = "Frostbane Arcanist", # (Arcanista de Escarcha)
}
static var HERO_TYPES: Dictionary[String, ExtraInfo] = {
	Names.BLOOD_WARDEN: ExtraInfo.new(Names.BLOOD_WARDEN, get_rect_frames(Vector2i(3, 0)), "Skar"),
	Names.FROSTBANE_ARCANIST: ExtraInfo.new(Names.FROSTBANE_ARCANIST, get_rect_frames(Vector2i(2, 0)), "Zareth"),
}

const _START_REGION = Vector2i(0, 320)
const _FRAME_SIZE = Vector2i(128, 128)
const _FRAMES := 2

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + (pos.y * _FRAMES) * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + (pos.y * _FRAMES) * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result

static func initialize(player: Player) -> void:
	player.extra_info = HERO_TYPES[player.extra_info.key_type]
	var stats = CombatStats.new()
	stats.crit_chance = 0.05
	stats.crit_multiplier = 1.5
	stats.attack_speed = 0.5
	stats.move_speed = 5
	stats.agility = 50
	stats.strength = 50
	stats.intelligence = 50
	stats.attack_range = CombatStats.MIN_ATTACK_RANGE
	# region Add some potions 
	# player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.HEALTH_POTION_I), 100))
	# player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.MANA_POTION_I), 100))
	player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.HEALTH_POTION_II), 100))
	player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.MANA_POTION_II), 100))
	player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.HEALTH_POTION_III), 100))
	player.add_item(SlotItemInfo.get_consumable_slot_item(Item.get_item(Item.Names.MANA_POTION_III), 100))
	# player.add_item(SlotItemInfo.get_non_consumable_slot_item(Item.get_item(Item.Names.CLEAVE_EDGE)))
	# player.add_item(SlotItemInfo.get_non_consumable_slot_item(Item.get_item(Item.Names.STUNNING_EDGE)))


	# endregion Add some potions

	if player.extra_info.key_type == Names.BLOOD_WARDEN:
		stats.evasion = 0.1
		stats.agility = 50
		stats.strength = 500
		stats.intelligence = 50
		player._skills = [
			Skill.get_skill(Skill.Names.LIFESTEAL),
			Skill.get_skill(Skill.Names.CLEAVE_STRIKE),
			Skill.get_skill(Skill.Names.STUNNING_STRIKE),
			Skill.get_skill(Skill.Names.BLOOD_FURY),
			# Skill.get_skill(Skill.Names.TRUE_STRIKE),
			# Skill.get_skill(Skill.Names.MANA_SCORCHER),
			# Skill.get_skill(Skill.Names.STORM_STRIKE),
			# Skill.get_skill(Skill.Names.FROZEN_TOUCH)
		]
		# player._skills[0].learned_level = 2
	
	if player.extra_info.key_type == Names.FROSTBANE_ARCANIST:
		stats.attack_range = 200
		player.projectile_type = Projectile.TYPES.ARROW
		stats.agility = 50
		stats.strength = 50
		stats.intelligence = 50
		player._skills = [
			Skill.get_skill(Skill.Names.MANA_SCORCHER),
			Skill.get_skill(Skill.Names.STORM_STRIKE),
			Skill.get_skill(Skill.Names.FROZEN_TOUCH),
			Skill.get_skill(Skill.Names.MULTIPLE_STRIKE)
		]
		
	# GlobalsEntityHelpers.print_description_skills(player)
	player.update_base_stats(stats)
