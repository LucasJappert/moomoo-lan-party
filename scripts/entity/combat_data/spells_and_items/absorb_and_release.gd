class_name AbsorbAndRelease

extends MyInitAuxiliary

var seconds_elapsed: float = 0
var seconds_to_release: float = 0
var percent_to_release: float = 0
var radius_in_tiles: float
var damage_accumulated: float
var active: bool = false

func _init(_seconds_to_release: float = 0, _percent_to_release: float = 0, _radius_in_tiles: float = 1, _activate: bool = false):
	super._init()
	seconds_to_release = _seconds_to_release
	percent_to_release = _percent_to_release
	radius_in_tiles = _radius_in_tiles
	active = _activate

func activate() -> void:
	active = true
	damage_accumulated = 0
	seconds_elapsed = 0

func on_damage_received(_attacker: Entity, _damage_received: int) -> void:
	if not active: return
	if _damage_received <= 0: return

	damage_accumulated += _damage_received

func process(_delta: float, _attacker: Entity) -> void:
	if not active: return
	seconds_elapsed += _delta
	if seconds_elapsed < seconds_to_release: return

	active = false

	var nearest_enemies = GlobalsEntityHelpers.get_closest_entities(_attacker.global_position, 30, _attacker.get_my_enemies(), radius_in_tiles)
	var total_damage_to_release := int(damage_accumulated * percent_to_release)
	for enemy in nearest_enemies:
		enemy.server_receive_damage(DamageInfo.new(total_damage_to_release, DamageType.PHYSICAL, _attacker.name), _attacker)

	var message := "💥 " + str(total_damage_to_release) + " released 💥"
	_attacker.hud.show_message_popup(message.to_upper(), Color(1, 1, 1), 0.4)

static func try_to_use(_my_owner: Entity, learned_skill: ItemSkillBase) -> bool:
	if learned_skill.my_name != Skill.Names.ABSORB_AND_RELEASE: return true

	var _seconds_to_release: float = learned_skill.float_dict["seconds_to_release"]
	var _percent_to_release: float = learned_skill.float_dict["percent_to_release"]
	_my_owner.absorb_and_release = AbsorbAndRelease.new(_seconds_to_release, _percent_to_release, learned_skill.range_in_tiles, true)

	return true