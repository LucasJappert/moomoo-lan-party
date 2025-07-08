extends Control
class_name HeroBox

const COLOR_TINT_SHADER := preload("res://shaders/color_tint.gdshader")

@onready var texture_rect: TextureRect = $NinePatchRect/TextureRect
@onready var bg_panel: NinePatchRect = %NinePatchRect

var shader_material: ShaderMaterial
var hero_type: String
var player: Player
var is_selected := false

func set_hero_type(type: String):
	hero_type = type

func _ready():
	shader_material = ShaderMaterial.new()
	shader_material.shader = COLOR_TINT_SHADER
	bg_panel.material = shader_material

	if not hero_type:
		set_disabled_effect()
		set_texture()
		return

	player = Player.new()
	HeroBase.initialize_from_name(hero_type, player)

	set_texture(player.extra_info.rects[0])
	texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	texture_rect.gui_input.connect(_on_texture_rect_input)

func set_texture(rect: Rect2 = Rect2(0, 0, 1, 1)):
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = SpritesHelper._ATLAS1
	atlas_texture.region = rect
	texture_rect.texture = atlas_texture

func _on_texture_rect_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EventBusHeroPicker.emit_hero_selected(player)

func set_disabled_effect():
	# Subtle black tint (slightly darkens)
	shader_material.set_shader_parameter("tint_color", Color(0.0, 0.0, 0.0))
	shader_material.set_shader_parameter("tint_strength", 0.3) # Adjust if you want it darker

func set_selected_effect(enabled: bool):
	is_selected = enabled

	if is_selected:
		shader_material.set_shader_parameter("tint_strength", 0.1) # Very subtle
		return
	shader_material.set_shader_parameter("tint_strength", 0.0)
