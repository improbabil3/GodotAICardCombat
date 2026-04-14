## VictoryScreen — Schermata di vittoria

extends Control

@onready var _content_panel: PanelContainer = $CenterContainer/ContentPanel
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBox
@onready var _victory_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/VictoryLabel
@onready var _sub_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/SubLabel
@onready var _portrait_row: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow
@onready var _player_card: PanelContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard
@onready var _player_portrait: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard/PlayerVBox/PlayerPortrait
@onready var _player_name: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/PlayerCard/PlayerVBox/PlayerName
@onready var _enemy_card: PanelContainer = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard
@onready var _enemy_portrait: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard/EnemyVBox/EnemyPortrait
@onready var _enemy_name: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/PortraitRow/EnemyCard/EnemyVBox/EnemyName
@onready var _stats_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/StatsLabel
@onready var _rating_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/RatingLabel
@onready var _run_meta_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/RunMetaLabel
@onready var _play_again_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBox/PlayAgainButton
@onready var _menu_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBox/MenuButton

func _ready() -> void:
	DebugLogger.log_system("VictoryScreen: pronta")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()

	var rating := GameManager.run_rating()
	var rating_desc := GameManager.rating_description(rating)
	var total := GameManager.total_score()

	# Riga punteggi per incontro
	var score_lines: Array[String] = []
	for i in range(GameManager.run_scores.size()):
		var enemy_data: EnemyData = GameManager.enemy_roster[i] if i < GameManager.enemy_roster.size() else null
		var enemy_name := enemy_data.enemy_name if enemy_data != null else "Nemico %d" % (i + 1)
		score_lines.append("Scontro %d — %s: %.0f pt" % [i + 1, enemy_name, GameManager.run_scores[i]])
	score_lines.append("─────────────────────────")
	score_lines.append("Punteggio totale: %.0f pt" % total)

	var final_enemy_name := "Galactic Tyrant"
	if not GameManager.last_result.is_empty() and GameManager.last_result.has("enemy_name"):
		final_enemy_name = String(GameManager.last_result["enemy_name"])
	elif not GameManager.enemy_roster.is_empty():
		final_enemy_name = GameManager.enemy_roster[GameManager.enemy_roster.size() - 1].enemy_name
	_populate_portraits(final_enemy_name)
	_run_meta_label.text = "Pilota: %s   |   HP finale: %s   |   Boss abbattuto: %s" % [
		_player_name.text,
		GameManager.player_hp_summary(),
		final_enemy_name,
	]

	_stats_label.text = "\n".join(score_lines)
	_rating_label.text = "Rating: %s — %s" % [rating, rating_desc]
	_play_again_button.pressed.connect(_on_play_again)
	_menu_button.pressed.connect(_on_menu)


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var compact_touch_ui := OS.has_feature("mobile") or viewport_size.x <= 900.0 or viewport_size.y <= 720.0
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(viewport_size.x - (24.0 if compact_touch_ui else 96.0), 300.0, 640.0 if compact_touch_ui else 760.0)
	var portrait_card_width: float = clampf(content_width * (0.42 if portrait_layout else 0.31), 132.0, 190.0)
	var portrait_size: float = clampf(portrait_card_width - 34.0, 108.0, 152.0)
	var button_width: float = clampf(content_width * 0.56, 220.0, 320.0)
	var button_height: float = 58.0 if compact_touch_ui else 54.0
	_content_panel.custom_minimum_size = Vector2(content_width, 0.0)
	_layout_box.custom_minimum_size = Vector2(content_width - 56.0, 0.0)
	_layout_box.add_theme_constant_override("separation", 18 if compact_touch_ui else 24)
	_portrait_row.add_theme_constant_override("separation", 12 if compact_touch_ui else 18)
	_victory_label.add_theme_font_size_override("font_size", 40 if compact_touch_ui else 52)
	_sub_label.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 20)
	_stats_label.add_theme_font_size_override("font_size", 15 if compact_touch_ui else 16)
	_rating_label.add_theme_font_size_override("font_size", 24 if compact_touch_ui else 28)
	_run_meta_label.add_theme_font_size_override("font_size", 15 if compact_touch_ui else 16)
	_play_again_button.custom_minimum_size = Vector2(button_width, button_height)
	_menu_button.custom_minimum_size = Vector2(button_width, 50.0 if compact_touch_ui else 44.0)
	_play_again_button.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 20)
	_menu_button.add_theme_font_size_override("font_size", 16 if compact_touch_ui else 16)
	_player_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 66.0)
	_enemy_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 66.0)
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

func _on_play_again() -> void:
	GameManager.return_to_menu()
	GameManager.start_character_selection()

func _on_menu() -> void:
	GameManager.return_to_menu()
