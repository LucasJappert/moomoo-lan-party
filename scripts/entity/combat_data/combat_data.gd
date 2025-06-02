class_name CombatData

extends CombatAttributes

const MIN_ATTACK_RANGE: int = int(MapManager.TILE_SIZE.x)

@onready var combat_effect_node = $CombatEffectNode

@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_mana: int = 100
@export var current_mana: int = 100
@export var attack_type := AttackTypes.MELEE
@export var projectile_type: String = Projectile.TYPES.NONE
var skills: Array[Skill] = []


var last_physical_hit_time: int = 0 # In milliseconds
var nearest_enemy_focused: Entity
var last_damage_received_time: int = 0 # In milliseconds

var my_owner: Entity

func _ready() -> void:
	initialize_default_values()
	if multiplayer.is_server() == false:
		set_process(false)


func set_my_owner(_owner: Entity) -> void:
	my_owner = _owner
	pass

func add_effect(effect: CombatEffect) -> void:
	# Should be called only on the server
	combat_effect_node.add_child(effect, true)

# TODO: Improve this get by creating a dictionary to quickly obtain active effects
func get_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for child in combat_effect_node.get_children():
		if child is CombatEffect:
			effects.append(child as CombatEffect)
	return effects

func _server_calculate_physical_damage(_target: Entity) -> void:
	if my_owner.multiplayer.is_server() == false: return
	if _target == null: return

	var critical_damage = 0
	if GlobalsEntityHelpers.roll_chance(crit_chance):
		critical_damage = get_total_physical_attack_power() * crit_multiplier
	var total_damage = get_total_physical_attack_power() + critical_damage
	# print("Normal power: ", physical_attack_power, " Extra power: ", extra_power, " Total total_damage: ", total_damage)

	var _di = DamageInfo.get_instance()
	_di.total_damage_heal = total_damage
	_di.critical = critical_damage
	_di.projectile_type = projectile_type
	_di.damage_type = DamageInfo.DamageType.PHYSICAL

	_target.combat_data._server_receive_physical_damage(_di, my_owner)

func _server_receive_physical_damage(_di: DamageInfo, _attacker: Entity) -> void:
	if my_owner.multiplayer.is_server() == false: return

	# Evasion verification
	if GlobalsEntityHelpers.roll_chance(get_total_evasion()):
		# TODO: Crear un helper para enviar mensajes
		var sm = ServerMessage.get_instance()
		sm.message = "Dodge"
		sm.color = Vector3(0, 0.5, 1)
		my_owner.rpc("rpc_server_message", sm.to_dict())
		return

	var damage_before_defense = _di.total_damage_heal
	var reduced_damage = get_total_physical_defense_percent() * damage_before_defense
	_di.critical = _di.critical - int(get_total_physical_defense_percent() * _di.critical)
	var total_damage: int = _di.total_damage_heal - reduced_damage
	if total_damage < 0: total_damage = 0

	_di.total_damage_heal = total_damage

	Skill.actions_after_effective_hit(_attacker, my_owner, _di)

	# print("Damage before defense: ", damage_before_defense, " reduced: ", reduced_damage, " total: ", total_damage, " critical: ", _di.critical)

	my_owner.rpc("rpc_receive_damage_or_heal", _di.to_dict())

	update_current_hp_for_damage(total_damage)

# region SETTERs
func update_current_hp_for_damage(value_to_decrease: int) -> void:
	if current_hp <= 0: return
	
	current_hp -= value_to_decrease
	current_hp = clamp(current_hp, 0, get_total_max_hp())
	
	if current_hp <= 0:
		Skill.actions_before_entity_death(my_owner, my_owner.target_entity)
		current_hp = 0
		if my_owner is Enemy:
			for player in GameManager.get_players():
				player.increment_current_exp(1000)
		my_owner.rpc("rpc_die")
# endregion

# region GETTERs
func get_skill(skill_name: String) -> Skill:
	for skill in skills:
		if skill.name == skill_name: return skill
	return null

