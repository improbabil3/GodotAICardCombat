## BattleResultScreen — Schermata di resoconto inter-battaglia
##
## Mostra il riepilogo dell'ultimo scontro vinto: nemico sconfitto,
## punteggio, turni, HP rimasti e prossimo avversario.
## Il pulsante "Continua" avvia il combattimento successivo
## tramite GameManager.continue_run().

extends Control

func _ready() -> void:
	DebugLogger.log_system("BattleResultScreen: pronta")

	var r: Dictionary = GameManager.last_result
	if r.is_empty():
		DebugLogger.log_error("BattleResultScreen: last_result vuoto, impossibile mostrare il recap")
		return

	$CenterContainer/VBox/TitleLabel.text = (
		"Scontro %d/%d — Completato!" % [r["encounter_num"], r["total_encounters"]]
	)

	$CenterContainer/VBox/EnemyLabel.text = (
		"%s  [%s]" % [r["enemy_name"], r["enemy_type_label"]]
	)

	var stats: Array[String] = []
	stats.append("Turni impiegati:  %d" % r["turns"])
	stats.append("HP rimasti:  %d / %d" % [r["hp_remaining"], Config.player_max_hp])
	$CenterContainer/VBox/StatsLabel.text = "\n".join(stats)

	$CenterContainer/VBox/ScoreLabel.text = (
		"Punteggio scontro:  %.0f pt" % r["score"]
	)
	$CenterContainer/VBox/TotalScoreLabel.text = (
		"Totale run:  %.0f pt" % GameManager.total_score()
	)

	var next_enemy := GameManager.get_current_enemy()
	if next_enemy != null:
		$CenterContainer/VBox/NextEnemyLabel.text = (
			"Prossimo:  %s  [%s]" % [next_enemy.enemy_name, next_enemy.type_label()]
		)
	else:
		$CenterContainer/VBox/NextEnemyLabel.visible = false

	$CenterContainer/VBox/ContinueButton.pressed.connect(_on_continue)

func _on_continue() -> void:
	GameManager.continue_run()
