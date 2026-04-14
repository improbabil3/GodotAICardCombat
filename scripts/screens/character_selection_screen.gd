## CharacterSelectionScreen — Schermata di selezione personaggio via carosello
##
## L'utente naviga tra i 3 personaggi e ne seleziona uno.
## Dopo la selezione, passa a CardSelectionScreen.

extends Control

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _content_panel: Control = $CenterContainer/ContentPanel
@onready var _content_margin: MarginContainer = $CenterContainer/ContentPanel/ContentMargin
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer
@onready var _carousel_area: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea
@onready var _character_panel: Control = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel
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
	if _uses_mobile_layout():
		_apply_mobile_layout(viewport_size)
	else:
		_apply_desktop_layout(viewport_size)


func _uses_mobile_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return OS.has_feature("mobile") or viewport_size.x <= 900.0


func _apply_mobile_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var mobile_landscape := not portrait_layout
	var screen_margin: float = 6.0 if mobile_landscape else 12.0
	var top_margin: float = 8.0 if mobile_landscape else 14.0
	var content_margin_x: int = 10 if mobile_landscape else 16
	var content_margin_y: int = 8 if mobile_landscape else 14
	var content_width: float = clampf(viewport_size.x - screen_margin * 2.0, 320.0, 1120.0)
	var content_height: float = clampf(viewport_size.y - top_margin * 2.0, 300.0, 820.0)
	var spacing: int = 8 if mobile_landscape else 12
	var side_button_width: float = 52.0 if mobile_landscape else 66.0
	var button_height: float = 48.0 if mobile_landscape else 58.0
	var panel_width: float = maxf(240.0, content_width - side_button_width * 2.0 - float(spacing * 2))
	var panel_height: float = clampf(content_height - 52.0, 250.0, 520.0)
	var image_height: float = clampf(panel_height * (0.42 if portrait_layout else 0.52), 150.0, 260.0)
	var total_height: float = 32.0 + float(spacing) + panel_height
	var carousel_width: float = panel_width + side_button_width * 2.0 + float(spacing * 2)
	_apply_layout_values({
		"mode_label": "mobile_landscape" if mobile_landscape else "mobile_portrait",
		"content_width": content_width,
		"content_height": content_height,
		"carousel_width": carousel_width,
		"total_height": total_height,
		"content_margin_x": content_margin_x,
		"content_margin_y": content_margin_y,
		"panel_y": maxf(top_margin, floor((viewport_size.y - total_height) * 0.5)),
		"spacing": spacing,
		"side_button_width": side_button_width,
		"button_height": button_height,
		"panel_width": panel_width,
		"panel_height": panel_height,
		"image_height": image_height,
		"title_font_size": 20 if mobile_landscape else 26,
		"name_font_size": 22 if mobile_landscape else 28,
		"description_height": clampf(panel_height * (0.18 if mobile_landscape else 0.24), 72.0, 132.0),
		"description_font_size": 14 if mobile_landscape else 18,
		"button_font_size": 16 if mobile_landscape else 20,
		"compact_buttons": true,
	})


func _apply_desktop_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var content_width: float = clampf(viewport_size.x - 96.0, 480.0, 980.0)
	var content_height: float = clampf(viewport_size.y - 48.0, 360.0, 620.0)
	var spacing: int = 18 if viewport_size.x >= 1100.0 else 12
	var side_button_width: float = clampf(viewport_size.x * 0.06, 72.0, 120.0)
	var button_height: float = clampf(viewport_size.y * 0.10, 46.0, 56.0)
	var panel_width: float = clampf(content_width * 0.46, 360.0, 460.0)
	var panel_height: float = clampf(content_height - 96.0, 300.0, 520.0)
	var image_height: float = clampf(panel_height * 0.34, 120.0, 220.0)
	var total_height: float = 40.0 + float(spacing) + panel_height
	_apply_layout_values({
		"mode_label": "desktop_portrait" if portrait_layout else "desktop",
		"content_width": content_width,
		"content_height": content_height,
		"carousel_width": panel_width + side_button_width * 2.0 + float(spacing * 2),
		"total_height": total_height,
		"content_margin_x": 28,
		"content_margin_y": 24,
		"panel_y": floor((viewport_size.y - total_height) * 0.5),
		"spacing": spacing,
		"side_button_width": side_button_width,
		"button_height": button_height,
		"panel_width": panel_width,
		"panel_height": panel_height,
		"image_height": image_height,
		"title_font_size": 22 if viewport_size.x >= 900.0 else 18,
		"name_font_size": 24 if viewport_size.x >= 1100.0 else 20,
		"description_height": clampf(panel_height * 0.18, 72.0, 110.0),
		"description_font_size": 16 if viewport_size.x >= 900.0 else 14,
		"button_font_size": 18,
		"compact_buttons": false,
	})


