## BattleResultScreen — Schermata di resoconto inter-battaglia
##
## Mostra il riepilogo dell'ultimo scontro vinto: nemico sconfitto,
## punteggio, turni, HP rimasti e prossimo avversario.
## Il pulsante "Continua" avvia il combattimento successivo
## tramite GameManager.continue_run().

extends Control

@onready var _content_panel: PanelContainer = $CenterContainer/ContentPanel
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBox
@onready var _title_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/TitleLabel
@onready var _enemy_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/EnemyLabel
@onready var _portrait_row: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow
@onready var _player_card: PanelContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard
@onready var _player_portrait: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard/PlayerVBox/PlayerPortrait
@onready var _player_name: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard/PlayerVBox/PlayerName
@onready var _enemy_card: PanelContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard
@onready var _enemy_portrait: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard/EnemyVBox/EnemyPortrait
@onready var _enemy_name: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard/EnemyVBox/EnemyName
@onready var _stats_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/StatsLabel
@onready var _score_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/ScoreLabel
@onready var _total_score_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/TotalScoreLabel
@onready var _next_enemy_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/NextEnemyLabel
@onready var _continue_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBox/ContinueButton

func _ready() -> void:
	DebugLogger.log_system("BattleResultScreen: pronta")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()

	var r: Dictionary = GameManager.last_result
	if r.is_empty():
		DebugLogger.log_error("BattleResultScreen: last_result vuoto, impossibile mostrare il recap")
		return

	_title_label.text = (
		"Scontro %d/%d — Completato!" % [r["encounter_num"], r["total_encounters"]]
	)

	_enemy_label.text = (
		"%s  [%s]" % [r["enemy_name"], r["enemy_type_label"]]
	)
	_populate_portraits(String(r["enemy_name"]))

	var stats: Array[String] = []
	stats.append("Turni impiegati:  %d" % r["turns"])
	stats.append("HP rimasti:  %d / %d" % [r["hp_remaining"], Config.player_max_hp])
	_stats_label.text = "\n".join(stats)

	_score_label.text = (
		"Punteggio scontro:  %.0f pt" % r["score"]
	)
	_total_score_label.text = (
		"Totale run:  %.0f pt" % GameManager.total_score()
	)

	var next_enemy := GameManager.get_current_enemy()
	if next_enemy != null:
		_next_enemy_label.text = (
			"Prossimo:  %s  [%s]" % [next_enemy.enemy_name, next_enemy.type_label()]
		)
	else:
		_next_enemy_label.visible = false

	_continue_button.pressed.connect(_on_continue)


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var compact_touch_ui := OS.has_feature("mobile") or viewport_size.x <= 900.0 or viewport_size.y <= 720.0
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(viewport_size.x - (24.0 if compact_touch_ui else 96.0), 300.0, 620.0 if compact_touch_ui else 760.0)
	var portrait_card_width: float = clampf(content_width * (0.42 if portrait_layout else 0.30), 128.0, 190.0)
	var portrait_size: float = clampf(portrait_card_width - 32.0, 104.0, 152.0)
	var button_width: float = clampf(content_width * 0.56, 220.0, 320.0)
	var button_height: float = 58.0 if compact_touch_ui else 54.0
	_content_panel.custom_minimum_size = Vector2(content_width, 0.0)
	_layout_box.custom_minimum_size = Vector2(content_width - 56.0, 0.0)
	_layout_box.add_theme_constant_override("separation", 16 if compact_touch_ui else 18)
	_portrait_row.add_theme_constant_override("separation", 12 if compact_touch_ui else 18)
	_title_label.add_theme_font_size_override("font_size", 34 if compact_touch_ui else 42)
	_enemy_label.add_theme_font_size_override("font_size", 19 if compact_touch_ui else 22)
	_stats_label.add_theme_font_size_override("font_size", 16 if compact_touch_ui else 18)
	_score_label.add_theme_font_size_override("font_size", 20 if compact_touch_ui else 22)
	_total_score_label.add_theme_font_size_override("font_size", 15 if compact_touch_ui else 16)
	_next_enemy_label.add_theme_font_size_override("font_size", 15 if compact_touch_ui else 17)
	_continue_button.custom_minimum_size = Vector2(button_width, button_height)
	_continue_button.add_theme_font_size_override("font_size", 20 if compact_touch_ui else 22)
	_player_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 62.0)
	_enemy_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 62.0)
	_player_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_enemy_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_player_name.add_theme_font_size_override("font_size", 14 if compact_touch_ui else 16)
	_enemy_name.add_theme_font_size_override("font_size", 14 if compact_touch_ui else 16)


func _populate_portraits(enemy_name: String) -> void:
	var selected_character: CharacterData = GameManager.selected_character
	if selected_character != null:
		_player_name.text = selected_character.name
		_player_portrait.texture = PortraitLibrary.load_portrait(selected_character.character_id, "result")
	else:
		_player_name.text = "Pilota"
		_player_portrait.texture = PortraitLibrary.load_portrait("player_default", "result")

	_enemy_name.text = enemy_name
	_enemy_portrait.texture = PortraitLibrary.load_named_portrait(enemy_name, "result")

func _on_continue() -> void:
	GameManager.continue_run()
