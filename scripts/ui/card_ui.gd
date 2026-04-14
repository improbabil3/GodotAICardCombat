## CardUI — Gestisce la visualizzazione e l'interazione di una singola carta

class_name CardUI
extends PanelContainer

signal card_clicked(card: CardData)
signal card_secondary_clicked(card: CardData)
signal card_hovered(card: CardData)
signal card_unhovered(card: CardData)
signal card_long_pressed(card: CardData)
signal card_long_press_released(card: CardData)

var card_data: CardData = null
var is_playable: bool = true
# Se false, i dettagli delle carte non sono visibili
var show_card_details: bool = true

var _status_label: Label = null
var _press_active: bool = false
var _press_start_pos: Vector2 = Vector2.ZERO

@onready var _vbox: VBoxContainer = $VBox
@onready var _image_frame: PanelContainer = $VBox/ImageFrame
@onready var _image: TextureRect = $VBox/ImageFrame/ImageArea
@onready var _name_label: Label = $VBox/NameLabel
@onready var _effects_box: VBoxContainer = $VBox/EffectsBox
@onready var _damage_label: Label = $VBox/EffectsBox/DamageLabel
@onready var _shield_label: Label = $VBox/EffectsBox/ShieldLabel
@onready var _heal_label: Label = $VBox/EffectsBox/HealLabel
@onready var _energy_label: Label = $VBox/EnergyLabel

const HOVER_SCALE := Vector2(1.08, 1.08)
const NORMAL_SCALE := Vector2(1.0, 1.0)
const LONG_PRESS_MOVE_TOLERANCE := 18.0

## Inizializza la carta con i dati forniti
func setup(data: CardData, playable: bool = true) -> void:
	card_data = data
	is_playable = playable
	if is_node_ready():
		_refresh_visuals()
		_apply_layout(custom_minimum_size)

func _ready() -> void:
	clip_contents = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	# Etichetta dinamica per simbolo status effect
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 9)
	_status_label.visible = false
	$VBox/EffectsBox.add_child(_status_label)
	_apply_layout(custom_minimum_size)
	if card_data != null:
		_refresh_visuals()


func apply_layout(card_size: Vector2) -> void:
	custom_minimum_size = card_size
	if not is_node_ready():
		return
	_apply_layout(card_size)


func _apply_layout(card_size: Vector2) -> void:
	var compact_touch_ui := OS.has_feature("mobile") or get_viewport_rect().size.x <= 900.0
	var width: float = maxf(126.0 if compact_touch_ui else 110.0, card_size.x)
	var height: float = maxf(186.0 if compact_touch_ui else 160.0, card_size.y)
	var padding: float = clampf(width * (0.06 if compact_touch_ui else 0.05), 8.0 if compact_touch_ui else 6.0, 12.0 if compact_touch_ui else 10.0)
	var name_font: int = 17 if width >= 170.0 else (15 if width >= 145.0 else 13)
	var effect_font: int = 16 if width >= 170.0 else (14 if width >= 145.0 else 12)
	if compact_touch_ui:
		name_font += 2
		effect_font += 2
	var energy_font: int = effect_font
	var separation: int = (8 if compact_touch_ui else 6) if width >= 170.0 else (6 if compact_touch_ui else 4)
	var image_height: float = clampf(height * 0.50, 104.0 if compact_touch_ui else 96.0, 170.0 if compact_touch_ui else 152.0)
	_vbox.offset_left = padding
	_vbox.offset_top = padding
	_vbox.offset_right = -padding
	_vbox.offset_bottom = -padding
	_vbox.add_theme_constant_override("separation", separation)
	_image_frame.custom_minimum_size = Vector2(width - padding * 2.0, image_height)
	_image.custom_minimum_size = Vector2(width - padding * 2.0 - 8.0, image_height - 8.0)
	_effects_box.size_flags_vertical = 0
	_effects_box.add_theme_constant_override("separation", 3 if compact_touch_ui else 2)
	_name_label.add_theme_font_size_override("font_size", name_font)
	_damage_label.add_theme_font_size_override("font_size", effect_font)
	_shield_label.add_theme_font_size_override("font_size", effect_font)
	_heal_label.add_theme_font_size_override("font_size", effect_font)
	_energy_label.add_theme_font_size_override("font_size", energy_font)
	if _status_label != null:
		_status_label.add_theme_font_size_override("font_size", max(12 if compact_touch_ui else 10, effect_font - 2))