func get_total_max_hp() -> int:
	return max_hp + _get_extra_hp()

func get_total_max_mana() -> int:
	return max_mana + _get_extra_mana()

func get_total_attack_speed() -> int:
	var base_speed := attack_speed + _get_extra_attack_speed()
	var extra_percent := _get_extra_attack_speed_percent()

	# Apply attack speed percentage as an inverse modifier
	var effective_speed := base_speed - (base_speed * extra_percent)

	# Protect against extreme values
	effective_speed = clamp(effective_speed, 100.0, 10000.0)

	return int(effective_speed)

func get_total_attack_range() -> int:
	var total := attack_range + _get_extra_attack_range()
	if total < MIN_ATTACK_RANGE: total = MIN_ATTACK_RANGE
	return total

func get_total_move_speed() -> float:
	var tiles_per_second := move_speed + _get_extra_move_speed()
	var extra_percent := _get_extra_move_speed_percent()

	tiles_per_second += tiles_per_second * extra_percent
	tiles_per_second = clamp(tiles_per_second, 0.1, 10.0)

	return tiles_per_second

func get_total_physical_defense_percent() -> float:
	return physical_defense_percent + _get_extra_physical_defense_percent()

func get_total_evasion() -> float:
	return evasion + _get_extra_evasion()

func get_total_stun_chance() -> float:
	return stun_chance + _get_extra_stun_chance()

func get_total_physical_attack_power() -> float:
	var total = physical_attack_power + _get_extra_physical_attack_power()
	var extra_percent = _get_extra_physical_attack_power_percent()
	total = total * (1 + extra_percent)
	if total < 0: total = 0
	return total


func is_stunned() -> bool:
	for effect in get_effects():
		if effect.stun_duration > 0: return true
	return false


# endregion

# region TRY PHISICAL ATTACK
func try_physical_attack(_delta: float):
	if not my_owner.multiplayer.is_server(): return

	if my_owner.velocity != Vector2.ZERO: return

	if my_owner.target_entity == null: _assign_target_if_needed()

	if my_owner.target_entity == null: return

	if not can_physical_attack(): return

	if not GlobalsEntityHelpers.is_target_in_attack_area(my_owner, my_owner.target_entity): return

	_execute_physical_attack()
	last_physical_hit_time = Time.get_ticks_msec()

func _assign_target_if_needed():
	if my_owner is Player:
		my_owner.target_entity = GlobalsEntityHelpers.get_nearest_entity_to_attack(my_owner, GameManager.get_enemies())
		return

	if my_owner is Enemy:
		# First we check if there is a player nearby, then if the moomoo is in attack range
		my_owner.target_entity = GlobalsEntityHelpers.get_nearest_entity_to_attack(my_owner, GameManager.get_players())
		if my_owner.target_entity != null: return
		if GlobalsEntityHelpers.is_target_in_attack_area(my_owner, GameManager.moomoo): my_owner.target_entity = GameManager.moomoo

func _execute_physical_attack():
	match attack_type:
		AttackTypes.RANGED:
			Projectile.launch(my_owner, my_owner.target_entity, physical_attack_power)

		AttackTypes.MELEE:
			_server_calculate_physical_damage(my_owner.target_entity)
	
func can_physical_attack() -> bool:
	if my_owner.velocity != Vector2.ZERO: return false
	if is_stunned(): return false
	var now = Time.get_ticks_msec()
	return now - last_physical_hit_time >= get_total_attack_speed()
# endregion

func _global_receive_damage_or_heal(_di: DamageInfo):
	var melee_attack = _di.projectile_type == Projectile.TYPES.NONE
	var arrow_attack = _di.projectile_type == Projectile.TYPES.ARROW
	if _di.critical > 0:
		my_owner.hud.show_damage_heal_popup(str(-_di.critical), Color(1, 1, 0))
		my_owner.hud.show_damage_heal_popup(str(- (_di.total_damage_heal - _di.critical)), Color(1, 0, 0))
		if arrow_attack: SoundManager.play_critical_arrow_shot()
		if melee_attack: SoundManager.play_critical_melee_hit()
	if _di.critical == 0 and _di.total_damage_heal > 0:
		if melee_attack: SoundManager.play_melee_hit()

	if _di.total_damage_heal < 0: # Heal
		my_owner.hud.show_damage_heal_popup(str(abs(_di.total_damage_heal)), Color(0, 1, 0))
	
	last_damage_received_time = Time.get_ticks_msec()
	pass

