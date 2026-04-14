## ThemeBuilder — Applica stile sci-fi procedurale all'intera UI
##
## I temi Godot 4 possono essere creati via codice tramite Theme.set_*.
## Questo nodo va aggiunto come autoload OPPURE chiamato manualmente da ogni
## screen in _ready(). Alternativa: get_tree().root.theme = ThemeBuilder.build()

class_name ThemeBuilder
extends Node

## Costruisce e ritorna un Theme sci-fi. Chiamare una volta in _ready() della root.
static func build() -> Theme:
	var theme := Theme.new()

	# --- Palette colori base ---
	var cyan      := Color(0.0,  0.75, 1.0,  1)
	var cyan_dim  := Color(0.0,  0.5,  0.7,  1)
	var white_dim := Color(0.85, 0.90, 0.95, 1)
	var panel_bg  := Color(0.08, 0.10, 0.20, 1)

	# --- Label ---
	theme.set_color("font_color", "Label", white_dim)

	# --- Button ---
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.05, 0.15, 0.35, 1)
	btn_normal.border_color = cyan_dim
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(6)
	btn_normal.content_margin_left   = 16
	btn_normal.content_margin_right  = 16
	btn_normal.content_margin_top    = 8
	btn_normal.content_margin_bottom = 8

	var btn_hover := btn_normal.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.08, 0.25, 0.55, 1)
	btn_hover.border_color = cyan

	var btn_pressed := btn_normal.duplicate() as StyleBoxFlat
	btn_pressed.bg_color = Color(0.02, 0.10, 0.25, 1)

	var btn_disabled := btn_normal.duplicate() as StyleBoxFlat
	btn_disabled.bg_color = Color(0.05, 0.07, 0.12, 1)
	btn_disabled.border_color = Color(0.3, 0.3, 0.4, 1)

	theme.set_stylebox("normal",   "Button", btn_normal)
	theme.set_stylebox("hover",    "Button", btn_hover)
	theme.set_stylebox("pressed",  "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_color("font_color",          "Button", white_dim)
	theme.set_color("font_hover_color",    "Button", Color(1, 1, 1, 1))
	theme.set_color("font_pressed_color",  "Button", cyan)
	theme.set_color("font_disabled_color", "Button", Color(0.4, 0.4, 0.5, 1))

	# --- PanelContainer ---
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = panel_bg
	panel_style.border_color = Color(0.15, 0.25, 0.55, 1)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 8
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 8
	panel_style.content_margin_bottom = 8
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	var screen_panel := StyleBoxFlat.new()
	screen_panel.bg_color = Color(0.05, 0.08, 0.16, 0.92)
	screen_panel.border_color = Color(0.24, 0.52, 0.88, 1)
	screen_panel.set_border_width_all(2)
	screen_panel.set_corner_radius_all(10)
	screen_panel.content_margin_left = 10
	screen_panel.content_margin_top = 10
	screen_panel.content_margin_right = 10
	screen_panel.content_margin_bottom = 10
	screen_panel.shadow_color = Color(0.01, 0.02, 0.05, 0.55)
	screen_panel.shadow_size = 8
	theme.set_stylebox("panel", "ScreenPanel", screen_panel)

	var selection_panel := StyleBoxFlat.new()
	selection_panel.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	selection_panel.border_color = Color(0.0, 0.0, 0.0, 0.0)
	selection_panel.set_border_width_all(0)
	selection_panel.set_corner_radius_all(0)
	selection_panel.content_margin_left = 0
	selection_panel.content_margin_top = 0
	selection_panel.content_margin_right = 0
	selection_panel.content_margin_bottom = 0
	selection_panel.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	selection_panel.shadow_size = 0
	theme.set_stylebox("panel", "SelectionPanel", selection_panel)

	var portrait_panel := StyleBoxFlat.new()
	portrait_panel.bg_color = Color(0.08, 0.11, 0.20, 0.96)
	portrait_panel.border_color = Color(0.40, 0.78, 1.0, 0.95)
	portrait_panel.set_border_width_all(2)
	portrait_panel.set_corner_radius_all(12)
	portrait_panel.content_margin_left = 8
	portrait_panel.content_margin_top = 8
	portrait_panel.content_margin_right = 8
	portrait_panel.content_margin_bottom = 8
	portrait_panel.shadow_color = Color(0.02, 0.04, 0.10, 0.48)
	portrait_panel.shadow_size = 7
	theme.set_stylebox("panel", "PortraitPanel", portrait_panel)

	var hud_panel := StyleBoxFlat.new()
	hud_panel.bg_color = Color(0.04, 0.07, 0.14, 0.94)
	hud_panel.border_color = Color(0.22, 0.48, 0.82, 0.92)
	hud_panel.set_border_width_all(2)
	hud_panel.set_corner_radius_all(8)
	hud_panel.content_margin_left = 6
	hud_panel.content_margin_top = 6
	hud_panel.content_margin_right = 6
	hud_panel.content_margin_bottom = 6
	hud_panel.shadow_color = Color(0.01, 0.02, 0.06, 0.42)
	hud_panel.shadow_size = 6
	theme.set_stylebox("panel", "HudPanel", hud_panel)

	var pile_panel := StyleBoxFlat.new()
	pile_panel.bg_color = Color(0.06, 0.09, 0.17, 0.96)
	pile_panel.border_color = Color(0.30, 0.66, 0.96, 0.92)
	pile_panel.set_border_width_all(2)
	pile_panel.set_corner_radius_all(10)
	pile_panel.content_margin_left = 4
	pile_panel.content_margin_top = 4
	pile_panel.content_margin_right = 4
	pile_panel.content_margin_bottom = 4
	pile_panel.shadow_color = Color(0.01, 0.02, 0.06, 0.36)
	pile_panel.shadow_size = 5
	theme.set_stylebox("panel", "PilePanel", pile_panel)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.07, 0.09, 0.18, 1)
	card_style.border_color = Color(0.24, 0.56, 0.92, 1)
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(8)
	card_style.shadow_color = Color(0.01, 0.02, 0.06, 0.45)
	card_style.shadow_size = 6
	theme.set_stylebox("panel", "CardUI", card_style)

	var separator_style := StyleBoxLine.new()
	separator_style.color = Color(0.28, 0.52, 0.84, 0.55)
	separator_style.thickness = 2
	theme.set_stylebox("separator", "HSeparator", separator_style)
	theme.set_stylebox("separator", "VSeparator", separator_style)

	# --- ProgressBar ---
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color(0.05, 0.06, 0.12, 1)
	pb_bg.set_border_width_all(1)
	pb_bg.border_color = Color(0.2, 0.3, 0.5, 1)
	pb_bg.set_corner_radius_all(3)

	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = Color(0.2, 0.9, 0.3, 1)
	pb_fill.set_corner_radius_all(3)

	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill",       "ProgressBar", pb_fill)

	return theme
