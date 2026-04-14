## CardSelectionScreen — Schermata di selezione carte specifiche del personaggio
##
## L'utente sceglie esattamente 10 carte dal pool di 20 specifiche del personaggio.
## Le altre 10 carte verranno scelte casualmente dal mazzo base.

extends Control

const CARD_SCENE := preload("res://scenes/card/card.tscn")

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _content_panel: Control = $CenterContainer/ContentPanel
@onready var _content_margin: MarginContainer = $CenterContainer/ContentPanel/ContentMargin
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer
@onready var _top_bar: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar
@onready var _character_portrait_card: Control = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar/CharacterPortraitCard
@onready var _character_portrait: TextureRect = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar/CharacterPortraitCard/CharacterPortrait
@onready var _character_name_card: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar/CharacterInfoLeft/CharacterNameCard
@onready var _character_description_card: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar/CharacterInfoLeft/CharacterDescriptionCard
@onready var _selection_counter: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar/SelectionCounter
@onready var _title_label: Label = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TitleLabel
@onready var _scroll_container: ScrollContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CardGridScroll
@onready var _card_grid: GridContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/CardGridScroll/CardGrid
@onready var _bottom_bar: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/BottomBar
@onready var _confirm_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/BottomBar/ConfirmButton
@onready var _back_button: Button = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/BottomBar/BackButton

# ── Stato ──────────────────────────────────────────────────────────────────────
var _selected_character: CharacterData = null
var _base_cards: Array[CardData] = []
var _selected_specific_cards: Array[CardData] = []
var _card_buttons: Array[CardUI] = []
var _card_button_size: Vector2 = Vector2(140, 140)
var _tooltip: PanelContainer = null
var _tooltip_box: VBoxContainer = null
var _tooltip_name: Label = null
var _tooltip_effects: Label = null
var _tooltip_energy: Label = null
var _tooltip_anchor_button: Control = null
var _tooltip_anchor_card: CardData = null

const CARD_ASPECT_RATIO := 212.0 / 148.0

func _ready() -> void:
	DebugLogger.log_system("CardSelectionScreen: avvio")
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_setup_tooltip_ui()
	
	# Recupera il personaggio selezionato
	_selected_character = CharacterManager.get_selected_character()
	if not _selected_character:
		DebugLogger.log_error("CardSelectionScreen: nessun personaggio selezionato!")
		return
	
	# Carica il mazzo base
	_base_cards = DeckLoader.load_deck("res://data/deck_player.json")
	
	_apply_responsive_layout()
	
	# Connetti pulsanti
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	
	# Mostra il personaggio e crea i bottoni
	_update_character_info()
	_create_card_buttons()


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()
	for btn in _card_buttons:
		if is_instance_valid(btn):
			btn.apply_layout(_card_button_size)
		if _tooltip.visible and btn == _tooltip_anchor_button:
			_reposition_tooltip()


func _setup_tooltip_ui() -> void:
	_tooltip = PanelContainer.new()
	_tooltip.name = "SelectionTooltip"
	_tooltip.visible = false
	_tooltip.z_index = 100
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip.anchor_left = 0.0
	_tooltip.anchor_top = 0.0
	_tooltip.anchor_right = 0.0
	_tooltip.anchor_bottom = 0.0
	_tooltip.offset_left = 0.0
	_tooltip.offset_top = 0.0
	_tooltip.offset_right = 0.0
	_tooltip.offset_bottom = 0.0
	_tooltip.custom_minimum_size = Vector2(220, 0)
	_tooltip.size_flags_horizontal = 0
	_tooltip.theme_type_variation = &"HudPanel"
	add_child(_tooltip)
	_tooltip_box = VBoxContainer.new()
	_tooltip_box.name = "TooltipVBox"
	_tooltip_box.add_theme_constant_override("separation", 4)
	_tooltip.add_child(_tooltip_box)
	_tooltip_name = Label.new()
	_tooltip_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_name.add_theme_font_size_override("font_size", 14)
	_tooltip_box.add_child(_tooltip_name)
	_tooltip_effects = Label.new()
	_tooltip_effects.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_effects.add_theme_font_size_override("font_size", 13)
	_tooltip_box.add_child(_tooltip_effects)
	_tooltip_energy = Label.new()
	_tooltip_energy.add_theme_font_size_override("font_size", 13)
	_tooltip_energy.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	_tooltip_box.add_child(_tooltip_energy)


