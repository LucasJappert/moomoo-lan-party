class_name InitialScene
extends CanvasLayer

const HERO_PICKER_SCENE := preload("res://scenes/GUI/hero_picker_scene.tscn")
const HERO_BOX_SCENE := preload("res://scenes/GUI/hero_picker/hero_box.tscn")
const INITIAL_SCENE := preload("res://scenes/initial_scene.tscn")

const TIMER_TIME := 5
@onready var _logo: TextureRect = %TextureRectLogo
@onready var _logo1: Sprite2D = %Sprite2D
@onready var _particles_container: Node2D = %ParticlesContainer
# @onready var _grid_container: NinePatchRect = %GridContainer


func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", _spawn_particles_delayed)
	timer.wait_time = TIMER_TIME
	timer.one_shot = false
	timer.start()
	# HeroPickerScene.load_scene()
	_animate_logo()

	# Primer spawn inmediato sin delay
	_spawn_particles_immediately()

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


func _animate_logo() -> void:
	# Guarda la posición original del logo
	var original_position = _logo1.position
	
	# Crea un nuevo Tween
	var _tween = create_tween()
	_tween.set_loops() # Para que se repita indefinidamente
	_tween.set_trans(Tween.TRANS_SINE) # Para un movimiento suave
	_tween.set_ease(Tween.EASE_IN_OUT) # Para aceleración/desaceleración suave
	
	# Animación hacia abajo (20 píxeles)
	_tween.tween_property(_logo1, "position:y", original_position.y + 20, 3)
	# Animación de regreso a la posición original
	_tween.tween_property(_logo1, "position:y", original_position.y, 3)
