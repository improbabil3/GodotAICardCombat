## ActorPanelUI — Visualizza le info di un attore (HP, Energia, Nome, Portrait)

class_name ActorPanelUI
extends PanelContainer

signal end_turn_pressed

var _is_player: bool = false
var _hp_tween: Tween = null

@onready var _portrait: TextureRect = $HBox/Portrait
@onready var _name_label: Label = $HBox/InfoBox/NameLabel
@onready var _hp_bar: ProgressBar = $HBox/InfoBox/HPBar
@onready var _hp_label: Label = $HBox/InfoBox/HPBar/HPLabel
@onready var _energy_label: Label = $HBox/InfoBox/EnergyLabel
@onready var _end_turn_btn: Button = $HBox/InfoBox/EndTurnButton

func _ready() -> void:
	_end_turn_btn.pressed.connect(func(): end_turn_pressed.emit())
	_end_turn_btn.visible = false

## Configura il pannello per il giocatore o il nemico
func setup(is_player: bool) -> void:
	_is_player = is_player
	_end_turn_btn.visible = false
	if not is_player:
		_end_turn_btn.queue_free()
	# Portrait placeholder procedurale: player=ciano, enemy=rosso
	var portrait_color := Color(0.1, 0.6, 0.9) if is_player else Color(0.8, 0.2, 0.2)
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(portrait_color)
	# Bordo scuro
	for x in 64:
		for y in 64:
			if x < 2 or x > 61 or y < 2 or y > 61:
				img.set_pixel(x, y, Color(0.05, 0.05, 0.1, 1))
	_portrait.texture = ImageTexture.create_from_image(img)

## Aggiorna tutti i valori visualizzati.
## Se animate=true la HP bar scorre con un Tween fluido.
func update_actor(actor: ActorData, animate: bool = false) -> void:
	_name_label.text = actor.actor_name
	_hp_bar.max_value = actor.max_hp
	_hp_label.text = "%d / %d" % [actor.hp, actor.max_hp]
	_energy_label.text = "⚡ Energia: %d / %d" % [actor.energy, actor.max_energy]

	var ratio := float(actor.hp) / float(actor.max_hp)
	if ratio > 0.6:
		_hp_bar.modulate = Color(0.2, 0.9, 0.3)
	elif ratio > 0.3:
		_hp_bar.modulate = Color(0.9, 0.7, 0.1)
	else:
		_hp_bar.modulate = Color(0.9, 0.2, 0.1)

	if _hp_tween:
		_hp_tween.kill()
		_hp_tween = null

	if animate and Config.animation_speed > 0.0:
		_hp_tween = create_tween()
		_hp_tween.tween_property(_hp_bar, "value", float(actor.hp), 0.4 * Config.animation_speed)\
			.set_ease(Tween.EASE_OUT)
	else:
		_hp_bar.value = actor.hp

## Ritorna il nodo HPBar (per AnimationManager)
func get_hp_bar() -> ProgressBar:
	return _hp_bar

## Mostra/nasconde il bottone Fine Turno
func show_end_turn_button(visible: bool) -> void:
	if _is_player and is_instance_valid(_end_turn_btn):
		_end_turn_btn.visible = visible

## Animazione: flash di colore (danno = rosso, guarigione = verde)
func flash(color: Color) -> void:
	var tween := create_tween()
	var dur := 0.15 * Config.animation_speed
	tween.tween_property(self, "modulate", color, dur)
	tween.tween_property(self, "modulate", Color.WHITE, dur)

## Animazione: shake (danno subito)
func shake() -> void:
	var origin := position
	var tween := create_tween()
	tween.tween_property(self, "position", origin + Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", origin - Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", origin + Vector2(4, 0), 0.04)
	tween.tween_property(self, "position", origin, 0.04)