func _uses_touch_tooltip_mode() -> bool:
	return OS.has_feature("mobile")


func _uses_compact_mobile_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return OS.has_feature("mobile") or viewport_size.x <= 900.0 or viewport_size.y <= 700.0


func _status_symbol(card: CardData) -> String:
	match card.status_effect:
		"burn": return "🔥"
		"poison": return "☠"
		"freeze": return "❄"
		"haste": return "⚡"
		"blessed": return "✨"
	return ""


func _status_tint(card: CardData) -> Color:
	match card.status_effect:
		"burn": return Color(1.0, 0.78, 0.78, 1)
		"poison": return Color(0.82, 1.0, 0.82, 1)
		"freeze": return Color(0.80, 0.93, 1.0, 1)
		"haste": return Color(1.0, 0.94, 0.74, 1)
		"blessed": return Color(1.0, 0.93, 0.82, 1)
	return Color.WHITE


func _apply_card_button_style(btn: CanvasItem, card: CardData, selected: bool) -> void:
	var tint := _status_tint(card)
	btn.modulate = Color(1.0, 0.92, 0.45, 1.0) if selected else tint


func _show_tooltip(card: CardData, anchor_button: Control) -> void:
	_tooltip_anchor_card = card
	_tooltip_anchor_button = anchor_button
	var tooltip_width := 260.0 if _uses_touch_tooltip_mode() else 200.0
	var text_width := tooltip_width - 16.0
	var tooltip_title := "%s %s" % [_status_symbol(card), card.card_name] if card.status_effect != "" else card.card_name
	_tooltip_name.text = tooltip_title
	var effects: Array[String] = []
	if card.damage > 0:
		effects.append("Danno: +%d" % card.damage)
	if card.shield > 0:
		effects.append("Scudo: +%d" % card.shield)
	if card.heal > 0:
		effects.append("Guarigione: +%d" % card.heal)
	if card.status_effect != "":
		var target := "sé stesso" if card.status_target == "self" else "avversario"
		effects.append("Effetto: %s su %s" % [card.status_effect.to_upper(), target])
	var effects_text := "\n".join(effects)
	_tooltip_effects.text = effects_text
	_tooltip_energy.text = "ENE: %d" % card.energy_cost
	var title_height := _estimate_text_block_height(tooltip_title, text_width, 18.0)
	var effects_height := _estimate_text_block_height(effects_text, text_width, 17.0)
	var energy_height := 18.0
	var content_height := title_height + effects_height + energy_height + 8.0
	var panel_height := content_height + 16.0
	_tooltip.custom_minimum_size = Vector2(tooltip_width, panel_height)
	_tooltip_box.custom_minimum_size = Vector2(text_width, content_height)
	_tooltip_name.custom_minimum_size = Vector2(text_width, title_height)
	_tooltip_effects.custom_minimum_size = Vector2(text_width, effects_height)
	_tooltip_energy.custom_minimum_size = Vector2(text_width, energy_height)
	_tooltip.visible = true
	_tooltip.size = Vector2(tooltip_width, panel_height)
	_log_tooltip_geometry("SelectionTooltip immediate", tooltip_width, panel_height)
	_reposition_tooltip()
	call_deferred("_finalize_tooltip_geometry", tooltip_width, panel_height)


