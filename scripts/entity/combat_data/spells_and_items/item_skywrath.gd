class_name ItemSkywrath
extends Item

const NAME = "Skywrath"
const ICON_SLOT = Vector2(7, 1)

static func create_and_add_instance() -> void:
	_ITEMS[NAME] = Item.new(NAME)
	_ITEMS[NAME].region_rect = Rect2(_ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, _ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	_ITEMS[NAME].set_intelligence(100)
	_ITEMS[NAME].set_hp(2000)
	_ITEMS[NAME].damage_type = DamageType.MAGIC
	_ITEMS[NAME].set_mana_regeneration_points(20)
	_ITEMS[NAME].float_dict["lightning_chance"] = 0.1 # Probabilidad de lanzar rayos al recibir ataque físico
	_ITEMS[NAME].float_dict["lightning_damage_base"] = 50 # Daño base
	_ITEMS[NAME].float_dict["lightning_damage_percent"] = 2 # Daño extra en base a la inteligencia total
	_ITEMS[NAME].float_dict["mana_cost_percent"] = 0.05 # Porcentaje de mana consumido
	_ITEMS[NAME].max_targets = 5 # Cantidad de rayos
	_ITEMS[NAME].cast_range_in_tiles = 8
	_ITEMS[NAME].cooldown = 4
	_ITEMS[NAME].buy_price = 10500

	_ITEMS[NAME].en_description = (
		"Grants " + StringHelpers.format_float(_ITEMS[NAME].get_intelligence()) + " Intelligence and " +
		StringHelpers.format_float(_ITEMS[NAME].get_hp()) + " HP. " +
		"Has a " + StringHelpers.format_percent(_ITEMS[NAME].float_dict["lightning_chance"]) +
		" chance when hit by a physical attack to unleash " + str(_ITEMS[NAME].max_targets) +
		" lightning bolts at random enemies within " + str(_ITEMS[NAME].cast_range_in_tiles) +
		" tiles. Each bolt deals " + StringHelpers.format_float(_ITEMS[NAME].float_dict["lightning_damage_base"]) +
		" base magic damage plus " +
		StringHelpers.format_percent(_ITEMS[NAME].float_dict["lightning_damage_percent"]) +
		" of the owner's total Intelligence. Consumes " +
		StringHelpers.format_percent(_ITEMS[NAME].float_dict["mana_cost_percent"]) +
		" mana each time it triggers."
	)

	_ITEMS[NAME].es_description = (
		"Otorga " + StringHelpers.format_float(_ITEMS[NAME].get_intelligence()) + " de inteligencia y " +
		StringHelpers.format_float(_ITEMS[NAME].get_hp()) + " puntos de vida. " +
		"Tiene un " + StringHelpers.format_percent(_ITEMS[NAME].float_dict["lightning_chance"]) +
		" de probabilidad, al recibir un ataque físico, de lanzar " + str(_ITEMS[NAME].max_targets) +
		" rayos a enemigos aleatorios en un rango de " + str(_ITEMS[NAME].cast_range_in_tiles) +
		" tiles. Cada rayo inflige " +
		StringHelpers.format_float(_ITEMS[NAME].float_dict["lightning_damage_base"]) + " de daño mágico base más un " +
		StringHelpers.format_percent(_ITEMS[NAME].float_dict["lightning_damage_percent"]) +
		" de la inteligencia total del portador. Consume " +
		StringHelpers.format_percent(_ITEMS[NAME].float_dict["mana_cost_percent"]) +
		" de maná cada vez que se activa."
	)


static func static_actions_after_effective_hit(_attacker: Entity, _target: Entity, _di: DamageInfo) -> bool:
	if not _di.is_main_attack(): return false
	if _di.damage_type != DamageType.PHYSICAL: return false
	var items_in_target := _target.get_items_by_name(NAME)
	if items_in_target.is_empty(): return false

	var item := items_in_target[0]
	if item.get_remaining_cooldown() > 0: return false

	var lightning_chance := items_in_target[0].float_dict["lightning_chance"]
	if not GlobalsEntityHelpers.roll_chance(lightning_chance): return false
	
	var mana_cost_percent := item.float_dict["mana_cost_percent"]
	var consumed_mana := int(_target.get_full_mana() * mana_cost_percent)
	if not _target.current_mana >= consumed_mana: return false
	_target.update_current_mana(-consumed_mana)
	
	for _item in items_in_target: _item.reset_last_used_time()

	var nearest_enemies := GlobalsEntityHelpers.get_closest_entities(_target.global_position, _target.get_my_enemies(), item.cast_range_in_tiles, item.max_targets)

	var lightning_damage_base := item.float_dict["lightning_damage_base"]
	var lightning_damage_percent := item.float_dict["lightning_damage_percent"]
	var total_intelligence := _target.cache_total_stats.get_intelligence()
	var lightning_damage := int(lightning_damage_base + lightning_damage_percent * total_intelligence)
	var _ldi := DamageInfo.new(lightning_damage, DamageType.MAGIC, _target)
	for enemy in nearest_enemies:
		AnimationsHelper.apply_lightning_animation(enemy)
		enemy.server_receive_damage(_ldi, _target)

	return true

static func verify_existing(_owner: Entity) -> void:
	var has_item := _owner.get_items_by_name(NAME).size() > 0
	if has_item: return SkywrathEffect.attach_to(_owner.front_animations_node, 0)

	return SkywrathEffect.remove_all_from(_owner.front_animations_node)

static func static_actions_after_update_item(_owner: Entity, _item: Item, _slot_number: int) -> void:
	verify_existing(_owner)