# region INTERNAL GETTERs
func _get_extra_physical_defense_percent() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.physical_defense_percent
	return snapped(total, 0.01)

func _get_extra_physical_attack_power() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.physical_attack_power
	return snapped(total, 0.01)
func _get_extra_physical_attack_power_percent() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.physical_attack_power_percent
	return snapped(total, 0.01)

func _get_extra_evasion() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.evasion
	return snapped(total, 0.01)

func _get_extra_attack_speed() -> int:
	var total: int = 0
	for effect in get_effects(): total += effect.attack_speed
	return total

func _get_extra_attack_speed_percent() -> float:
	var total: float = 0.0
	for effect in get_effects(): total += effect.attack_speed_percent
	return snapped(clamp(total, -10.0, 10.0), 0.1)

func _get_extra_attack_range() -> int:
	var total: int = 0
	for effect in get_effects(): total += effect.attack_range
	return total

func _get_extra_move_speed() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.move_speed
	return snapped(total, 0.01)

func _get_extra_move_speed_percent() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.move_speed_percent
	return snapped(total, 0.01)

func _get_extra_stun_chance() -> float:
	var total: float = 0
	for effect in get_effects(): total += effect.stun_chance
	return snapped(total, 0.01)

func _get_extra_hp() -> int:
	var total: int = 0
	for effect in get_effects(): total += effect.hp
	return total

func _get_extra_mana() -> int:
	var total: int = 0
	for effect in get_effects(): total += effect.mana
	return total

# endregion

# region Front Animations
const _ANIMATED_SPRITE_STUN_NAME = "stun"
func animation_active(animated_sprite_name: String) -> bool:
	for animated_sprite in my_owner.front_animations_node.get_children():
		if animated_sprite is AnimatedSprite2D and animated_sprite.name == animated_sprite_name:
			return true
	return false
func remove_animations(animated_sprite_name: String):
	for child in my_owner.front_animations_node.get_children():
		if child is AnimatedSprite2D and child.name == animated_sprite_name:
			child.queue_free()
func try_to_remove_obsolete_stun_animation():
	var animation_stun_active = animation_active(_ANIMATED_SPRITE_STUN_NAME)
	if not animation_stun_active: return
	
	for effect in get_effects():
		if effect.stun_duration > 0: return

	remove_animations(_ANIMATED_SPRITE_STUN_NAME)

func apply_frost_hit_animation():
	const sprite_size = Vector2(32, 32)
	var frames = SpritesAnimationHelper.get_sprite_frames(Vector2(0, 576), sprite_size, 11, 30, false)
	spawn_front_fx(frames, "frost_hit")

func apply_stun_animation():
	if animation_active(_ANIMATED_SPRITE_STUN_NAME): return
	const sprite_size = Vector2(32, 17)
	var sprite_position = Vector2(0, my_owner.hud.my_health_bar.position.y + 10)
	var frames = SpritesAnimationHelper.get_sprite_frames(Vector2(0, 608), sprite_size, 14, 30, true)
	spawn_front_fx(frames, _ANIMATED_SPRITE_STUN_NAME, sprite_position)

func spawn_front_fx(frames: SpriteFrames, animated_sprite_name: String, sprite_position: Vector2 = Vector2.ZERO):
	var sprite := AnimatedSprite2D.new()
	sprite.position = sprite_position
	sprite.sprite_frames = frames
	sprite.name = animated_sprite_name
	my_owner.front_animations_node.add_child(sprite, true)
	sprite.play()
	sprite.animation_finished.connect(func(): sprite.queue_free())

# endregion Front Animations
