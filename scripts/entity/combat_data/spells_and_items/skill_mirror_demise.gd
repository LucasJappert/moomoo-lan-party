class_name SkillMirrorDemise
extends SkillBase

const NAME = "Mirror Demise"
const ICON_SLOT = Vector2(2, 0)

static func create_and_add_instance() -> void:
	SKILLS[NAME] = Skill.new(NAME, SkillType.PASSIVE)
	SKILLS[NAME].region_rect = Rect2(ATLAS_START_POS.x + FRAME_SIZE * ICON_SLOT.x, ATLAS_START_POS.y + FRAME_SIZE * ICON_SLOT.y, FRAME_SIZE, FRAME_SIZE)
	
	for i in AVAILABLE_LEVELS:
		SKILLS[NAME].item_skill_base[i].apply_to_enemy = false
		SKILLS[NAME].item_skill_base[i].description = "Upon death, splits into " + str((i + 1) * 2) + " copies with half the original HP."


static func actions_after_die(_owner: Entity, _killed_by: Entity) -> void:
	var _learned_skill = _owner.get_learned_skill(NAME)
	if not _learned_skill: return

	if not _owner is Enemy: return
	if _owner.replicated: return

	var target_tiles = [
		Vector2(-MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
		Vector2(MapManager.TILE_SIZE.x, -MapManager.TILE_SIZE.y),
		Vector2(MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y),
		Vector2(-MapManager.TILE_SIZE.x, MapManager.TILE_SIZE.y)
	]
	for i in range(4):
		var new_enemy = ObjectHelpers.deep_clone(_owner) as Enemy
		new_enemy.replicated = true
		new_enemy.global_position = _owner.global_position + target_tiles[i]
		new_enemy.combat_stats.set_hp(new_enemy.get_full_health() * 0.5)
		new_enemy.set_current_hp_and_mana()
		GameManager.spawn_enemy(new_enemy)