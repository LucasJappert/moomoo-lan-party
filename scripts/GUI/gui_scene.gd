extends CanvasLayer

@onready var _skills_bar = $SkillsBarContainer/SkillsBar
@onready var _hp_ball = $SkillsBarContainer/HpBall
@onready var _mana_ball = $SkillsBarContainer/ManaBall

var _original_ball_size: Vector2
var _original_ball_rect_pos_y: float


func _ready() -> void:
	if multiplayer.is_server() && not Main.HOSTED_GAME: return

	%HostGameButton.connect("pressed", _on_host_game_pressed)
	%JoinAsPlayerButton.connect("pressed", _on_join_as_player_pressed)
	%MultiplayerHUD.show()
	_hp_ball.modulate = Color(1, 0.3, 0.3, 1)
	_mana_ball.modulate = Color(0.3, 0.3, 1, 1)
	_original_ball_size = _hp_ball.region_rect.size
	_original_ball_rect_pos_y = _hp_ball.region_rect.position.y
	# _skills_bar.set_visible(false)

func _process(_delta: float) -> void:
	if not Main.MY_PLAYER: return
	update_hp_bar_sprite()
	pass

func update_hp_bar_sprite():
	# Update the HP bar sprite based on the current HP percentage
	var current_hp = Main.MY_PLAYER.combat_data.current_hp
	var max_hp = Main.MY_PLAYER.combat_data.max_hp
	var percent: float = clamp(current_hp / float(max_hp), 0.0, 1.0)
	var visible_height := int(_original_ball_size.y * percent)
	var crop_from_top := _original_ball_size.y - visible_height

	# Update the region
	_hp_ball.region_rect = Rect2(
		Vector2(_hp_ball.region_rect.position.x, _original_ball_rect_pos_y + crop_from_top),
		Vector2(_original_ball_size.x, visible_height)
	)

	# Adjust the Y position to keep the base steady
	_hp_ball.position.y = crop_from_top * 0.5

func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_host()
	_spawn_moomoo()
	
	EnemiesWavesController.start_wave()
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_client()
	_spawn_moomoo()

func _spawn_moomoo() -> void:
	GameManager.moomoo = load("res://scenes/entity/moomoo_scene.tscn").instantiate()
	GameManager.moomoo_node.add_child(GameManager.moomoo, true)
	MapManager.set_cell_blocked_from_world(GameManager.moomoo.global_position, true)