func _estimate_text_block_height(text: String, text_width: float, line_height: float) -> float:
	var chars_per_line := maxi(12, int(text_width / 7.5))
	var line_count := 0
	for paragraph in text.split("\n"):
		line_count += maxi(1, int(ceili(float(maxi(paragraph.length(), 1)) / float(chars_per_line))))
	return float(maxi(1, line_count)) * line_height


func _finalize_tooltip_geometry(tooltip_width: float, panel_height: float) -> void:
	if not _tooltip.visible:
		return
	_tooltip.size = Vector2(tooltip_width, panel_height)
	_log_tooltip_geometry("SelectionTooltip deferred", tooltip_width, panel_height)
	_reposition_tooltip()


func _log_tooltip_geometry(stage: String, tooltip_width: float, panel_height: float) -> void:
	DebugLogger.log_system(
		"%s expected=(%s,%s) actual=%s custom_min=%s box_min=%s title_min=%s effects_min=%s energy_min=%s" % [
			stage,
			tooltip_width,
			panel_height,
			_tooltip.size,
			_tooltip.custom_minimum_size,
			_tooltip_box.get_combined_minimum_size(),
			_tooltip_name.get_combined_minimum_size(),
			_tooltip_effects.get_combined_minimum_size(),
			_tooltip_energy.get_combined_minimum_size()
		]
	)


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if _uses_compact_mobile_layout():
		_apply_mobile_layout(viewport_size)
	else:
		_apply_desktop_layout(viewport_size)


func _apply_mobile_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var mobile_landscape := not portrait_layout
	var screen_margin: float = 4.0 if mobile_landscape else 10.0
	var top_margin: float = 6.0 if mobile_landscape else 10.0
	var content_margin_x: int = 10 if mobile_landscape else 16
	var content_margin_y: int = 10 if mobile_landscape else 16
	var layout_width: float = clampf(viewport_size.x - screen_margin * 2.0, 320.0, 1820.0)
	var layout_height: float = clampf(viewport_size.y - (top_margin + 8.0), 420.0, 980.0)
	var spacing: int = 6 if mobile_landscape else 8
	var top_height: float = clampf(viewport_size.y * (0.095 if mobile_landscape else 0.12), 64.0 if mobile_landscape else 84.0, 84.0 if mobile_landscape else 112.0)
	var bottom_height: float = 52.0 if mobile_landscape else 64.0
	var title_height: float = 28.0 if mobile_landscape else 40.0
	var grid_gap: int = 4 if mobile_landscape else 6
	var inner_width: float = layout_width - float(content_margin_x * 2)
	var columns: int = 4 if portrait_layout else (8 if inner_width >= 1380.0 else 7)
	var total_cards: int = _selected_character.specific_cards.size() if _selected_character != null else 20
	var row_count: int = ceili(float(total_cards) / float(columns))
	var max_grid_height: float = maxf(220.0, layout_height - top_height - title_height - bottom_height - float(spacing * 3))
	var width_limited_card_width: float = floor((inner_width - float((columns - 1) * grid_gap)) / float(columns))
	var max_card_height_by_rows: float = floor((max_grid_height - float((row_count - 1) * grid_gap)) / float(maxi(1, row_count)))
	var height_limited_card_width: float = floor(max_card_height_by_rows / CARD_ASPECT_RATIO)
	var card_width: float = maxf(96.0, min(width_limited_card_width, height_limited_card_width))
	var card_height: float = clampf(card_width * CARD_ASPECT_RATIO, 160.0 if mobile_landscape else 188.0, 320.0)
	var full_grid_height := card_height * float(row_count) + float((row_count - 1) * grid_gap)
	var scroll_height: float = full_grid_height
	var total_height: float = top_height + title_height + scroll_height + bottom_height + float(spacing * 3)
	_apply_layout_values({
		"mode_label": "mobile_landscape" if mobile_landscape else "mobile_portrait",
		"layout_width": layout_width,
		"layout_height": layout_height,
		"inner_width": inner_width,
		"total_height": total_height,
		"content_margin_x": content_margin_x,
		"content_margin_y": content_margin_y,
		"panel_y": maxf(top_margin, floor((viewport_size.y - total_height) * 0.5)),
		"spacing": spacing,
		"top_height": top_height,
		"bottom_height": bottom_height,
		"title_font_size": 18 if mobile_landscape else 24,
		"selection_counter_width": 92.0 if mobile_landscape else 150.0,
		"selection_counter_font": 15 if mobile_landscape else 18,
		"name_font_size": 20 if mobile_landscape else 24,
		"description_font_size": 12 if mobile_landscape else 14,
		"description_visible": not mobile_landscape,
		"portrait_size": 64.0 if mobile_landscape else 72.0,
		"grid_gap": grid_gap,
		"scroll_height": scroll_height,
		"columns": columns,
		"card_width": card_width,
		"card_height": card_height,
		"button_font_size": 15 if mobile_landscape else 18,
		"bottom_alignment": BoxContainer.ALIGNMENT_CENTER,
		"back_width_factor": 0.18,
		"confirm_width_factor": 0.32,
		"hide_scrollbars": true,
	})