func _refresh_visuals() -> void:
	if card_data == null:
		return

	if not show_card_details:
		_name_label.visible = false
		_damage_label.visible = false
		_shield_label.visible = false
		_heal_label.visible = false
		_energy_label.visible = false
		if _status_label != null:
			_status_label.visible = false
		_image.texture = _get_card_back_texture()
		_update_playable_state()
		return

	_name_label.visible = true
	_energy_label.visible = true
	_name_label.text = card_data.card_name
	_energy_label.text = "ENE: %d" % card_data.energy_cost

	# Effetti — mostra solo quelli attivi
	_damage_label.visible = card_data.damage > 0
	_shield_label.visible = card_data.shield > 0
	_heal_label.visible = card_data.heal > 0

	if card_data.damage > 0:
		_damage_label.text = "⚔ DAN +%d" % card_data.damage
	if card_data.shield > 0:
		_shield_label.text = "🛡 SCU +%d" % card_data.shield
	if card_data.heal > 0:
		_heal_label.text = "💚 GUA +%d" % card_data.heal

	# Status effect symbol
	if _status_label != null:
		if card_data.status_effect != "":
			var symbol := _status_symbol(card_data.status_effect)
			var tgt_str := "→sé" if card_data.status_target == "self" else "→op"
			_status_label.text = "%s%s" % [symbol, tgt_str]
			_status_label.visible = show_card_details
		else:
			_status_label.visible = false

	# Immagine carta
	var img_path := "res://assets/images/cards/%s.png" % card_data.image_key
	if ResourceLoader.exists(img_path):
		_image.texture = load(img_path)
	else:
		# Fallback: placeholder colorato in base al tipo predominante
		_image.texture = _get_placeholder_texture()

	_update_playable_state()

## Mappa nome effetto di stato → simbolo emoji
func _status_symbol(effect: String) -> String:
	match effect:
		"burn":    return "🔥"
		"poison":  return "☠"
		"freeze":  return "❄"
		"haste":   return "⚡"
		"blessed": return "✨"
	return "?"

func _update_playable_state() -> void:
	modulate = Color.WHITE if is_playable else Color(0.4, 0.4, 0.4, 0.8)

func set_playable(playable: bool) -> void:
	is_playable = playable
	_update_playable_state()

func _on_mouse_entered() -> void:
	if card_data == null:
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", HOVER_SCALE, 0.1 * Config.animation_speed)
	card_hovered.emit(card_data)

func _on_mouse_exited() -> void:
	if card_data == null:
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", NORMAL_SCALE, 0.1 * Config.animation_speed)
	card_unhovered.emit(card_data)

func _on_gui_input(event: InputEvent) -> void:
	if card_data == null:
		return
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_start_touch_preview(touch_event.position)
		else:
			_finish_touch_preview()
		return
	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if _press_active and drag_event.position.distance_to(_press_start_pos) > LONG_PRESS_MOVE_TOLERANCE:
			_cancel_touch_preview(true)
		return
	if event is InputEventMouseMotion and _uses_touch_interaction():
		var motion_event := event as InputEventMouseMotion
		if _press_active and motion_event.position.distance_to(_press_start_pos) > LONG_PRESS_MOVE_TOLERANCE:
			_cancel_touch_preview(true)
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not _uses_touch_interaction() and mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			card_secondary_clicked.emit(card_data)
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if _uses_touch_interaction():
				if mouse_event.pressed:
					_start_touch_preview(mouse_event.position)
				else:
					_finish_touch_preview()
				return
			if mouse_event.pressed and is_playable:
				card_clicked.emit(card_data)


func _uses_touch_interaction() -> bool:
	return OS.has_feature("mobile")


