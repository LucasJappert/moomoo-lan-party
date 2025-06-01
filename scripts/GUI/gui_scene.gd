extends CanvasLayer

@onready var _skills_bar = $BottomCenterAnchor/SkillsBar


func _ready() -> void:
	%HostGameButton.connect("pressed", _on_host_game_pressed)
	%JoinAsPlayerButton.connect("pressed", _on_join_as_player_pressed)
	%MultiplayerHUD.show()
	# _skills_bar.set_visible(false)

func _process(_delta: float) -> void:
	var texture_size = _skills_bar.texture.get_size()
	_skills_bar.position = Vector2(Main.SCREEN_SIZE.x / 2, Main.SCREEN_SIZE.y - texture_size.y / 2)

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
