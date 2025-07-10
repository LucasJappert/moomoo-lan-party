class_name ProjectileArcLightning

extends ProjectileBase

const TYPE = "arc_lightning"
const VOLUME: float = -10

static func try_init(_projectile: Projectile):
	if _projectile.type != TYPE: return


static func try_launch(_proj_type: String, _entity: Entity, _target: Entity, _damage: int) -> bool:
	if _proj_type != TYPE: return false

	SoundsHelper.play_electric(VOLUME)
	LineEffect.spawn(GameManager.game_world.general_container, _entity.projectile_zone.global_position, _target.projectile_zone.global_position, 0.1, 0.4)
	_entity.server_execute_physical_damage(_target)
	return true