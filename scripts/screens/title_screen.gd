## TitleScreen — Schermata iniziale

extends Control

func _ready() -> void:
	DebugLogger.log_system("TitleScreen: pronta")
	$CenterContainer/VBox/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBox/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	DebugLogger.log_system("TitleScreen: inizio selezione personaggio")
	GameManager.start_character_selection()

func _on_quit_pressed() -> void:
	get_tree().quit()
