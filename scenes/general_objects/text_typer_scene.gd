class_name TextTyperScene
extends Control

@onready var _panel: NinePatchRect = %Panel
@onready var _description: RichTextLabel = %Description
@onready var _aux_description: RichTextLabel = %AuxDescription
@onready var _my_button: MyButton = %MyButton
# @onready var _particles_container: PanelContainer = %ParticlesContainer

const TYPING_SPEED = 0.02 # Segundos entre caracteres
const BUTTON_HEIGHT: int = 80

var _current_text: String = ""
var _displayed_text: String = ""
var _typing_timer: float = 0.05
var _is_typing: bool = false

var english_dialogs: Array[String] = [
	"Millennia ago, the Eternal Lands were protected by an ancient creature known as MooMoo — a mystical being who preserved the balance between chaos and harmony...",
	"It was said that its energy was the life source of the world... but deep within its core pulsed a forbidden power: the Seed of Chaos.",
	"Over time, civilizations forgot its purpose and began to worship it as a sleeping god.\nBut now... something has disturbed its slumber..."
]
var spanish_dialogs: Array[String] = [
	"Hace milenios, las Tierras Eternas estaban protegidas por una criatura ancestral conocida como MooMoo, un ser místico que preservaba el equilibrio entre el caos y la armonía...",
	"Se decía que su energía era la fuente de vida del mundo... pero en lo profundo de su núcleo latía un poder prohibido: la Semilla del Caos.",
	"Con el paso del tiempo, las civilizaciones olvidaron su propósito y comenzaron a adorarlo como a un dios dormido.\nPero ahora... algo ha perturbado su reposo..."
]

var _current_dialog_index: int = 0

func _ready() -> void:
	_panel.visible = false
	_panel.modulate.a = 0
	_my_button.modulate.a = 0
	_aux_description.bbcode_enabled = true
	_aux_description.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description.text = ""
	_description.bbcode_enabled = true
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD
	_my_button.on_pressed = _next_dialog

	EventBus.connect_to_lang_changed(func():
		_update_my_button("Next" if LanguageManager.is_english() else "Siguiente")
	)

func _process(delta: float) -> void:
	if _is_typing:
		_typing_timer += delta
		if _typing_timer > TYPING_SPEED:
			_type_next_character()
			# _type_next_character()
			_typing_timer = 0

func _next_dialog() -> void:
	_current_dialog_index += 1
	if _current_dialog_index <= english_dialogs.size():
		show_text(_get_dialog(_current_dialog_index - 1))
	
	if _current_dialog_index == english_dialogs.size():
		var text_button := "The world needs a defender — Choose Your Hero" if LanguageManager.is_english() else "El mundo necesita un defensor — Elige a tu héroe"
		_my_button.text = text_button
		_update_my_button(text_button)
		_my_button.on_pressed = HeroPickerScene.load_scene

func show_text(text: String) -> void:
	_current_text = text
	_displayed_text = ""
	_is_typing = true
	_typing_timer = TYPING_SPEED
	_description.text = "" # Limpiar el texto anterior
	_aux_description.text = text
	var description_height = _aux_description.get_content_height()
	_description.set_size(Vector2(_description.get_size().x, description_height))
	var new_size := Vector2(_panel.get_size().x, description_height + BUTTON_HEIGHT + 20)
	_panel.set_size(new_size)
	set_size(new_size)
	position.y = get_viewport().get_visible_rect().size.y - new_size.y

func _type_next_character() -> void:
	if _displayed_text.length() >= _current_text.length():
		_is_typing = false
		return

	_displayed_text = _current_text.substr(0, _displayed_text.length() + 1)
	_description.text = _displayed_text

func _update_my_button(_text: String) -> void:
	_my_button.text = _text
	_my_button.position.x = _panel.size.x * 0.5 - _my_button.size.x * 0.5

func show_me() -> void:
	# Creamos el efecto de fuego en el fondo de la pantalla
	# for x in range(40, _panel.size.x + 20, 20):
	# 	FireEffect.spawn_fire_effect(_particles_container, Vector2(x, 0 - 15), 0, 2)
	_panel.visible = true
	const DURATION := 0.8
	var tween_button := create_tween()
	tween_button.tween_property(_my_button, "modulate:a", DURATION, 1)
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", DURATION, 1)
	tween.tween_callback(func(): _next_dialog())

func hide_me() -> void:
	_panel.visible = false
	_is_typing = false
	_current_text = ""
	_displayed_text = ""
	_aux_description.text = ""

func skip_typing() -> void:
	if _is_typing:
		_description.text = _current_text
		_is_typing = false
		_displayed_text = _current_text
		_aux_description.text = _current_text

func _get_dialog(index: int) -> String:
	return english_dialogs[index] if LanguageManager.is_english() else spanish_dialogs[index]