func _apply_desktop_layout(viewport_size: Vector2) -> void:
	var portrait_layout := viewport_size.y > viewport_size.x
	var screen_margin := 48.0
	var content_margin_x := 28
	var content_margin_y := 24
	var layout_width: float = clampf(viewport_size.x - screen_margin * 2.0, 480.0, 1820.0)
	var layout_height: float = clampf(viewport_size.y - 64.0, 420.0, 940.0)
	var spacing: int = 16 if viewport_size.x >= 900.0 else 10
	var top_height: float = clampf(viewport_size.y * 0.10, 68.0, 88.0)
	var bottom_height := 56.0
	var title_height := 34.0
	var grid_gap: int = 8 if viewport_size.x >= 900.0 else 6
	var inner_width: float = layout_width - float(content_margin_x * 2)
	var columns: int = 4 if portrait_layout else (5 if viewport_size.x < 1500.0 else 6)
	var card_width: float = floor((inner_width - float((columns - 1) * grid_gap)) / float(columns))
	var card_height: float = clampf(card_width * CARD_ASPECT_RATIO, 226.0, 300.0)
	var total_cards: int = _selected_character.specific_cards.size() if _selected_character != null else 20
	var row_count: int = ceili(float(total_cards) / float(columns))
	var max_grid_height: float = maxf(220.0, layout_height - top_height - title_height - bottom_height - float(spacing * 3))
	var full_grid_height := card_height * float(row_count) + float((row_count - 1) * grid_gap)
	var scroll_height: float = min(full_grid_height, max_grid_height)
	var total_height: float = top_height + title_height + scroll_height + bottom_height + float(spacing * 3)
	_apply_layout_values({
		"mode_label": "desktop",
		"layout_width": layout_width,
		"layout_height": layout_height,
		"inner_width": inner_width,
		"total_height": total_height,
		"content_margin_x": content_margin_x,
		"content_margin_y": content_margin_y,
		"panel_y": floor((viewport_size.y - total_height) * 0.5),
		"spacing": spacing,
		"top_height": top_height,
		"bottom_height": bottom_height,
		"title_font_size": 20 if viewport_size.x >= 900.0 else 17,
		"selection_counter_width": 150.0,
		"selection_counter_font": 18 if viewport_size.x >= 900.0 else 15,
		"name_font_size": 24 if viewport_size.x >= 900.0 else 19,
		"description_font_size": 15 if viewport_size.x >= 900.0 else 13,
		"description_visible": true,
		"portrait_size": 96.0,
		"grid_gap": grid_gap,
		"scroll_height": scroll_height,
		"columns": columns,
		"card_width": card_width,
		"card_height": card_height,
		"button_font_size": 16,
		"bottom_alignment": BoxContainer.ALIGNMENT_CENTER,
		"back_width_factor": 0.22,
		"confirm_width_factor": 0.38,
		"hide_scrollbars": false,
	})


