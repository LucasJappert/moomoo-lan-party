class_name HeroBase

static var REGISTERED_CLASSES = [
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
	player.id = UniqueIdGenerator.get_id()

	_commons_initialize(player, stats)

	for hero_class in REGISTERED_CLASSES: hero_class.try_to_init_from_name(_name, player, stats)
	
	# GlobalsEntityHelpers.print_description_skills(player)
	player.update_base_stats(stats.get_info())

static func _commons_initialize(player: Player, stats: CombatStats) -> void:
	stats.set_hp(100000)
	stats.set_crit_chance(0.05)
	stats.set_crit_multiplier(1.5)
	stats.set_attack_speed(0.5)
	stats.set_move_speed(5)
	stats.set_agility(50)
	stats.set_strength(50)
	stats.set_intelligence(50)
	stats.set_attack_range(CombatStats.MIN_ATTACK_RANGE)
	# region Add some potions 
	player.add_item(Item.get_item(Item.Names.HEALTH_POTION_I, 20, true))
	player.add_item(Item.get_item(Item.Names.MANA_POTION_I, 20, true))
	player.add_item(Item.get_item(ItemSkeletonSummonersRing.NAME, 1, true))
	player.add_item(Item.get_item(ItemMultiShot.NAME, 1, true))
	player.add_item(Item.get_item(ItemTrinityBoost.NAME, 1, true))
	player.add_item(Item.get_item(ItemTrinityBoost.NAME, 1, true))


static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result
