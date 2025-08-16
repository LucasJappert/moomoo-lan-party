class_name ItemSkeletonSummonersRing
extends Item

const NAME = "Skeleton Summoner's Ring"
const ICON_SLOT = Vector2(8, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].float_dict["chance"] = 0.1
	_ITEMS[NAME].float_dict["max_summons"] = 10
	_ITEMS[NAME].float_dict["summons_duration_in_seconds"] = 40
	_ITEMS[NAME].cooldown = 2
	_ITEMS[NAME].buy_price = 4800
	_ITEMS[NAME].en_description = "Each physical attack has a " + StringHelpers.format_percent(_ITEMS[NAME].float_dict["chance"]) + " chance to summon a Skeleton Blade and a Skeleton Bow for " + StringHelpers.format_float(_ITEMS[NAME].float_dict["summons_duration_in_seconds"]) + " seconds (up to " + StringHelpers.format_float(_ITEMS[NAME].float_dict["max_summons"]) + " skeletons)."
	_ITEMS[NAME].es_description = "Cada ataque fisico tiene una probabilidad del " + StringHelpers.format_percent(_ITEMS[NAME].float_dict["chance"]) + " de invocar un esqueleto de espada y un esqueleto de arco por " + StringHelpers.format_float(_ITEMS[NAME].float_dict["summons_duration_in_seconds"]) + " segundos (hasta " + StringHelpers.format_float(_ITEMS[NAME].float_dict["max_summons"]) + " esqueletos)."

static func static_actions_after_execute_physical_attack(_attacker: Entity, _target: Entity, _di: DamageInfo) -> void:
	if not _di.is_main_attack(): return
	if _di.damage_type != DamageType.PHYSICAL: return
	var items_in_target := _attacker.get_items_by_name(NAME)
	if items_in_target.is_empty(): return

	var item := items_in_target[0]
	if item.get_remaining_cooldown() > 0: return

	var chance := items_in_target[0].float_dict["chance"]
	if not GlobalsEntityHelpers.roll_chance(chance): return

	var SUMM_TYPES: Array[String] = [EnemySummonedSkeletonBlade.LONG_NAME, EnemySummonedSkeletonBow.LONG_NAME]
	if _attacker.get_summoned_entities(SUMM_TYPES).size() >= items_in_target[0].float_dict["max_summons"]: return
	
	for _item in items_in_target: _item.reset_last_used_time()

	var duration := items_in_target[0].float_dict["summons_duration_in_seconds"]

	_spawn_melee_skeleton(_attacker, _target, duration)
	_spawn_ranged_skeleton(_attacker, _target, duration)

static func _spawn_melee_skeleton(_attacker: Entity, _target: Entity, _duration: float) -> void:
	var enemy: Enemy = EnemyBase.get_new_instance(EnemySummonedSkeletonBlade.LONG_NAME)
	enemy._skills = [
		SkillBase.get_new_learned_skill(SkillBlessingOfPower.NAME, 3),
		SkillBase.get_new_learned_skill(SkillBloodFury.NAME, 3),
		SkillBase.get_new_learned_skill(SkillFrozenTouch.NAME, 3),
		SkillBase.get_new_learned_skill(SkillTrueStrike.NAME, 3),
	]
	enemy.set_summoned_helper(_attacker.name, _duration)
	enemy.combat_stats.set_hp(3000)
	enemy.combat_stats.set_evasion(0.3)
	enemy.combat_stats.set_stun_chance(0.05, 2)
	enemy.combat_stats.set_crit_chance(0.2, 1.5)

	_aux_spawn_skeletons(enemy, _attacker, _target)

static func _spawn_ranged_skeleton(_attacker: Entity, _target: Entity, _duration: float) -> void:
	var enemy: Enemy = EnemyBase.get_new_instance(EnemySummonedSkeletonBow.LONG_NAME)
	enemy._skills = [
		SkillBase.get_new_learned_skill(SkillInfernalTouch.NAME, 3),
		SkillBase.get_new_learned_skill(SkillShieldedCore.NAME, 3),
		SkillBase.get_new_learned_skill(SkillLifesteal.NAME, 3),
		SkillBase.get_new_learned_skill(SkillFrenziedSilence.NAME, 3),
	]
	enemy.projectile_type = ProjectileVenomArrow.NAME
	enemy.combat_stats.set_attack_range(250)
	enemy.set_summoned_helper(_attacker.name, _duration)
	enemy.combat_stats.set_hp(2000)
	enemy.combat_stats.set_attack_speed(1)
	enemy.combat_stats.set_crit_chance(0.1, 1.5)

	_aux_spawn_skeletons(enemy, _attacker, _target)

static func _aux_spawn_skeletons(enemy: Entity, _attacker: Entity, _target: Entity) -> void:
	enemy.combat_stats.set_physical_attack_power(int(_attacker.cache_total_stats.get_physical_attack_power() * randf_range(0.1, 0.2)))
	enemy.combat_stats.set_magic_attack_power(int(_attacker.cache_total_stats.get_magic_attack_power() * randf_range(0.1, 0.2)))
	enemy.combat_stats.set_agility(int(_attacker.cache_total_stats.get_agility() * randf_range(0.1, 0.2)))
	enemy.combat_stats.set_strength(int(_attacker.cache_total_stats.get_strength() * randf_range(0.1, 0.2)))
	enemy.combat_stats.set_intelligence(int(_attacker.cache_total_stats.get_intelligence() * randf_range(0.1, 0.2)))

	enemy.set_current_hp_and_mana()

	var direction := _attacker.direction
	var front_cell := _attacker.movement_helper.current_cell + Vector2i(int(direction.x), int(direction.y))
	var safe_cell := MapManager.get_safe_cell(front_cell)
	enemy.global_position = MapManager.cell_to_world(safe_cell)

	GameManager.spawn_enemy(enemy)