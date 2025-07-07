extends Control
class_name HeroBox

@onready var texture_rect: TextureRect = $NinePatchRect/TextureRect
var hero_type: String
var player: Player
var is_selected := false

func set_hero_type(type: String):
	hero_type = type

func _ready():
	if not hero_type: return

	player = Player.new()
	HeroBase.initialize_from_name(hero_type, player)

	_set_texture()
	texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	texture_rect.gui_input.connect(_on_texture_rect_input)

func _set_texture():
	var atlas := AtlasTexture.new()
	atlas.atlas = SpritesHelper._ATLAS1
	atlas.region = player.extra_info.rects[0]
	texture_rect.texture = atlas

func _on_texture_rect_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EventBusHeroPicker.emit_hero_selected(player)
