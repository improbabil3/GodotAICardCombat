## VictoryScreen — Schermata di vittoria

extends Control

func _ready() -> void:
	DebugLogger.log_system("VictoryScreen: pronta")
	var turns := GameManager.turns_played
	var hp_summary := GameManager.player_hp_summary()
	$CenterContainer/VBox/StatsLabel.text = "Turni giocati: %d  |  HP rimasti: %s" % [turns, hp_summary]
	$CenterContainer/VBox/PlayAgainButton.pressed.connect(_on_play_again)
	$CenterContainer/VBox/MenuButton.pressed.connect(_on_menu)

func _on_play_again() -> void:
	GameManager.start_character_selection()

func _on_menu() -> void:
	GameManager.return_to_menu()