func _apply_layout_values(config: Dictionary) -> void:
	var layout_width: float = config["layout_width"]
	var layout_height: float = config["layout_height"]
	var inner_width: float = config["inner_width"]
	var total_height: float = config["total_height"]
	var content_margin_x: int = config["content_margin_x"]
	var content_margin_y: int = config["content_margin_y"]
	var spacing: int = config["spacing"]
	var top_height: float = config["top_height"]
	var bottom_height: float = config["bottom_height"]
	var title_font_size: int = config["title_font_size"]
	var selection_counter_width: float = config["selection_counter_width"]
	var selection_counter_font: int = config["selection_counter_font"]
	var name_font_size: int = config["name_font_size"]
	var description_font_size: int = config["description_font_size"]
	var description_visible: bool = config["description_visible"]
	var portrait_size: float = config["portrait_size"]
	var grid_gap: int = config["grid_gap"]
	var scroll_height: float = config["scroll_height"]
	var columns: int = config["columns"]
	var card_width: float = config["card_width"]
	var card_height: float = config["card_height"]
	var button_font_size: int = config["button_font_size"]
	var bottom_alignment: int = config["bottom_alignment"]
	var back_width_factor: float = config["back_width_factor"]
	var confirm_width_factor: float = config["confirm_width_factor"]
	var hide_scrollbars: bool = config["hide_scrollbars"]

	_content_margin.add_theme_constant_override("margin_left", content_margin_x)
	_content_margin.add_theme_constant_override("margin_top", content_margin_y)
	_content_margin.add_theme_constant_override("margin_right", content_margin_x)
	_content_margin.add_theme_constant_override("margin_bottom", content_margin_y)
	_content_panel.custom_minimum_size = Vector2(layout_width, total_height)
	_content_panel.size = Vector2(layout_width, total_height)
	_layout_box.custom_minimum_size = Vector2(inner_width, 0.0)
	_layout_box.size = Vector2(inner_width, total_height - float(content_margin_y * 2))
	_layout_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_layout_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_layout_box.add_theme_constant_override("separation", spacing)
	_content_panel.position = Vector2(
		floor((size.x - layout_width) * 0.5),
		config["panel_y"]
	)
	_layout_box.position = Vector2.ZERO
	_top_bar.custom_minimum_size = Vector2(inner_width, top_height)
	_top_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_top_bar.add_theme_constant_override("separation", spacing)
	_top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", title_font_size)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selection_counter.custom_minimum_size = Vector2(selection_counter_width, 0.0)
	_selection_counter.add_theme_font_size_override("font_size", selection_counter_font)
	_character_name_card.add_theme_font_size_override("font_size", name_font_size)
	_character_description_card.visible = description_visible
	_character_description_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_description_card.add_theme_font_size_override("font_size", description_font_size)
	_character_portrait_card.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_character_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_tooltip.custom_minimum_size = Vector2(260.0 if _uses_touch_tooltip_mode() else 200.0, 0.0)
	_card_grid.add_theme_constant_override("h_separation", grid_gap)
	_card_grid.add_theme_constant_override("v_separation", grid_gap)
	_scroll_container.custom_minimum_size = Vector2(inner_width, scroll_height)
	_scroll_container.size = Vector2(inner_width, scroll_height)
	_scroll_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_scroll_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_card_grid.columns = columns
	_card_grid.custom_minimum_size = Vector2(inner_width, card_height * float(ceili(float(_selected_character.specific_cards.size() if _selected_character != null else 20) / float(columns))) + float((ceili(float(_selected_character.specific_cards.size() if _selected_character != null else 20) / float(columns)) - 1) * grid_gap))
	_bottom_bar.custom_minimum_size = Vector2(inner_width, bottom_height)
	_bottom_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bottom_bar.alignment = bottom_alignment
	_back_button.custom_minimum_size = Vector2(clampf(inner_width * back_width_factor, 110.0, 200.0), bottom_height)
	_confirm_button.custom_minimum_size = Vector2(clampf(inner_width * confirm_width_factor, 170.0, 340.0), bottom_height)
	_back_button.add_theme_font_size_override("font_size", button_font_size)
	_confirm_button.add_theme_font_size_override("font_size", button_font_size)
	_confirm_button.size_flags_horizontal = 0
	_apply_mobile_scrollbar_visibility(hide_scrollbars)
	_card_button_size = Vector2(card_width, card_height)
	DebugLogger.log_system("CardSelectionScreen[%s]: viewport=%s layout=(%f,%f) inner=%f columns=%d card=(%f,%f) scroll_h=%f" % [config["mode_label"], size, layout_width, layout_height, inner_width, columns, card_width, card_height, scroll_height])


