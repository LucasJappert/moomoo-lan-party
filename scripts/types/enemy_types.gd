class_name EnemyTypes

const Names = {
	FROST_REVENANT = "Frost Revenant", # (Revenant de Escarcha) - alias: Frostreign
	WARDEN_OF_DECAY = "Warden of Decay", # (Guardián de la Decadencia) - alias: Decaywarden
	FLAME_CULTIST = "Flame Cultist", # (Cultista de la Llama) - alias: Pyraeth
	MOSSWOOD_SHAMAN = "Mosswood Shaman", # (Chamán de Bosque Musgoso) - alias: Mossgrove
	EMBER_FIEND = "Ember Fiend", # (Demonio de la Brasa) - alias: Cindral
	DUSK_PRIESTESS = "Dusk Priestess", # (Sacerdotisa del Ocaso) - alias: Nythera
	VENOM_GUARD = "Venom Guard", # (Guardia Venenosa) - alias: Virex
	ROTPIERCER = "Rotpiercer", # (Perforador Pútrido) - alias: Rukmar
	ORC_BERSERKER = "Orc Berserker", # (Orco Rabioso) - alias: Gorthak
	LICH_COMMANDER = "Lich Commander", # (Comandante Lich) - alias: Varnor
	SOULBURN_SKELETON = "Soulburn Skeleton", # (Esqueleto Quemaalmas) - alias: Ashrack
	GRAVE_WARDEN = "Grave Warden", # (Guardián de la Tumba) - alias: Tharn
	BLAZELEAF_ROGUE = "Blazeleaf Rogue", # (Pícaro de Hoja Llameante) - alias: Sylza
	HELLHORN_BRUTE = "Hellhorn Brute", # (Bruto de Cuerno Infernal) - alias: Braknor
	ASHEN_KNIGHT = "Ashen Knight", # (Caballero Cenizo) - alias: Duskar
	INFERNO_HORNBEAST = "Inferno Hornbeast", # (Bestia Cornuda del Infierno) - alias: Moltrax
	BONEGUARD = "Boneguard", # (Guardián Óseo) - alias: Dravok
	WRAITHMANCER = "Wraithmancer", # (Nigromante Espectral) - alias: Kaelmor
	BOGSHADE_ADEPT = "Bogshade Adept", # (Adepto del Pantano Sombrío) - alias: Morgrin
	INFERNAL_MINOTAUR = "Infernal Minotaur", # (Minotauro Infernal) - alias: Threx
	CRIMSON_ARCHER = "Crimson Archer", # (Arquero Carmesí) - alias: Valyra
	FROSTSKIN_GOBLIN = "Frostskin Goblin", # (Goblin de Piel Helada) - alias: Snurgle
	SILVERBLADE_HUNTER = "Silverblade Hunter", # (Cazador de Hoja Plateada) - alias: Eryndor
	CINDERFLAME_WIELDER = "Cinderflame Wielder", # (Portador de la Llama de Ceniza) - alias: Arvok
	DARK_ACOLYTE = "Dark Acolyte", # (Acólito Oscuro) - alias: Nihzar
	NIGHTFANG_ASSASSIN = "Nightfang Assassin", # (Asesino Colmillo Nocturno) - alias: Vexira
	SWAMP_HEXER = "Swamp Hexer", # (Hechicero del Pantano) - alias: Drogar
	ASHBORN_GLADIATOR = "Ashborn Gladiator", # (Gladiador Nacido de Ceniza) - alias: Kaelgor
	GHOSTBLADE = "Ghostblade", # (Hoja Fantasmal) - alias: Spectralis
	MOONFANG_DUELIST = "Moonfang Duelist", # (Duelista de Colmillo Lunar) - alias: Lurien
	BONE_BULWARK = "Bone Bulwark", # (Muralla Ósea) - alias: Marrak
	FROSTBONE_WARRIOR = "Frostbone Warrior", # (Guerrero de Hueso Helado) - alias: Halgrim
}

static var ENEMY_TYPES: Dictionary[String, ExtraInfo] = {
	Names.FROST_REVENANT: ExtraInfo.new(Names.FROST_REVENANT, get_rect_frames(Vector2i(0, 0)), "Frostreign"),
	Names.WARDEN_OF_DECAY: ExtraInfo.new(Names.WARDEN_OF_DECAY, get_rect_frames(Vector2i(1, 0)), "Decaywarden"),
	Names.FLAME_CULTIST: ExtraInfo.new(Names.FLAME_CULTIST, get_rect_frames(Vector2i(2, 0)), "Pyraeth"),
	# ... y así para cada enemigo
}

const _START_REGION = Vector2i(0, 0)
const _FRAME_SIZE = Vector2i(64, 64)
const _FRAMES = 2

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + (pos.y * _FRAMES) * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + (pos.y * _FRAMES) * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result

static func initialize(enemy: Enemy) -> void:
	enemy.extra_info = ENEMY_TYPES[enemy.extra_info.key_type]
	enemy.update_cache_total_stats()
