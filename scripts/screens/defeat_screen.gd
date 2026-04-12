## DefeatScreen — Schermata di sconfitta

extends Control

func _ready() -> void:
	DebugLogger.log_system("DefeatScreen: pronta")

	var rating := GameManager.run_rating()
	var rating_desc := GameManager.rating_description(rating)
	var total := GameManager.total_score()

	# Riga punteggi per incontri vinti
	var score_lines: Array[String] = []
	for i in range(GameManager.run_scores.size()):
		var enemy_data: EnemyData = GameManager.enemy_roster[i] if i < GameManager.enemy_roster.size() else null
		var enemy_name := enemy_data.enemy_name if enemy_data != null else "Nemico %d" % (i + 1)
		score_lines.append("Scontro %d — %s: %.0f pt" % [i + 1, enemy_name, GameManager.run_scores[i]])

	# Scontro perso
	var defeated_idx := GameManager.run_defeated_at
	if defeated_idx >= 0 and defeated_idx < GameManager.enemy_roster.size():
		var lost_enemy: EnemyData = GameManager.enemy_roster[defeated_idx]
		score_lines.append("Scontro %d — %s: SCONFITTA" % [defeated_idx + 1, lost_enemy.enemy_name])

	score_lines.append("─────────────────────────")
	score_lines.append("Punteggio totale: %.0f pt" % total)

	$CenterContainer/VBox/StatsLabel.text = "\n".join(score_lines)
	$CenterContainer/VBox/RatingLabel.text = "Rating: %s — %s" % [rating, rating_desc]
	$CenterContainer/VBox/PlayAgainButton.pressed.connect(_on_play_again)
	$CenterContainer/VBox/MenuButton.pressed.connect(_on_menu)

func _on_play_again() -> void:
	GameManager.return_to_menu()
	GameManager.start_character_selection()

func _on_menu() -> void:
	GameManager.return_to_menu()
