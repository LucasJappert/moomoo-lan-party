class_name EnemyBase
const SCENE = preload("res://scenes/entity/enemy_scene.tscn")

static var REGISTERED_CLASSES = [
	EnemySummonedSkeletonBow,
	EnemySummonedSkeletonBlade,
	EnemyRotbull,
	EnemyBlowDigger,
	EnemyCrimsonWarlock,
	EnemyReflector,
	EnemyDeadShield,
	EnemySilentShuriken,
	EnemyNightArcher,
	EnemyInfernalMinotaur,
	EnemyBoneguard,
	EnemyFrostboneArcher,
	EnemyEmberFiend,
	EnemyCinderflameWielder,
	EnemyFrostRevenant,
	EnemyFlameCultist,
	EnemyWardenOfDecay,
	EnemyMosswoodShaman
]

const _START_REGION = Vector2i(0, 0)
const _FRAME_SIZE = Vector2i(64, 64)
const _FRAMES = 2

static func get_new_instance(_name: String = "") -> Enemy:
	var _enemy: Enemy = SCENE.instantiate()
	_enemy.id = UniqueIdGenerator.get_id()
	if _name.is_empty(): return _enemy

	_enemy.set_enemy_type(_name)

	_commons_initialize(_enemy)

	for registered_class in REGISTERED_CLASSES: registered_class.try_to_init_from_name(_name, _enemy)
	
	_enemy.update_base_stats(_enemy.combat_stats.get_info())

	return _enemy

static func _commons_initialize(_enemy: Enemy) -> void:
	_enemy.combat_stats.set_move_speed(2)
	_enemy.combat_stats.set_attack_range(CombatStats.MIN_ATTACK_RANGE)
	_enemy.combat_stats.set_magic_attack_power(0)
	_enemy.combat_stats.set_physical_attack_power(100)
	_enemy.combat_stats.set_crit_multiplier(1.5)
	_enemy.combat_stats.set_attack_speed(0.5)
	_enemy.combat_stats.set_agility(10)
	_enemy.combat_stats.set_strength(6)
	_enemy.combat_stats.set_intelligence(10)

static func get_rect_frames(pos: Vector2i) -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	result.append(Rect2(_START_REGION.x + (pos.x * _FRAMES + 1) * _FRAME_SIZE.x, _START_REGION.y + pos.y * _FRAME_SIZE.y, _FRAME_SIZE.x, _FRAME_SIZE.y))
	return result

# const Names = {
# 	FROST_REVENANT = "Frost Revenant", # (Revenant de Escarcha) - alias: Frostreign
# 	WARDEN_OF_DECAY = "Warden of Decay", # (Guardián de la Decadencia) - alias: Decaywarden
# 	FLAME_CULTIST = "Flame Cultist", # (Cultista de la Llama) - alias: Pyraeth
# 	MOSSWOOD_SHAMAN = "Mosswood Shaman", # (Chamán de Bosque Musgoso) - alias: Mossgrove
# 	EMBER_FIEND = "Ember Fiend", # (Demonio de la Brasa) - alias: Cindral
# 	DUSK_PRIESTESS = "Dusk Priestess", # (Sacerdotisa del Ocaso) - alias: Nythera
# 	VENOM_GUARD = "Venom Guard", # (Guardia Venenosa) - alias: Virex
# 	ROTPIERCER = "Rotpiercer", # (Perforador Pútrido) - alias: Rukmar
# 	ORC_BERSERKER = "Orc Berserker", # (Orco Rabioso) - alias: Gorthak
# 	LICH_COMMANDER = "Lich Commander", # (Comandante Lich) - alias: Varnor
# 	FROSTBONE_ARCHER = "Frostbone Archer", # (Arquero Huesohelado) - alias: Frostbite
# 	GRAVE_WARDEN = "Grave Warden", # (Guardián de la Tumba) - alias: Tharn
# 	NIGHT_ARCHER = "Night Archer", # (Arquero Nocturno) - alias: Shadebolt
# 	HELLHORN_BRUTE = "Hellhorn Brute", # (Bruto de Cuerno Infernal) - alias: Braknor
# 	ASHEN_KNIGHT = "Ashen Knight", # (Caballero Cenizo) - alias: Duskar
# 	INFERNO_HORNBEAST = "Inferno Hornbeast", # (Bestia Cornuda del Infierno) - alias: Moltrax
# 	BONEGUARD = "Warden", # (Guardián Óseo) - alias: Dravok
# 	WRAITHMANCER = "Wraithmancer", # (Nigromante Espectral) - alias: Kaelmor
# 	BOGSHADE_ADEPT = "Bogshade Adept", # (Adepto del Pantano Sombrío) - alias: Morgrin
# 	INFERNAL_MINOTAUR = "Infernal Minotaur", # (Minotauro Infernal) - alias: Threx
# 	CRIMSON_ARCHER = "Crimson Archer", # (Arquero Carmesí) - alias: Valyra
# 	FROSTSKIN_GOBLIN = "Frostskin Goblin", # (Goblin de Piel Helada) - alias: Snurgle
# 	SILVERBLADE_HUNTER = "Silverblade Hunter", # (Cazador de Hoja Plateada) - alias: Eryndor
# 	CINDERFLAME_WIELDER = "Cinderflame Wielder", # (Portador de la Llama de Ceniza) - alias: Arvok
# 	DARK_ACOLYTE = "Dark Acolyte", # (Acólito Oscuro) - alias: Nihzar
# 	NIGHTFANG_ASSASSIN = "Nightfang Assassin", # (Asesino Colmillo Nocturno) - alias: Vexira
# 	SWAMP_HEXER = "Swamp Hexer", # (Hechicero del Pantano) - alias: Drogar
# 	ASHBORN_GLADIATOR = "Ashborn Gladiator", # (Gladiador Nacido de Ceniza) - alias: Kaelgor
# 	GHOSTBLADE = "Ghostblade", # (Hoja Fantasmal) - alias: Spectralis
# 	MOONFANG_DUELIST = "Moonfang Duelist", # (Duelista de Colmillo Lunar) - alias: Lurien
# 	BONE_BULWARK = "Bone Bulwark", # (Muralla Ósea) - alias: Marrak
# 	FROSTBONE_WARRIOR = "Frostbone Warrior", # (Guerrero de Hueso Helado) - alias: Halgrim
# }