func _start_touch_preview(press_pos: Vector2) -> void:
	if card_data == null:
		return
	_press_start_pos = press_pos
	_press_active = true
	card_long_pressed.emit(card_data)


func _finish_touch_preview() -> void:
	if not _press_active:
		return
	if card_data != null:
		card_long_press_released.emit(card_data)
	if is_playable:
		card_clicked.emit(card_data)
	_press_active = false


func _cancel_touch_preview(emit_release: bool) -> void:
	if emit_release and _press_active and card_data != null:
		card_long_press_released.emit(card_data)
	_press_active = false

## Placeholder texture colorato in base al tipo carta
func _get_card_back_texture() -> ImageTexture:
	var img := Image.create(120, 80, false, Image.FORMAT_RGB8)
	img.fill(Color(0.06, 0.08, 0.16))
	# strisce diagonali decorative (dorso)
	for x in 120:
		for y in 80:
			var pixel := Color(0.06, 0.08, 0.16).lerp(Color(0.10, 0.14, 0.26), float(x + y) / 200.0)
			if (x + y) % 12 < 2:
				pixel = Color(0.16, 0.20, 0.34)
			img.set_pixel(x, y, pixel)
	# bordo
	for x in 120:
		img.set_pixel(x, 0, Color(0.36, 0.55, 0.82))
		img.set_pixel(x, 79, Color(0.28, 0.36, 0.58))
	for y in 80:
		img.set_pixel(0, y, Color(0.36, 0.55, 0.82))
		img.set_pixel(119, y, Color(0.28, 0.36, 0.58))
	return ImageTexture.create_from_image(img)

func _get_placeholder_texture() -> ImageTexture:
	var img := Image.create(120, 80, false, Image.FORMAT_RGB8)
	var color: Color
	if card_data.damage > 0 and card_data.shield > 0:
		color = Color(0.7, 0.5, 0.0)   # dorato — danno+scudo
	elif card_data.damage > 0 and card_data.heal > 0:
		color = Color(0.7, 0.0, 0.5)   # viola — danno+guarigione
	elif card_data.shield > 0 and card_data.heal > 0:
		color = Color(0.0, 0.5, 0.7)   # blu-verde — scudo+guarigione
	elif card_data.damage > 0:
		color = Color(0.8, 0.1, 0.1)   # rosso — danno
	elif card_data.shield > 0:
		color = Color(0.1, 0.3, 0.8)   # blu — scudo
	else:
		color = Color(0.1, 0.7, 0.3)   # verde — guarigione
	for x in 120:
		for y in 80:
			var gradient := clampf(float(x) / 119.0 * 0.35 + float(y) / 79.0 * 0.15, 0.0, 0.45)
			var pixel := color.darkened(0.28).lerp(color.lightened(0.08), gradient)
			if abs(x - 60) < 4 or abs(y - 40) < 3:
				pixel = pixel.lightened(0.08)
			img.set_pixel(x, y, pixel)
	for x in 120:
		img.set_pixel(x, 0, Color.WHITE.darkened(0.25))
		img.set_pixel(x, 79, color.darkened(0.40))
	for y in 80:
		img.set_pixel(0, y, Color.WHITE.darkened(0.25))
		img.set_pixel(119, y, color.darkened(0.40))
	return ImageTexture.create_from_image(img)

## Animazione: vola verso una posizione target (usata da animazioni giocata/scarto)
func fly_to(target_global_pos: Vector2, duration: float, on_complete: Callable = Callable()) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_global_pos, duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration * 0.8)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

## Animazione: pesca (entra dalla posizione del mazzo)
func animate_draw(from_pos: Vector2, to_pos: Vector2) -> void:
	global_position = from_pos
	modulate.a = 0.0
	scale = Vector2(0.3, 0.3)
	var tween := create_tween()
	var dur := 0.3 * Config.animation_speed
	tween.tween_property(self, "global_position", to_pos, dur).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 1.0, dur)
	tween.parallel().tween_property(self, "scale", NORMAL_SCALE, dur).set_ease(Tween.EASE_OUT)
