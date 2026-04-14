## CardSelectionScreen — Schermata di selezione carte specifiche del personaggio
##
## L'utente sceglie esattamente 10 carte dal pool di 20 specifiche del personaggio.
## Le altre 10 carte verranno scelte casualmente dal mazzo base.

extends Control

const CARD_SCENE := preload("res://scenes/card/card.tscn")

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _content_panel: PanelContainer = $CenterContainer/ContentPanel
@onready var _layout_box: VBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer
@onready var _top_bar: HBoxContainer = $CenterContainer/ContentPanel/ContentMargin/VBoxContainer/TopBar
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
	if card.damage > 0: effects.append("Danno: +%d" % card.damage)
	if card.shield > 0: effects.append("Scudo: +%d" % card.shield)
	if card.heal > 0: effects.append("Guarigione: +%d" % card.heal)
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


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var compact_touch_ui := _uses_compact_mobile_layout()
	var portrait_layout := viewport_size.y > viewport_size.x
	var layout_width: float = clampf(viewport_size.x - (24.0 if compact_touch_ui else 96.0), 320.0, 1820.0)
	var layout_height: float = clampf(viewport_size.y - (24.0 if compact_touch_ui else 64.0), 480.0 if compact_touch_ui else 420.0, 980.0 if compact_touch_ui else 940.0)
	var spacing: int = 12 if compact_touch_ui else (16 if viewport_size.x >= 900.0 else 10)
	var grid_gap: int = 10 if compact_touch_ui else (8 if viewport_size.x >= 900.0 else 6)
	var top_height: float = clampf(viewport_size.y * (0.12 if compact_touch_ui else 0.10), 84.0 if compact_touch_ui else 68.0, 112.0 if compact_touch_ui else 88.0)
	var bottom_height: float = 64.0 if compact_touch_ui else 56.0
	var title_height: float = 40.0 if compact_touch_ui else 34.0
	var max_grid_height: float = maxf(220.0, layout_height - top_height - title_height - bottom_height - float(spacing * 3))
	var total_cards: int = _selected_character.specific_cards.size() if _selected_character != null else 20
	var scroll_height: float = max_grid_height
	var columns: int = 2 if portrait_layout else (4 if compact_touch_ui else (5 if viewport_size.x < 1500.0 else 6))
	var width_limit: float = (layout_width - float((columns - 1) * grid_gap)) / float(columns)
	var card_width: float = clampf(width_limit, 168.0 if portrait_layout else 176.0, 240.0 if portrait_layout else 220.0)
	var card_height: float = clampf(card_width * (1.42 if compact_touch_ui else 1.34), 238.0 if portrait_layout else 226.0, 340.0 if portrait_layout else 300.0)
	var row_count: int = ceili(float(total_cards) / float(columns))
	var full_grid_height := card_height * float(row_count) + float((row_count - 1) * grid_gap)
	scroll_height = min(full_grid_height, max_grid_height)
	var total_height: float = top_height + title_height + scroll_height + bottom_height + float(spacing * 3)

	_layout_box.custom_minimum_size = Vector2(layout_width, 0.0)
	_layout_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_layout_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_layout_box.add_theme_constant_override("separation", spacing)
	_content_panel.position = Vector2(
		floor((viewport_size.x - layout_width) * 0.5),
		floor((viewport_size.y - total_height) * 0.5)
	)
	_layout_box.position = Vector2(
		0.0,
		0.0
	)
	_top_bar.custom_minimum_size = Vector2(layout_width, top_height)
	_top_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_top_bar.add_theme_constant_override("separation", spacing)
	_top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 24 if compact_touch_ui else (20 if viewport_size.x >= 900.0 else 17))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selection_counter.add_theme_font_size_override("font_size", 20 if compact_touch_ui else (18 if viewport_size.x >= 900.0 else 15))
	_character_name_card.add_theme_font_size_override("font_size", 28 if compact_touch_ui else (24 if viewport_size.x >= 900.0 else 19))
	_character_description_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_description_card.add_theme_font_size_override("font_size", 18 if compact_touch_ui else (15 if viewport_size.x >= 900.0 else 13))
	_tooltip.custom_minimum_size = Vector2(260.0 if _uses_touch_tooltip_mode() else 200.0, 0.0)
	_card_grid.add_theme_constant_override("h_separation", grid_gap)
	_card_grid.add_theme_constant_override("v_separation", grid_gap)
	_scroll_container.custom_minimum_size = Vector2(layout_width, scroll_height)
	_scroll_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_scroll_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_card_grid.columns = columns
	_card_grid.custom_minimum_size = Vector2(layout_width, full_grid_height)
	_bottom_bar.custom_minimum_size = Vector2(layout_width, bottom_height)
	_bottom_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bottom_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_back_button.custom_minimum_size = Vector2(clampf(layout_width * 0.20, 120.0, 180.0), bottom_height)
	_confirm_button.custom_minimum_size = Vector2(clampf(layout_width * 0.36, 180.0, 320.0), bottom_height)
	_back_button.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 16)
	_confirm_button.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 16)
	_confirm_button.size_flags_horizontal = 0
	_card_button_size = Vector2(card_width, card_height)
	DebugLogger.log_system("CardSelectionScreen: viewport=%s layout=(%f,%f) columns=%d card=(%f,%f) grid_h=%f" % [viewport_size, layout_width, layout_height, columns, card_width, card_height, scroll_height])

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
