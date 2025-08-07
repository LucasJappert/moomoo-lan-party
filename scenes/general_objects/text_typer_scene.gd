class_name TextTyperScene
extends Control

@onready var _panel: NinePatchRect = %Panel
@onready var _description: RichTextLabel = %Description
@onready var _aux_description: RichTextLabel = %AuxDescription
@onready var _description_button: MyButton = %DescriptionButton

const TYPING_SPEED = 0.02 # Segundos entre caracteres
const BUTTON_HEIGHT: int = 80

var _current_text: String = ""
var _displayed_text: String = ""
var _typing_timer: float = 0.05
var _is_typing: bool = false

var dialogs: Array[String] = [
	"Millennia ago, the Eternal Lands were protected by an ancient creature known as MooMoo — a mystical being who preserved balance between chaos and harmony.",
	"Its energy was said to be the world’s life source... but locked deep within its core slumbered a forbidden power: the Primordial Heart.  

Over time, civilizations forgot its purpose and began to worship it as a sleeping god.  
But now... something has disturbed its slumber."
]
var _current_dialog_index: int = 0

func _ready() -> void:
	_panel.visible = false
	_panel.modulate.a = 0.8
	_aux_description.bbcode_enabled = true
	_aux_description.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description.bbcode_enabled = true
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description_button.on_pressed = _next_dialog
	_next_dialog()

func _process(delta: float) -> void:
	if _is_typing:
		_typing_timer += delta
		if _typing_timer > TYPING_SPEED:
			_type_next_character()
			# _type_next_character()
			_typing_timer = 0

func _next_dialog() -> void:
	if _current_dialog_index < dialogs.size():
		show_text(dialogs[_current_dialog_index])
		_current_dialog_index += 1
		return

	# Mostramos la escena de selección de héroes

func show_text(text: String) -> void:
	_current_text = text
	_displayed_text = ""
	_is_typing = true
	_typing_timer = TYPING_SPEED
	_panel.visible = true
	_description.text = "" # Limpiar el texto anterior
	_aux_description.text = text
	var description_height = _aux_description.get_content_height()
	_description.set_size(Vector2(_description.get_size().x, description_height))
	var new_size := Vector2(_panel.get_size().x, description_height + BUTTON_HEIGHT + 20)
	_panel.set_size(new_size)
	set_size(new_size)
	print(position.y)
	position.y = get_viewport().get_visible_rect().size.y - new_size.y
	print(position.y)


func _type_next_character() -> void:
	if _displayed_text.length() >= _current_text.length():
		_is_typing = false
		return

	_displayed_text = _current_text.substr(0, _displayed_text.length() + 1)
	_description.text = _displayed_text

func hide_me() -> void:
	_panel.visible = false
	_is_typing = false
	_current_text = ""
	_displayed_text = ""
	_aux_description.text = ""

# Función para saltar la animación y mostrar todo el texto inmediatamente
func skip_typing() -> void:
	if _is_typing:
		_description.text = _current_text
		_is_typing = false
		_displayed_text = _current_text
		_aux_description.text = _current_text

# Funciones estáticas para fácil acceso
static func static_show(text: String) -> void:
	GameManager.main_scene.text_typer_scene.show_text(text)

static func static_hide_me() -> void:
	GameManager.main_scene.text_typer_scene.hide_me()

static func skip() -> void:
	GameManager.main_scene.text_typer_scene.skip_typing()