func _hide_tooltip() -> void:
	_tooltip.visible = false
	_tooltip_anchor_button = null
	_tooltip_anchor_card = null


func _reposition_tooltip() -> void:
	if _tooltip_anchor_button == null or not is_instance_valid(_tooltip_anchor_button):
		return
	var vp_size := get_viewport().get_visible_rect().size
	var ts := _tooltip.size
	var anchor_pos := _tooltip_anchor_button.global_position
	var anchor_size := _tooltip_anchor_button.size
	var pos := Vector2(
		anchor_pos.x + (anchor_size.x - ts.x) * 0.5,
		anchor_pos.y - ts.y - 12.0
	)
	if pos.y < 8.0:
		pos.y = anchor_pos.y + anchor_size.y + 12.0
	if _uses_touch_tooltip_mode() and pos.y + ts.y > vp_size.y - 12.0:
		pos = Vector2((vp_size.x - ts.x) * 0.5, maxf(12.0, (vp_size.y - ts.y) * 0.5))
	pos.x = clamp(pos.x, 8.0, vp_size.x - ts.x - 8.0)
	pos.y = clamp(pos.y, 8.0, vp_size.y - ts.y - 8.0)
	_tooltip.position = pos


func _apply_mobile_scrollbar_visibility(hide_scrollbars: bool) -> void:
	var horizontal_bar := _scroll_container.get_h_scroll_bar()
	if horizontal_bar != null:
		horizontal_bar.visible = not hide_scrollbars
		horizontal_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		horizontal_bar.modulate = Color(1, 1, 1, 0.0 if hide_scrollbars else 1.0)
		horizontal_bar.custom_minimum_size.y = 0.0 if hide_scrollbars else horizontal_bar.custom_minimum_size.y
	var vertical_bar := _scroll_container.get_v_scroll_bar()
	if vertical_bar != null:
		vertical_bar.visible = not hide_scrollbars
		vertical_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vertical_bar.modulate = Color(1, 1, 1, 0.0 if hide_scrollbars else 1.0)
		vertical_bar.custom_minimum_size.x = 0.0 if hide_scrollbars else vertical_bar.custom_minimum_size.x

func _update_character_info() -> void:
	_character_name_card.text = _selected_character.name
	_character_description_card.text = _selected_character.description
	_character_portrait.texture = PortraitLibrary.load_portrait(_selected_character.character_id, "select")
	_character_portrait.tooltip_text = _selected_character.name
	_update_counter()

func _create_card_buttons() -> void:
	DebugLogger.log_system("CardSelectionScreen: creazione bottoni per %d carte" % _selected_character.specific_cards.size())
	
	# Pulisci griglia
	for child in _card_grid.get_children():
		child.queue_free()
	_card_buttons.clear()
	_selected_specific_cards.clear()
	
	# Attendi un frame per assicurare pulizia
	await get_tree().process_frame
	
	DebugLogger.log_system("CardSelectionScreen: CardGrid children prima: %d" % _card_grid.get_child_count())
	
	# Crea un bottone per ogni carta
	for card in _selected_character.specific_cards:
		var btn := _create_single_card_button(card)
		_card_grid.add_child(btn)
		_card_buttons.append(btn)
		DebugLogger.log_card("CardSelectionScreen: bottone aggiunto per %s, total: %d" % [card.card_name, _card_grid.get_child_count()])
	
	DebugLogger.log_system("CardSelectionScreen: creati %d bottoni, grid children: %d" % [_card_buttons.size(), _card_grid.get_child_count()])
	DebugLogger.log_system("CardSelectionScreen: CardGrid size: %s, visible: %s" % [_card_grid.size, _card_grid.visible])

