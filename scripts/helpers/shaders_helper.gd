class_name ShadersHelper

static func set_dissolve_shader_material(_node: Node, particles_scale := 2.0) -> void:
	var shader := load("res://shaders/dissolve.gdshader")
	var material := ShaderMaterial.new()
	material.shader = shader

	var noise_texture := load("res://assets/noise_dissolve.png")
	material.set_shader_parameter("noise_texture", noise_texture)
	material.set_shader_parameter("dissolve_amount", 0.0)
	material.set_shader_parameter("noise_scale", particles_scale) # 👈 cuanto mayor, más pequeñas las "partículas"

	_node.material = material

static func set_distortion_shader_material(sprite: AnimatedSprite2D, scroll_speed := 1.0, distortion_strength := 0.03) -> void:
	var shader := load("res://shaders/flame_distortion.gdshader")
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("scroll_speed", scroll_speed)
	material.set_shader_parameter("distortion_strength", distortion_strength)

	sprite.material = material
