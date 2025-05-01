extends Node2D


func _on_host_game_pressed() -> void:
    print("Join as player")
    %MultiplayerHUD.hide()
    MultiplayerManager.become_host()
    
func _on_join_as_player_pressed() -> void:
    print("Host new game")
    %MultiplayerHUD.hide()
    MultiplayerManager.become_client()
