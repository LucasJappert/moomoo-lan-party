class_name ShadersHelper

const BORDER_SHADER := preload("res://shaders/border_shader.gdshader")
const DISSOLVE_SHADER := preload("res://shaders/dissolve.gdshader")
const NOISE_DISSOLVE := preload("res://assets/noise_dissolve.png")

static func set_dissolve_shader_material(_node: Node, particles_scale := 2.0) -> void:
	var material := ShaderMaterial.new()
	material.shader = DISSOLVE_SHADER

	material.set_shader_parameter("noise_texture", NOISE_DISSOLVE)
	material.set_shader_parameter("dissolve_amount", 0.0)
	material.set_shader_parameter("noise_scale", particles_scale) # 👈 cuanto mayor, más pequeñas las "partículas"

	_node.material = material

static func apply_border_shader(entity: Entity, shader_name: String, replace_existing: bool, color: Color = Color(1.0, 0.5, 0.0, 1.0)) -> void:
	if entity.current_hp <= 0: return
	if not replace_existing and entity.body_sprite.material != null: return
	
	var border_shader := ShaderMaterial.new()
	border_shader.shader = BORDER_SHADER
	border_shader.set_shader_parameter("my_name", shader_name)

	# Asegúrate de que el sprite tenga un SpriteFrames asignado
	if entity.body_sprite.sprite_frames != null:
		var animation = entity.body_sprite.animation # Nombre de la animación actual
		var frame = entity.body_sprite.frame # Frame actual en la animación
		
		# Obtén la textura del frame actual (asumiendo que es un AtlasTexture)
		var texture = entity.body_sprite.sprite_frames.get_frame_texture(animation, frame)
		
		if texture is AtlasTexture:
			# Obtén la región del frame en el atlas
			var region = texture.region
			border_shader.set_shader_parameter("frame_offset", region.position)
			border_shader.set_shader_parameter("frame_size", region.size)
		else:
			# Si no es un atlas, desactiva el outline o usa valores por defecto
			border_shader.set_shader_parameter("frame_size", entity.body_sprite.texture.get_size())
			border_shader.set_shader_parameter("frame_offset", Vector2.ZERO)

	border_shader.set_shader_parameter("outline_color", color)
	entity.body_sprite.material = border_shader

static func clear_border_shader(entity: Entity, shader_name: String) -> void:
	if entity.current_hp <= 0: return
	if not entity.body_sprite.material: return
	if entity.body_sprite.material.get_shader_parameter("my_name") != shader_name: return

	entity.body_sprite.material = null