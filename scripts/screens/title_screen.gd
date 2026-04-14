## TitleScreen — Schermata iniziale

extends Control

@onready var _vbox: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBox
@onready var _title_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/TitleLabel
@onready var _subtitle_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBox/SubtitleLabel
@onready var _spacer: Control = $CenterContainer/ContentPanel/ContentMargin/VBox/Spacer
@onready var _play_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBox/PlayButton
@onready var _quit_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBox/QuitButton

func _ready() -> void:
	DebugLogger.log_system("TitleScreen: pronta")
	_play_button.pressed.connect(_on_play_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	if _uses_mobile_layout(viewport_size):
		_apply_mobile_layout(viewport_size)
	else:
		_apply_desktop_layout(viewport_size)


func _uses_mobile_layout(viewport_size: Vector2) -> bool:
	return OS.has_feature("mobile") or viewport_size.x <= 900.0


func _apply_mobile_layout(viewport_size: Vector2) -> void:
	var min_dimension := minf(viewport_size.x, viewport_size.y)
	_apply_layout_values({
		"mode_label": "mobile",
		"content_width": clampf(viewport_size.x - 24.0, 280.0, 420.0),
		"title_font": int(clampf(min_dimension * 0.10, 38.0, 58.0)),
		"subtitle_font": int(clampf(min_dimension * 0.045, 18.0, 24.0)),
		"primary_height": 64.0,
		"secondary_height": 56.0,
		"separation": 20,
		"spacer_height": 24.0,
		"play_font": 22,
		"quit_font": 18,
	})


func _apply_desktop_layout(viewport_size: Vector2) -> void:
	var min_dimension := minf(viewport_size.x, viewport_size.y)
	_apply_layout_values({
		"mode_label": "desktop",
		"content_width": clampf(viewport_size.x - 96.0, 360.0, 560.0),
		"title_font": int(clampf(min_dimension * 0.08, 38.0, 58.0)),
		"subtitle_font": int(clampf(min_dimension * 0.045, 18.0, 24.0)),
		"primary_height": 54.0,
		"secondary_height": 44.0,
		"separation": 24,
		"spacer_height": 32.0,
		"play_font": 20,
		"quit_font": 16,
	})


func _apply_layout_values(config: Dictionary) -> void:
	var content_width: float = config["content_width"]
	_vbox.add_theme_constant_override("separation", config["separation"])
	_title_label.add_theme_font_size_override("font_size", config["title_font"])
	_subtitle_label.add_theme_font_size_override("font_size", config["subtitle_font"])
	_spacer.custom_minimum_size.y = config["spacer_height"]
	_play_button.custom_minimum_size = Vector2(content_width, config["primary_height"])
	_play_button.add_theme_font_size_override("font_size", config["play_font"])
	_quit_button.custom_minimum_size = Vector2(content_width, config["secondary_height"])
	_quit_button.add_theme_font_size_override("font_size", config["quit_font"])

func _on_play_pressed() -> void:
	DebugLogger.log_system("TitleScreen: inizio selezione personaggio")
	GameManager.start_character_selection()

func _on_quit_pressed() -> void:
	get_tree().quit()
