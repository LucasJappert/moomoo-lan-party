class_name Skill

enum Type {ACTIVE, PASSIVE}

var name: String = ""
var type: Type = Type.ACTIVE
var cooldown: float = 0
var mana_cost: float = 0
var description: String = ""

func _init(_name: String, _type: Type, _cooldown: float, _mana_cost: float, _description: String):
	name = _name
	type = _type
	cooldown = _cooldown
	mana_cost = _mana_cost
	description = _description

static func get_stun_charge() -> Skill:
	return new(SkillNames.STUN_CHARGE, Type.ACTIVE, 5, 0, "Charges at the target, stunning it for 1 second.")

static func get_fireball() -> Skill:
	return new(SkillNames.FIREBALL, Type.ACTIVE, 4, 20, "Casts a fireball that deals area magic damage.")

static func get_frost_slam() -> Skill:
	return new(SkillNames.FROST_SLAM, Type.ACTIVE, 6, 0, "Slams the ground and slows nearby enemies.")

static func get_drain_life() -> Skill:
	return new(SkillNames.DRAIN_LIFE, Type.ACTIVE, 8, 25, "Drains life from the target and heals the caster.")

static func get_phase_shift() -> Skill:
	return new(SkillNames.PHASE_SHIFT, Type.PASSIVE, 10, 0, "Ignores the first incoming attack every 10 seconds.")

static func get_self_destruct() -> Skill:
	return new(SkillNames.SELF_DESTRUCT, Type.ACTIVE, 0, 0, "Ignores the first incoming attack every 10 seconds.")


# 🌀 Activas
# Shadow Strike – Golpe físico con +30% probabilidad de crítico y 150% de daño.

# Arcane Pulse – Onda de energía mágica que daña a todos los enemigos cercanos.

# Stunning Roar – Intenta aturdir a los enemigos en un área cercana.

# Poison Arrow – Flecha que envenena al enemigo por varios segundos.

# Quickstep – Aumenta evasión y velocidad de ataque por unos segundos.

# Fireball – Lanza una bola de fuego que explota en área.

# Frost Nova – Congela temporalmente a los enemigos cercanos.

# Blink – Teletransporte a corta distancia.

# Ground Slam – Golpe al suelo que daña y empuja enemigos alrededor.

# Life Drain – Roba vida del enemigo y la transfiere al usuario.

# Flame Dash – Avanza envuelto en fuego, dañando a quienes atraviesa.

# Multi Shot – Dispara múltiples proyectiles a diferentes enemigos.

# Thunder Clap – Descarga eléctrica que aturde a un objetivo.

# Searing Blade – Aumenta el daño del próximo ataque cuerpo a cuerpo.

# Guardian’s Shield – Absorbe daño durante unos segundos.

# Whirlwind – Ataque giratorio que golpea a todos los enemigos cercanos.

# Sniper Shot – Disparo con gran daño a larga distancia.

# Crippling Trap – Coloca una trampa que reduce la velocidad y evasión.

# Meteor Fall – Invoca un meteorito que cae sobre un área.

# Heal Wave – Cura al usuario y a aliados cercanos.

# 🌱 Pasivas
# Thick Skin – Aumenta defensa física y mágica permanentemente.

# Killer Instinct – Aumenta probabilidad de crítico contra enemigos heridos.

# Battle Rhythm – Incrementa velocidad de ataque con cada golpe consecutivo.

# Unyielding Will – Otorga un escudo al estar por debajo del 20% de vida.

# Stun Mastery – Mejora la probabilidad y duración de aturdimientos.

# Magic Efficiency – Reduce el costo de maná de habilidades mágicas.

# Evasive Stance – Aumenta la evasión en combate cuerpo a cuerpo.

# Fury – Incrementa daño a medida que se pierde vida.

# Precision – Aumenta la precisión y reduce la evasión del enemigo.

# Mana Leech – Recupera maná al infligir daño mágico.

# Bloodthirst – Cura un pequeño porcentaje de HP al matar enemigos.

# Arcane Resilience – Otorga resistencia al daño mágico.

# Shielded Core – Reduce todo el daño recibido un 5%.

# Adrenaline – Aumenta la velocidad de movimiento cuando se recibe daño.

# Projectile Expert – Aumenta el alcance y daño de ataques con proyectiles.

# Regeneration – Recupera lentamente HP con el tiempo.

# Armor Breaker – Los ataques tienen chance de reducir la defensa del enemigo.

# Spell Echo – Las habilidades mágicas tienen una probabilidad de duplicarse.

# Stealth Mastery – Mejora evasión y daño al atacar desde el sigilo.

# Explosive Death – Al morir, inflige daño a enemigos cercanos.
