class_name HeroTypes

class JsonItem:
	var alias: String
	var description_en: String
	var description_es: String

	func _init(data: Dictionary):
		alias = data["alias"]
		description_en = data["description_en"]
		description_es = data["description_es"]

const IRON_VEX = "Iron Vex"
const LIORA_SUNVEIL = "Liora Sunveil"
const THARNOK_THE_VERDANT = "Tharnok the Verdant"
const VARRIK_DUSKHOLLOW = "Varrik Duskhollow"

const _START_REGION = Vector2i(0, 320)
const _FRAME_SIZE = Vector2i(128, 128)
const frames_by_type := 2
static var heros_start_vector: Dictionary[String, Vector2i] = {}
static var heros_json_data: Dictionary[String, JsonItem] = {}

static func _get_heros_start_vector() -> Dictionary[String, Vector2i]:
	if heros_start_vector.size() != 0:
		return heros_start_vector

	const heros_by_row = 2
	const heros_by_column = 2

	for y in range(heros_by_column):
		for x in range(heros_by_row):
			var _key = y * heros_by_row + x
			heros_start_vector[get_keys()[_key]] = Vector2i(_START_REGION.x + x * _FRAME_SIZE.x * frames_by_type, _START_REGION.y + y * _FRAME_SIZE.y)

	return heros_start_vector

static func get_rect_frames(hero_type: String) -> Array[Rect2]:
	var start_vector := _get_heros_start_vector()[hero_type]
	var rects: Array[Rect2] = []
	for i in range(frames_by_type):
		rects.append(Rect2(start_vector.x + i * _FRAME_SIZE.x, start_vector.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return rects

static func get_keys() -> Array[String]:
	return [
		IRON_VEX,
		LIORA_SUNVEIL,
		THARNOK_THE_VERDANT,
		VARRIK_DUSKHOLLOW
	]

static func get_json_data() -> Dictionary[String, JsonItem]:
	var json_data = JsonHelpers.load_json("res://.docs/heros.json")
	var result: Dictionary[String, JsonItem] = {}
	for key in json_data:
		result[key] = JsonItem.new(json_data[key])
	return result

static func get_hero_json_data(hero_type: String) -> JsonItem:
	if heros_json_data.size() == 0:
		heros_json_data = get_json_data()

	return heros_json_data[hero_type]

static func initialize_hero(player: Player) -> void:
	player.combat_data.base_hp = 400
	player.combat_data.base_mana = 100
	player.combat_data.physical_defense_percent = 0.1
	player.combat_data.magic_defense_percent = 0.1
	player.combat_data.evasion = 0.05
	player.combat_data.crit_chance = 0.05
	player.combat_data.crit_multiplier = 1.5
	player.combat_data.attack_speed = 1
	player.combat_data.physical_attack_power = 25
	player.combat_data.magic_attack_power = 25
	player.combat_data.move_speed = 5
	player.combat_data.agility = 10
	player.combat_data.strength = 10
	player.combat_data.intelligence = 10
	player.combat_data.attack_range = CombatStats.MIN_ATTACK_RANGE
	player.json_data = HeroTypes.get_hero_json_data(player.hero_type)

	if player.hero_type == IRON_VEX:
		player.combat_data.attack_type = AttackTypes.MELEE
		player.combat_data.projectile_type = Projectile.TYPES.NONE
		player.combat_data.base_hp = 600
		player.combat_data.evasion = 0.1
		player.combat_data.agility = 10
		player.combat_data.strength = 15
		player.combat_data.intelligence = 10
		player.combat_data.skills = [
			Skill.get_skill(Skill.Names.LIFESTEAL),
			Skill.get_skill(Skill.Names.STUNNING_STRIKE),
			Skill.get_skill(Skill.Names.SHIELDED_CORE),
			Skill.get_skill(Skill.Names.FROZEN_TOUCH)
		]
	
	if player.hero_type == LIORA_SUNVEIL:
		player.combat_data.skills = [Skill.get_skill(Skill.Names.LIFESTEAL)]
	
	if player.hero_type == THARNOK_THE_VERDANT:
		player.combat_data.skills = [Skill.get_skill(Skill.Names.LIFESTEAL)]
	
	if player.hero_type == VARRIK_DUSKHOLLOW:
		player.combat_data.skills = [Skill.get_skill(Skill.Names.LIFESTEAL)]

	player.combat_data.current_hp = int(player.combat_data.get_total_hp() * 0.9)

# [
#   {
#     "name": "Iron Vex",
#     "alias": "Vexar",
#     "description_en": "A shielded warrior who strikes back with raw plasma force.",
#     "description_es": "Un guerrero blindado que contraataca con fuerza de plasma pura."
#   },
#   {
#     "name": "Liora Sunveil",
#     "alias": "Lumira",
#     "description_en": "A divine priestess channeling celestial light to heal and smite.",
#     "description_es": "Una sacerdotisa divina que canaliza luz celestial para sanar y castigar."
#   },
#   {
#     "name": "Tharnok the Verdant",
#     "alias": "Thornak",
#     "description_en": "Nature-bound knight who thrives on regeneration and retaliation.",
#     "description_es": "Caballero vinculado a la naturaleza que se regenera y contraataca."
#   },
#   {
#     "name": "Varrik Duskhollow",
#     "alias": "Duskar",
#     "description_en": "A cursed archer who fires shadow-tipped arrows from afar.",
#     "description_es": "Arquero maldito que dispara flechas sombrías desde la distancia."
#   }
# ]
