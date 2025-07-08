class_name ShadersHelper

static func set_dissolve_shader_material(entity: Entity) -> void:
	var shader := load("res://shaders/dissolve.gdshader")
	var material := ShaderMaterial.new()
	material.shader = shader

	var noise_texture := load("res://assets/noise_dissolve.png")
	material.set_shader_parameter("noise_texture", noise_texture)
	material.set_shader_parameter("dissolve_amount", 0.0)
	material.set_shader_parameter("noise_scale", 2.0) # 👈 cuanto mayor, más pequeñas las "partículas"

	entity.sprite.material = material
