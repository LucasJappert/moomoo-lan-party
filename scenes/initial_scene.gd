class_name InitialScene
extends CanvasLayer

const HERO_PICKER_SCENE := preload("res://scenes/GUI/hero_picker_scene.tscn")
const HERO_BOX_SCENE := preload("res://scenes/GUI/hero_picker/hero_box.tscn")
const INITIAL_SCENE := preload("res://scenes/initial_scene.tscn")

const TIMER_TIME := 5
@onready var _logo: Sprite2D = %Sprite2D
@onready var _particles_container: Node2D = %ParticlesContainer
@onready var _text_typer_scene: TextTyperScene = %TextTyperScene
@onready var _spanish_button: MyCheckScene = %SpanishButton
@onready var _english_button: MyCheckScene = %EnglishButton
@onready var _lang_ok_button: MyButton = %LangOkButton
@onready var _lang_picker_panel: Panel = %LangPickerPanel
# @onready var _grid_container: NinePatchRect = %GridContainer


func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", _spawn_particles_delayed)
	timer.wait_time = TIMER_TIME
	timer.one_shot = false
	timer.start()

	_spawn_particles_immediately() # Primer spawn inmediato sin delay

	_spanish_button.on_pressed = _on_spanish_button_pressed
	_english_button.on_pressed = _on_english_button_pressed
	_lang_ok_button.on_pressed = _start_scene


func _spawn_particles_immediately() -> void:
	var screen := get_viewport().get_visible_rect().size
	for i in range(100):
		ParticleEffects.spawn_floating_particle(screen, _particles_container, randi_range(6, 12))

func _spawn_particles_delayed() -> void:
	spawn_particles_with_delay(80, 0.1)

func spawn_particles_with_delay(amount: int, delay: float) -> void:
	var screen := get_viewport().get_visible_rect().size
	for i in range(amount):
		ParticleEffects.spawn_floating_particle(screen, _particles_container, randi_range(6, 12))
		await get_tree().create_timer(delay).timeout


# region	SETTERS
static func load_scene() -> void:
	var scene = INITIAL_SCENE.instantiate()
	GameManager.main_scene.load_scene(scene)

func _start_scene() -> void:
	if not LanguageManager.initialized(): return

	# Hacemos aparecer el logo y luego la animacion tanto del logo como del texto de la historia
	var _appear_tween = create_tween()
	_appear_tween.tween_property(_lang_picker_panel, "modulate:a", 0, 1)
	_appear_tween.tween_callback(func():
		_lang_picker_panel.visible = false
		_animate_logo()
		_text_typer_scene.show_me()
	)

	# Creamos el efecto de fuego en el fondo de la pantalla
	# var screen_size = get_viewport().get_visible_rect().size
	# for x in range(0, screen_size.x, 20):
	# 	FireEffect.spawn_fire_effect(_particles_container, Vector2(x, screen_size.y), 0, 2)

func _animate_logo() -> void:
	# Guarda la posición original del logo
	var original_position = _logo.position
	
	# Crea un nuevo Tween
	var _tween = create_tween()
	_tween.set_loops() # Para que se repita indefinidamente
	_tween.set_trans(Tween.TRANS_SINE) # Para un movimiento suave
	_tween.set_ease(Tween.EASE_IN_OUT) # Para aceleración/desaceleración suave
	
	# Animación hacia abajo (20 píxeles)
	_tween.tween_property(_logo, "position:y", original_position.y + 20, 3)
	# Animación de regreso a la posición original
	_tween.tween_property(_logo, "position:y", original_position.y, 3)

func _on_spanish_button_pressed():
	LanguageManager.set_spanish()
	_english_button.set_checked(false)

func _on_english_button_pressed():
	LanguageManager.set_english()
	_spanish_button.set_checked(false)
