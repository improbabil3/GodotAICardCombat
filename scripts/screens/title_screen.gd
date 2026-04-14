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
	var compact_touch_ui := OS.has_feature("mobile") or viewport_size.x <= 900.0
	var min_dimension := minf(viewport_size.x, viewport_size.y)
	var content_width := clampf(
		viewport_size.x - (24.0 if compact_touch_ui else 96.0),
		280.0,
		420.0 if compact_touch_ui else 560.0
	)
	var title_font := int(clampf(min_dimension * (0.10 if compact_touch_ui else 0.08), 38.0, 58.0))
	var subtitle_font := int(clampf(min_dimension * 0.045, 18.0, 24.0))
	var primary_height := 64.0 if compact_touch_ui else 54.0
	var secondary_height := 56.0 if compact_touch_ui else 44.0
	_vbox.add_theme_constant_override("separation", 20 if compact_touch_ui else 24)
	_title_label.add_theme_font_size_override("font_size", title_font)
	_subtitle_label.add_theme_font_size_override("font_size", subtitle_font)
	_spacer.custom_minimum_size.y = 24.0 if compact_touch_ui else 32.0
	_play_button.custom_minimum_size = Vector2(content_width, primary_height)
	_play_button.add_theme_font_size_override("font_size", 22 if compact_touch_ui else 20)
	_quit_button.custom_minimum_size = Vector2(content_width, secondary_height)
	_quit_button.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 16)

func _on_play_pressed() -> void:
	DebugLogger.log_system("TitleScreen: inizio selezione personaggio")
	GameManager.start_character_selection()

func _on_quit_pressed() -> void:
	get_tree().quit()
