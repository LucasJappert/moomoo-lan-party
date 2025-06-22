class_name AnimationsHelper

const ANIMATION_NAMES = {
	LIGHTNING = "lightning",
	FROST_HIT = "frost_hit",
	STUN = "stun",
	LEVEL_UP = "level_up"
}

static func try_to_remove_obsolete_stun_animation(target: Entity):
	var animation_stun_active = _animation_active(target, ANIMATION_NAMES.STUN)
	if not animation_stun_active: return
	
	for effect in target.combat_data.get_effects():
		if effect.stats.apply_stun(): return

	_remove_animations(target, ANIMATION_NAMES.STUN)

static func apply_animation(animation_msg: AddAnimationMessage, target: Entity) -> void:
	if animation_msg.animation_name == ANIMATION_NAMES.LIGHTNING:
		_apply_lightning_animation(target)
	if animation_msg.animation_name == ANIMATION_NAMES.LEVEL_UP:
		_apply_level_up_animation(target)

static func apply_frost_hit_animation(target: Entity):
	const sprite_size = Vector2(32, 32)
	var frames = SpritesHelper.get_sprite_frames(Vector2(0, 576), sprite_size, 11, 30, false)
	_spawn_front_animation(target, frames, ANIMATION_NAMES.FROST_HIT)
	
static func apply_stun_animation(target: Entity):
	if _animation_active(target, ANIMATION_NAMES.STUN): return
	var sprite_size = CombatEffect.STUN_RECT_REGION.size
	var frames = SpritesHelper.get_sprite_frames(CombatEffect.STUN_RECT_REGION.position, sprite_size, 14, 30, true)
	var sprite_position = Vector2(0, target.hud.bars_container.position.y)
	_spawn_front_animation(target, frames, ANIMATION_NAMES.STUN, sprite_position)

static func _apply_level_up_animation(target: Entity):
	if _animation_active(target, ANIMATION_NAMES.LEVEL_UP): return
	const sprite_size = Vector2(64, 64)
	var frames = SpritesHelper.get_sprite_frames(Vector2(0, 736), sprite_size, 10, 20, false)
	var sprite_position = Vector2(0, -sprite_size.y * 0.5)
	_spawn_front_animation(target, frames, ANIMATION_NAMES.LEVEL_UP, sprite_position, Vector2(1.5, 1.5))


static func _remove_animations(target: Entity, animated_sprite_name: String):
	for child in target.front_animations_node.get_children():
		if child is AnimatedSprite2D and child.name == animated_sprite_name:
			child.queue_free()

static func _animation_active(target: Entity, animated_sprite_name: String) -> bool:
	for animated_sprite in target.front_animations_node.get_children():
		# TODO: remove animated_sprite is AnimatedSprite2D condition
		if animated_sprite is AnimatedSprite2D and animated_sprite.name == animated_sprite_name:
			return true
	return false

static func _get_position_of_bottom_of_the_cell(sprite_size: Vector2) -> Vector2:
	return Vector2(0, -sprite_size.y * 0.5 + MapManager.TILE_SIZE.y * 0.7)

static func _spawn_front_animation(target: Entity,
	frames: SpriteFrames,
	anim_name: String,
	anim_pos: Vector2 = Vector2.ZERO,
	scale: Vector2 = Vector2.ONE
):
	var sprite := AnimatedSprite2D.new()
	sprite.position = anim_pos
	sprite.scale = scale
	sprite.sprite_frames = frames
	sprite.name = anim_name
	target.front_animations_node.add_child(sprite, true)
	sprite.play()
	sprite.animation_finished.connect(func(): sprite.queue_free())

static func _apply_lightning_animation(target: Entity):
	var sprite_size = Vector2(64, 96)
	var frames = SpritesHelper.get_sprite_frames(Vector2(0, 640), sprite_size, 12, 25, false)
	_spawn_front_animation(target, frames, ANIMATION_NAMES.LIGHTNING, _get_position_of_bottom_of_the_cell(sprite_size))
	SoundManager.play_lightning_spell()
