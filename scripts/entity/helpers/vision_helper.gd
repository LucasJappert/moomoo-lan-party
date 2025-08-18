# VisionHelper.gd
class_name VisionHelper
extends MyInitAuxiliary

var DEFAULT_RADIUS_IN_PIXEL: int = MapManager.TILE_SIZE_INT * 12
const RECT_REGION := Rect2(0, 1216, 96, 96)
var radius_in_pixel: int = DEFAULT_RADIUS_IN_PIXEL
var redius_in_tiles: int = int(radius_in_pixel / MapManager.TILE_SIZE_FLOAT)
var color := Color.WHITE

var _owner_entity: Entity = null
var _sprite: Sprite2D = null
var _hovered: bool = false
var _last_visible: bool = false
var _tex_w: float = 0.0

func _init(p_owner: Entity = null, p_radius: int = DEFAULT_RADIUS_IN_PIXEL, p_color: Color = Color.WHITE) -> void:
	super._init()
	_owner_entity = p_owner
	radius_in_pixel = p_radius
	redius_in_tiles = int(radius_in_pixel / MapManager.TILE_SIZE_FLOAT)
	color = p_color
	if not p_owner: return

	_build_sprite()

	# Conectar señal (NOMBRE CORRECTO DEL HANDLER)
	EventBus.connect_to_hovered_entity_changed(Callable(self, "_on_hovered_entity_changed"))

	# --- SINCRONIZAR ESTADO INICIAL ---
	# Si ya hay una entidad hovereada, arrancamos en el estado correcto
	# (ajustá la referencia si AreaHovered vive en otro lado)
	if AreaHovered.hovered_entity != null and is_instance_valid(AreaHovered.hovered_entity):
		_hovered = (AreaHovered.hovered_entity == _owner_entity)
	else:
		_hovered = false

	# Forzar visibilidad acorde al estado actual (ALT puede estar presionada o no)
	var should_show := _hovered and KeyboardController.ALT_PRESSED
	_sprite.visible = should_show
	_last_visible = should_show

func set_radius(p_radius: int) -> void:
	if float(radius_in_pixel) == float(p_radius):
		return
	radius_in_pixel = p_radius
	redius_in_tiles = int(radius_in_pixel / MapManager.TILE_SIZE_FLOAT)
	_apply_radius_scale()

func set_color(p_color: Color) -> void:
	color = p_color
	if is_instance_valid(_sprite):
		_sprite.modulate = color

func process() -> void:
	if not is_instance_valid(_sprite):
		return
	if not is_instance_valid(_owner_entity):
		_hovered = false

	# Mostrar solo si hay hover + ALT presionada
	var should_show := _hovered and KeyboardController.ALT_PRESSED
	if should_show != _last_visible:
		_sprite.visible = should_show
		_last_visible = should_show

	_apply_radius_scale()

func _build_sprite() -> void:
	_clear_sprite()
	_sprite = SpritesHelper.get_sprite_2d(RECT_REGION)
	_sprite.centered = true
	_sprite.modulate = color
	_sprite.visible = false

	# Asegurate que este nodo existe y es Node2D
	_owner_entity.back_animations_node.add_child(_sprite)

	# Tomar tamaño de la región (AtlasTexture respeta la región)
	if _sprite.texture != null:
		var sz := _sprite.texture.get_size()
		_tex_w = max(min(sz.x, sz.y), 0.0001) # usa el menor por si no es cuadrada
	else:
		_tex_w = 1.0

	_apply_radius_scale()

func _apply_radius_scale() -> void:
	if not is_instance_valid(_sprite) or _tex_w <= 0.0:
		return
	var uniform := (2.0 * float(radius_in_pixel)) / _tex_w # diámetro = 2*radius_in_pixel
	_sprite.scale = Vector2(uniform, uniform)

func _clear_sprite() -> void:
	if is_instance_valid(_sprite):
		_sprite.queue_free()
	_sprite = null
	_tex_w = 0.0

# NOMBRE DEL HANDLER QUE COINCIDE CON EL connect()
func _on_hovered_entity_changed(new_e: Entity, _prev_e: Entity) -> void:
	_hovered = (new_e == _owner_entity)
