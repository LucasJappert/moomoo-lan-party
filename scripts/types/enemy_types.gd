class_name EnemyTypes


const FROST_REVENANT = "Frost Revenant"
const WARDEN_OF_DECAY = "Warden of Decay"
const FLAME_CULTIST = "Flame Cultist"
const MOSSWOOD_SHAMAN = "Mosswood Shaman"
const EMBER_FIEND = "Ember Fiend"
const DUSK_PRIESTESS = "Dusk Priestess"
const VENOM_GUARD = "Venom Guard"
const ROTPIERCER = "Rotpiercer"
const ORC_BERSERKER = "Orc Berserker"
const LICH_COMMANDER = "Lich Commander"
const SOULBURN_SKELETON = "Soulburn Skeleton"
const GRAVE_WARDEN = "Grave Warden"
const BLAZELEAF_ROGUE = "Blazeleaf Rogue"
const HELLHORN_BRUTE = "Hellhorn Brute"
const ASHEN_KNIGHT = "Ashen Knight"
const INFERNO_HORNBEAST = "Inferno Hornbeast"
const BONEGUARD = "Boneguard"
const WRAITHMANCER = "Wraithmancer"
const BOGSHADE_ADEPT = "Bogshade Adept"
const INFERNAL_MINOTAUR = "Infernal Minotaur"
const CRIMSON_ARCHER = "Crimson Archer"
const FROSTSKIN_GOBLIN = "Frostskin Goblin"
const SILVERBLADE_HUNTER = "Silverblade Hunter"
const CINDERFLAME_WIELDER = "Cinderflame Wielder"
const DARK_ACOLYTE = "Dark Acolyte"
const NIGHTFANG_ASSASSIN = "Nightfang Assassin"
const SWAMP_HEXER = "Swamp Hexer"
const ASHBORN_GLADIATOR = "Ashborn Gladiator"
const GHOSTBLADE = "Ghostblade"
const MOONFANG_DUELIST = "Moonfang Duelist"
const BONE_BULWARK = "Bone Bulwark"
const FROSTBONE_WARRIOR = "Frostbone Warrior"

const frames_by_enemy = 2
const frame_size = 64
static var enemies_start_vector: Dictionary[String, Vector2i] = {}

static func _get_enemies_start_vector() -> Dictionary[String, Vector2i]:
	if enemies_start_vector.size() != 0:
		return enemies_start_vector

	const enemies_by_row = 8
	const enemies_by_column = 4

	for y in range(enemies_by_column):
		for x in range(enemies_by_row):
			var _key = y * enemies_by_row + x
			enemies_start_vector[get_enemy_keys()[_key]] = Vector2i(x * frame_size * frames_by_enemy, y * frame_size)

	print(enemies_start_vector)
	print(enemies_start_vector.size())
	return enemies_start_vector

static func get_enemy_rect_frames(enemy_key: String) -> Array[Rect2]:
	var start_vector := _get_enemies_start_vector()[enemy_key]
	var rects: Array[Rect2] = []
	for i in range(frames_by_enemy):
		rects.append(Rect2(start_vector.x + i * frame_size, start_vector.y, frame_size, frame_size))
	return rects

static func get_enemy_keys() -> Array[String]:
	return [
		FROST_REVENANT,
		WARDEN_OF_DECAY,
		FLAME_CULTIST,
		MOSSWOOD_SHAMAN,
		EMBER_FIEND,
		DUSK_PRIESTESS,
		VENOM_GUARD,
		ROTPIERCER,
		ORC_BERSERKER,
		LICH_COMMANDER,
		SOULBURN_SKELETON,
		GRAVE_WARDEN,
		BLAZELEAF_ROGUE,
		HELLHORN_BRUTE,
		ASHEN_KNIGHT,
		INFERNO_HORNBEAST,
		BONEGUARD,
		WRAITHMANCER,
		BOGSHADE_ADEPT,
		INFERNAL_MINOTAUR,
		CRIMSON_ARCHER,
		FROSTSKIN_GOBLIN,
		SILVERBLADE_HUNTER,
		CINDERFLAME_WIELDER,
		DARK_ACOLYTE,
		NIGHTFANG_ASSASSIN,
		SWAMP_HEXER,
		ASHBORN_GLADIATOR,
		GHOSTBLADE,
		MOONFANG_DUELIST,
		BONE_BULWARK,
		FROSTBONE_WARRIOR
	]