func _apply_layout_values(config: Dictionary) -> void:
	var content_width: float = config["content_width"]
	var carousel_width: float = config["carousel_width"]
	var total_height: float = config["total_height"]
	var content_margin_x: int = config["content_margin_x"]
	var content_margin_y: int = config["content_margin_y"]
	var spacing: int = config["spacing"]
	var side_button_width: float = config["side_button_width"]
	var button_height: float = config["button_height"]
	var panel_width: float = config["panel_width"]
	var panel_height: float = config["panel_height"]
	var image_height: float = config["image_height"]
	var title_font_size: int = config["title_font_size"]
	var name_font_size: int = config["name_font_size"]
	var description_height: float = config["description_height"]
	var description_font_size: int = config["description_font_size"]
	var button_font_size: int = config["button_font_size"]
	var compact_buttons: bool = config["compact_buttons"]

	_content_margin.add_theme_constant_override("margin_left", content_margin_x)
	_content_margin.add_theme_constant_override("margin_top", content_margin_y)
	_content_margin.add_theme_constant_override("margin_right", content_margin_x)
	_content_margin.add_theme_constant_override("margin_bottom", content_margin_y)
	_content_panel.custom_minimum_size = Vector2(content_width, total_height)
	_content_panel.size = Vector2(content_width, total_height)
	_layout_box.custom_minimum_size = Vector2(content_width - float(content_margin_x * 2), 0.0)
	_layout_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_layout_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_layout_box.add_theme_constant_override("separation", spacing)
	_content_panel.position = Vector2(
		floor((size.x - content_width) * 0.5),
		config["panel_y"]
	)
	_layout_box.position = Vector2.ZERO
	_carousel_area.custom_minimum_size = Vector2(carousel_width, panel_height)
	_carousel_area.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_carousel_area.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_carousel_area.add_theme_constant_override("separation", spacing)
	_character_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	_character_info.add_theme_constant_override("separation", 12 if compact_buttons else 10)
	_prev_button.custom_minimum_size = Vector2(side_button_width, button_height)
	_next_button.custom_minimum_size = Vector2(side_button_width, button_height)
	_prev_button.add_theme_font_size_override("font_size", button_font_size)
	_next_button.add_theme_font_size_override("font_size", button_font_size)
	_prev_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_next_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_select_button.custom_minimum_size = Vector2(minf(panel_width - 24.0, 320.0 if not compact_buttons else 260.0), button_height)
	_select_button.add_theme_font_size_override("font_size", button_font_size)
	_select_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_character_image.custom_minimum_size = Vector2(0.0, image_height)
	_character_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_character_name.add_theme_font_size_override("font_size", name_font_size)
	_character_description.custom_minimum_size = Vector2(0.0, description_height)
	_character_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_description.add_theme_font_size_override("font_size", description_font_size)
	_prev_button.text = "◀" if compact_buttons else "< Precedente"
	_next_button.text = "▶" if compact_buttons else "Successivo >"
	_carousel_label.add_theme_font_size_override("font_size", title_font_size)
	_carousel_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	DebugLogger.log_system("CharacterSelectionScreen[%s]: viewport=%s content=(%f,%f) panel=(%f,%f)" % [config["mode_label"], size, content_width, config["content_height"], panel_width, panel_height])


func _update_carousel_display() -> void:
	var selected_character := CharacterManager.get_character(_carousel_index)
	_character_name.text = selected_character.name
	_character_description.text = selected_character.description
	_character_image.texture = PortraitLibrary.load_portrait(selected_character.character_id, "select")
	_character_image.tooltip_text = selected_character.name

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
