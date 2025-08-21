class_name Projectile

extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/general_objects/projectile.tscn")

var _origin_ref: Entity
var _target_ref: Entity
@onready var general_objects_container = %GeneralObjectsContainer
var is_extra_projectile := false
var speed: float = 400.0
var direction := Vector2.ZERO
var target_position := Vector2.ZERO
var origin_entity_name: String
var target_entity_name: String
var damage: int
var type: String
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

static var projectile_frames: Dictionary[String, SpriteFrames] = {}

var _tick_acc: float = 0.0
const FLY_TICK := 1.0 / 30.0 # 30 Hz
var _fly_action: Callable = Callable()

func _ready() -> void:
	var sf: SpriteFrames = sprite.sprite_frames # <- correcto en Godot 4
	if sf.has_animation("default") and sf.get_frame_count("default") <= 1:
		# Animación de 1 frame: dejalo estático (ahorra CPU)
		sprite.stop()
		sprite.animation = "default"
		sprite.frame = 0
	else: sprite.play("default")

	# Resolvemos 1 sola vez qué clase maneja este tipo
	for klass in ProjectileBase.REGISTERED_CLASSES:
		if klass.NAME == type:
			_fly_action = Callable(klass, "actions_while_flying")
			break

	# try_init de la clase concreta (si lo usás)
	for registered_class in ProjectileBase.REGISTERED_CLASSES:
		registered_class.try_init(self)

func _process(_delta: float) -> void:
	pass

# Nuevo: enlazás referencias directas (y mantenés los nombres por compatibilidad/red)
func bind_refs(origin: Entity, target: Entity) -> void:
	_origin_ref = origin
	_target_ref = target
	origin_entity_name = origin.name
	target_entity_name = target.name

func get_target_entity() -> Entity:
	return GameManager.get_entity(target_entity_name)

func _get_origin_entity() -> Entity:
	return GameManager.get_entity(origin_entity_name)

func _physics_process(delta: float) -> void:
	if MainScene.PAUSED: return
	_server_move(delta)

	_tick_acc += delta
	if _tick_acc >= FLY_TICK:
		_tick_acc = 0.0
		_update_rotation_and_fx() # se llama ~30 veces/seg

func _update_rotation_and_fx() -> void:
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	# Llamamos SOLO a la clase que corresponde (ver 2b)
	if _fly_action.is_valid():
		_fly_action.call(self)

func _server_move(delta: float):
	if not multiplayer.is_server(): return

	if _target_ref == null and target_entity_name != "":
		_target_ref = GameManager.get_entity(target_entity_name)

	if _target_ref != null:
		target_position = _target_ref.projectile_zone.global_position
		direction = (target_position - position)
		# (rotación la pasamos a un tick más bajo, ver punto 2)
	
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta

	if position.distance_to(target_position) < 10:
		_projectile_reached_target()

func _projectile_reached_target():
	if get_target_entity() != null && _get_origin_entity() != null:
		_get_origin_entity().server_execute_physical_damage(get_target_entity(), is_extra_projectile)
	for reg_proj in ProjectileBase.REGISTERED_CLASSES: reg_proj.actions_on_reaching_target(self)
	queue_free()

static func get_instance_from_dict(dict: Dictionary) -> Projectile:
	var instance = PROJECTILE_SCENE.instantiate()
	ObjectHelpers.from_dict(instance, dict)
	return instance

static func launch(_origin: Entity, _target: Entity, _damage: int, _extra_projectile: bool = false):
	# Seguir viendo la baja de FPS, al parecer puede que sea por los fors para las clases/items registradas
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.is_extra_projectile = _extra_projectile
	projectile.type = _origin.projectile_type
	projectile.damage = _damage
	projectile.origin_entity_name = _origin.name
	projectile.target_entity_name = _target.name
	projectile.position = _origin.projectile_zone.global_position
	projectile.target_position = _target.projectile_zone.global_position
	projectile.direction = (projectile.target_position - projectile.position).normalized()
	projectile.rotation = projectile.direction.angle()

	# 👇 cache refs locales para evitar GameManager.get_entity() por frame
	projectile.bind_refs(_origin, _target)

	GameManager.add_projectile(projectile)
	projectile.queue_free()
