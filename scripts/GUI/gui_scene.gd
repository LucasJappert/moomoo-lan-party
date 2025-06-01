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
	_hp_ball.modulate = Color(1, 0.3, 0.3)
	_mana_ball.modulate = Color(0.2, 0.6, 1.0)
	_original_ball_size = _hp_ball.region_rect.size
	_original_ball_rect_pos_y = _hp_ball.region_rect.position.y
	# _skills_bar.set_visible(false)

func _process(_delta: float) -> void:
	if not Main.MY_PLAYER: return
	update_hp_ball_sprite()
	update_mana_ball_sprite()

func update_hp_ball_sprite():
	_update_ball_sprite(
		_hp_ball,
		Main.MY_PLAYER.combat_data.current_hp,
		Main.MY_PLAYER.combat_data.get_total_max_hp()
	)
func update_mana_ball_sprite():
	_update_ball_sprite(
		_mana_ball,
		Main.MY_PLAYER.combat_data.current_mana,
		Main.MY_PLAYER.combat_data.get_total_max_mana()
	)
func _update_ball_sprite(ball_sprite: Sprite2D, current_value: int, max_value: int) -> void:
	var percent: float = clamp(current_value / float(max_value), 0.0, 1.0)
	var visible_height := int(_original_ball_size.y * percent)
	var crop_from_top := _original_ball_size.y - visible_height

	ball_sprite.region_rect = Rect2(
		Vector2(ball_sprite.region_rect.position.x, _original_ball_rect_pos_y + crop_from_top),
		Vector2(_original_ball_size.x, visible_height)
	)

	ball_sprite.position.y = crop_from_top * 0.5

func _on_host_game_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_host()
	GameManager.spawn_moomoo()
	
	EnemiesWavesController.start_wave()
	
func _on_join_as_player_pressed() -> void:
	%MultiplayerHUD.hide()
	_skills_bar.set_visible(true)
	MultiplayerManager.become_client()
	# GameManager._spawn_moomoo()
