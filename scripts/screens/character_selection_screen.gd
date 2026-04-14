## CharacterSelectionScreen — Schermata di selezione personaggio via carosello
##
## L'utente naviga tra i 3 personaggi e ne seleziona uno.
## Dopo la selezione, passa a CardSelectionScreen.

extends Control

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _content_panel: PanelContainer = $CenterContainer/ContentPanel
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer
@onready var _carousel_area: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea
@onready var _character_panel: PanelContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel
@onready var _carousel_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselLabel
@onready var _prev_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/PrevButton
@onready var _next_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/NextButton
@onready var _character_info: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo
@onready var _character_image: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterImage
@onready var _character_name: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterName
@onready var _character_description: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterDescription
@onready var _select_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/SelectButton

# ── Stato ──────────────────────────────────────────────────────────────────────
var _carousel_index: int = 0

func _ready() -> void:
	DebugLogger.log_system("CharacterSelectionScreen: avvio")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()
	
	# Connetti pulsanti
	_prev_button.pressed.connect(_on_prev_pressed)
	_next_button.pressed.connect(_on_next_pressed)
	_select_button.pressed.connect(_on_select_pressed)
	
	# Mostra primo personaggio
	_update_carousel_display()


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var compact_touch_ui := OS.has_feature("mobile") or viewport_size.x <= 900.0
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(
		viewport_size.x - (24.0 if compact_touch_ui else 48.0),
		320.0,
		1120.0 if compact_touch_ui else 980.0
	)
	var content_height: float = clampf(
		viewport_size.y - (24.0 if compact_touch_ui else 48.0),
		420.0 if compact_touch_ui else 360.0,
		820.0 if compact_touch_ui else 620.0
	)
	var spacing: int = 12 if compact_touch_ui else (24 if viewport_size.x >= 1100.0 else 12)
	var side_button_width: float = clampf(
		viewport_size.x * (0.12 if compact_touch_ui else 0.07),
		54.0 if compact_touch_ui else 48.0,
		76.0 if portrait_layout and compact_touch_ui else (96.0 if compact_touch_ui else 140.0)
	)
	var button_height: float = clampf(
		viewport_size.y * (0.11 if compact_touch_ui else 0.10),
		58.0 if compact_touch_ui else 46.0,
		72.0 if compact_touch_ui else 56.0
	)
	var panel_width: float = maxf(240.0 if compact_touch_ui else 200.0, content_width - side_button_width * 2.0 - float(spacing * 2))
	var panel_height: float = clampf(
		content_height - (82.0 if compact_touch_ui else 96.0),
		360.0 if compact_touch_ui else 300.0,
		660.0 if compact_touch_ui else 520.0
	)
	var image_height: float = clampf(
		panel_height * (0.42 if compact_touch_ui else 0.34),
		160.0 if compact_touch_ui else 120.0,
		260.0 if compact_touch_ui else 220.0
	)
	var total_height: float = 40.0 + float(spacing) + panel_height

	_layout_box.custom_minimum_size = Vector2(content_width, 0.0)
	_layout_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_layout_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_layout_box.add_theme_constant_override("separation", spacing)
	_content_panel.position = Vector2(
		floor((viewport_size.x - content_width) * 0.5),
		floor((viewport_size.y - total_height) * 0.5)
	)
	_layout_box.position = Vector2(
		0.0,
		0.0
	)
	_carousel_area.custom_minimum_size = Vector2(content_width, panel_height)
	_carousel_area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_carousel_area.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_carousel_area.add_theme_constant_override("separation", spacing)
	_character_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	_character_info.add_theme_constant_override("separation", 14 if compact_touch_ui else 10)
	_prev_button.custom_minimum_size = Vector2(side_button_width, button_height)
	_next_button.custom_minimum_size = Vector2(side_button_width, button_height)
	_prev_button.add_theme_font_size_override("font_size", 20 if compact_touch_ui else 16)
	_next_button.add_theme_font_size_override("font_size", 20 if compact_touch_ui else 16)
	_prev_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_next_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_select_button.custom_minimum_size = Vector2(minf(panel_width - 24.0, 320.0 if compact_touch_ui else 280.0), button_height)
	_select_button.add_theme_font_size_override("font_size", 20 if compact_touch_ui else 18)
	_select_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_character_image.custom_minimum_size = Vector2(0.0, image_height)
	_character_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_character_name.add_theme_font_size_override("font_size", 28 if compact_touch_ui else (24 if viewport_size.x >= 1100.0 else 20))
	_character_description.custom_minimum_size = Vector2(0.0, clampf(panel_height * (0.22 if compact_touch_ui else 0.18), 96.0 if compact_touch_ui else 72.0, 150.0 if compact_touch_ui else 110.0))
	_character_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_description.add_theme_font_size_override("font_size", 18 if compact_touch_ui else (16 if viewport_size.x >= 900.0 else 14))
	_prev_button.text = "◀" if compact_touch_ui or viewport_size.x < 760.0 else "< Precedente"
	_next_button.text = "▶" if compact_touch_ui or viewport_size.x < 760.0 else "Successivo >"
	_carousel_label.add_theme_font_size_override("font_size", 26 if compact_touch_ui else (22 if viewport_size.x >= 900.0 else 18))
	_carousel_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _update_carousel_display() -> void:
	var char := CharacterManager.get_character(_carousel_index)
	_character_name.text = char.name
	_character_description.text = char.description
	_character_image.texture = PortraitLibrary.load_portrait(char.character_id, "select")
	_character_image.tooltip_text = char.name

func _on_prev_pressed() -> void:
	_carousel_index = (_carousel_index - 1 + CharacterManager.characters.size()) % CharacterManager.characters.size()
	_update_carousel_display()

func _on_next_pressed() -> void:
	_carousel_index = (_carousel_index + 1) % CharacterManager.characters.size()
	_update_carousel_display()

func _on_select_pressed() -> void:
	var selected_char := CharacterManager.get_character(_carousel_index)
	CharacterManager.set_selected_character(_carousel_index)
	DebugLogger.log_system("CharacterSelectionScreen: selezionato %s" % selected_char.name)
	
	# Vai a CardSelectionScreen
	GameManager.start_card_selection()
