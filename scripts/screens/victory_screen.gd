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
	if _uses_mobile_layout(viewport_size):
		_apply_mobile_layout(viewport_size)
	else:
		_apply_desktop_layout(viewport_size)


func _uses_mobile_layout(viewport_size: Vector2) -> bool:
	return OS.has_feature("mobile") or viewport_size.x <= 900.0 or viewport_size.y <= 720.0


func _apply_mobile_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(viewport_size.x - 24.0, 300.0, 640.0)
	var portrait_card_width: float = clampf(content_width * (0.42 if portrait_layout else 0.31), 132.0, 190.0)
	var portrait_size: float = clampf(portrait_card_width - 34.0, 108.0, 152.0)
	_apply_layout_values({
		"content_width": content_width,
		"layout_width": content_width - 56.0,
		"separation": 18,
		"portrait_separation": 12,
		"title_font": 40,
		"sub_font": 18,
		"stats_font": 15,
		"rating_font": 24,
		"meta_font": 15,
		"button_width": clampf(content_width * 0.56, 220.0, 320.0),
		"play_height": 58.0,
		"menu_height": 50.0,
		"play_font": 18,
		"menu_font": 16,
		"portrait_card_width": portrait_card_width,
		"portrait_size": portrait_size,
		"name_font": 14,
	})


func _apply_desktop_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(viewport_size.x - 96.0, 360.0, 760.0)
	var portrait_card_width: float = clampf(content_width * (0.42 if portrait_layout else 0.31), 132.0, 190.0)
	var portrait_size: float = clampf(portrait_card_width - 34.0, 108.0, 152.0)
	_apply_layout_values({
		"content_width": content_width,
		"layout_width": content_width - 56.0,
		"separation": 24,
		"portrait_separation": 18,
		"title_font": 52,
		"sub_font": 20,
		"stats_font": 16,
		"rating_font": 28,
		"meta_font": 16,
		"button_width": clampf(content_width * 0.56, 220.0, 320.0),
		"play_height": 54.0,
		"menu_height": 44.0,
		"play_font": 20,
		"menu_font": 16,
		"portrait_card_width": portrait_card_width,
		"portrait_size": portrait_size,
		"name_font": 16,
	})


func _apply_layout_values(config: Dictionary) -> void:
	var content_width: float = config["content_width"]
	var portrait_card_width: float = config["portrait_card_width"]
	var portrait_size: float = config["portrait_size"]
	_content_panel.custom_minimum_size = Vector2(content_width, 0.0)
	_layout_box.custom_minimum_size = Vector2(config["layout_width"], 0.0)
	_layout_box.add_theme_constant_override("separation", config["separation"])
	_portrait_row.add_theme_constant_override("separation", config["portrait_separation"])
	_victory_label.add_theme_font_size_override("font_size", config["title_font"])
	_sub_label.add_theme_font_size_override("font_size", config["sub_font"])
	_stats_label.add_theme_font_size_override("font_size", config["stats_font"])
	_rating_label.add_theme_font_size_override("font_size", config["rating_font"])
	_run_meta_label.add_theme_font_size_override("font_size", config["meta_font"])
	_play_again_button.custom_minimum_size = Vector2(config["button_width"], config["play_height"])
	_menu_button.custom_minimum_size = Vector2(config["button_width"], config["menu_height"])
	_play_again_button.add_theme_font_size_override("font_size", config["play_font"])
	_menu_button.add_theme_font_size_override("font_size", config["menu_font"])
	_player_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 66.0)
	_enemy_card.custom_minimum_size = Vector2(portrait_card_width, portrait_size + 66.0)
	_player_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_enemy_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_player_name.add_theme_font_size_override("font_size", config["name_font"])
	_enemy_name.add_theme_font_size_override("font_size", config["name_font"])


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
