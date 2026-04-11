## DefeatScreen — Schermata di sconfitta

extends Control

func _ready() -> void:
	DebugLogger.log_system("DefeatScreen: pronta")
	var turns := GameManager.turns_played
	$CenterContainer/VBox/StatsLabel.text = "Turni sopravvissuti: %d" % turns
	$CenterContainer/VBox/PlayAgainButton.pressed.connect(_on_play_again)
	$CenterContainer/VBox/MenuButton.pressed.connect(_on_menu)

func _on_play_again() -> void:
	GameManager.start_character_selection()

func _on_menu() -> void:
	GameManager.return_to_menu()
