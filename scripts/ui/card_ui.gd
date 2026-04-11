## CardUI — Gestisce la visualizzazione e l'interazione di una singola carta

class_name CardUI
extends PanelContainer

signal card_clicked(card: CardData)
signal card_hovered(card: CardData)
signal card_unhovered(card: CardData)

var card_data: CardData = null
var is_playable: bool = true
# Se false, i dettagli delle carte non sono visibili
var show_card_details: bool = true

@onready var _image: TextureRect = $VBox/ImageArea
@onready var _name_label: Label = $VBox/NameLabel
@onready var _damage_label: Label = $VBox/EffectsBox/DamageLabel
@onready var _shield_label: Label = $VBox/EffectsBox/ShieldLabel
@onready var _heal_label: Label = $VBox/EffectsBox/HealLabel
@onready var _energy_label: Label = $VBox/EnergyLabel

const HOVER_SCALE := Vector2(1.08, 1.08)
const NORMAL_SCALE := Vector2(1.0, 1.0)

## Inizializza la carta con i dati forniti
func setup(data: CardData, playable: bool = true) -> void:
	card_data = data
	is_playable = playable
	_refresh_visuals()

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _refresh_visuals() -> void:
	if card_data == null:
		return

	if not show_card_details:
		_name_label.visible = false
		_damage_label.visible = false
		_shield_label.visible = false
		_heal_label.visible = false
		_energy_label.visible = false
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

	# Immagine carta
	var img_path := "res://assets/images/cards/%s.png" % card_data.image_key
	if ResourceLoader.exists(img_path):
		_image.texture = load(img_path)
	else:
		# Fallback: placeholder colorato in base al tipo predominante
		_image.texture = _get_placeholder_texture()

	_update_playable_state()

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
	if is_playable:
		card_hovered.emit(card_data)

func _on_mouse_exited() -> void:
	if card_data == null:
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", NORMAL_SCALE, 0.1 * Config.animation_speed)
	card_unhovered.emit(card_data)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if is_playable:
				card_clicked.emit(card_data)

## Placeholder texture colorato in base al tipo carta
func _get_card_back_texture() -> ImageTexture:
	var img := Image.create(120, 80, false, Image.FORMAT_RGB8)
	img.fill(Color(0.08, 0.08, 0.18))  # sfondo blu scuro
	# strisce diagonali decorative (dorso)
	for x in 120:
		for y in 80:
			if (x + y) % 12 < 2:
				img.set_pixel(x, y, Color(0.15, 0.15, 0.3))
	# bordo
	for x in 120:
		img.set_pixel(x, 0, Color(0.3, 0.3, 0.5))
		img.set_pixel(x, 79, Color(0.3, 0.3, 0.5))
	for y in 80:
		img.set_pixel(0, y, Color(0.3, 0.3, 0.5))
		img.set_pixel(119, y, Color(0.3, 0.3, 0.5))
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
	img.fill(color)
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
