class_name HeroBase

extends MyInitAuxiliary

static var REGISTERED_HEROS = [
	HeroLightningWarden,
	HeroBloodWarden,
	HeroFrostbaneArcanist,
	HeroKaelDravok
]

const _START_REGION = Vector2i(0, 320)
const _FRAME_SIZE = Vector2i(128, 128)
const _FRAMES := 2

static func initialize_from_name(_name: String, player: Player) -> void:
	var stats = CombatStats.new()

	_commons_initialize(player, stats)

	for hero_class in REGISTERED_HEROS: hero_class.try_to_init_from_name(_name, player, stats)
	
	# GlobalsEntityHelpers.print_description_skills(player)
	player.update_base_stats(stats)

static func _commons_initialize(player: Player, stats: CombatStats) -> void:
	stats.crit_chance = 0.05
	stats.crit_multiplier = 1.5
	stats.attack_speed = 0.5
	stats.move_speed = 5
	stats.agility = 50
	stats.strength = 50
	stats.intelligence = 50
	stats.attack_range = CombatStats.MIN_ATTACK_RANGE
	# region Add some potions 
	player.add_item(Item.get_item(Item.Names.HEALTH_POTION_I, 100, true))
	player.add_item(Item.get_item(Item.Names.MANA_POTION_I, 100, true))
	player.add_item(Item.get_item(Item.Names.HEALTH_POTION_III, 100, true))
	player.add_item(Item.get_item(Item.Names.MANA_POTION_III, 100, true))
	# player.add_item(Item.get_item(Item.Names.CLEAVE_EDGE, 1, false))
	# player.add_item(Item.get_item(Item.Names.STUNNING_EDGE, 1, false))

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result