func _create_single_card_button(card: CardData) -> CardUI:
	var btn := CARD_SCENE.instantiate() as CardUI
	btn.apply_layout(_card_button_size)
	btn.setup(card, true)
	_apply_card_button_style(btn, card, false)
	btn.card_clicked.connect(_on_card_button_pressed.bind(btn))
	btn.card_secondary_clicked.connect(_on_card_secondary_clicked.bind(btn))
	btn.card_long_pressed.connect(_on_card_long_pressed.bind(btn))
	btn.card_long_press_released.connect(_on_card_long_press_released.bind(btn))
	return btn

func _on_card_button_pressed(card: CardData, btn: CardUI) -> void:
	if _tooltip.visible and _tooltip_anchor_button == btn:
		_hide_tooltip()
	if card in _selected_specific_cards:
		# Deseleziona
		_selected_specific_cards.erase(card)
		_apply_card_button_style(btn, card, false)
		DebugLogger.log_card("CardSelectionScreen: deselezionata %s (totale: %d)" % [card.card_name, _selected_specific_cards.size()])
	else:
		# Seleziona solo se non abbiamo già 10
		if _selected_specific_cards.size() < 10:
			_selected_specific_cards.append(card)
			_apply_card_button_style(btn, card, true)
			DebugLogger.log_card("CardSelectionScreen: selezionata %s (totale: %d)" % [card.card_name, _selected_specific_cards.size()])
	
	_update_counter()


func _on_card_secondary_clicked(card: CardData, btn: CardUI) -> void:
	if _tooltip.visible and _tooltip_anchor_card == card and _tooltip_anchor_button == btn:
		_hide_tooltip()
		return
	_show_tooltip(card, btn)


func _on_card_long_pressed(card: CardData, btn: CardUI) -> void:
	_show_tooltip(card, btn)


func _on_card_long_press_released(card: CardData, btn: CardUI) -> void:
	if _tooltip_anchor_card == card and _tooltip_anchor_button == btn:
		_hide_tooltip()

func _update_counter() -> void:
	_selection_counter.text = "%d / 10" % _selected_specific_cards.size()
	_confirm_button.disabled = _selected_specific_cards.size() != 10

func _on_confirm_pressed() -> void:
	if _selected_specific_cards.size() != 10:
		DebugLogger.log_error("CardSelectionScreen: deve selezionare esattamente 10 carte, ne hai scelte %d" % _selected_specific_cards.size())
		return
	
	# Costruisci il mazzo finale: 10 specifiche + 10 base random
	var final_deck: Array[CardData] = []
	final_deck.append_array(_selected_specific_cards)
	
	# Copia il mazzo base e mescola
	var base_copy := _base_cards.duplicate()
	DeckManager.shuffle_deck(base_copy)
	
	# Prendi i primi 10 dal mazzo mescolato
	for i in range(10):
		if i < base_copy.size():
			final_deck.append(base_copy[i])
	
	# Salva nel GameManager e avvia la run
	GameManager.selected_character = _selected_character
	GameManager.player_deck = final_deck
	
	DebugLogger.log_system("CardSelectionScreen: mazzo costruito — 10 specifiche + 10 base random = %d carte" % final_deck.size())
	GameManager.start_run()

func _on_back_pressed() -> void:
	DebugLogger.log_system("CardSelectionScreen: ritorno al carosello personaggi")
	GameManager.start_character_selection()
