## ActorPanelUI — Visualizza le info di un attore (HP, Energia, Nome, Portrait)

class_name ActorPanelUI
extends PanelContainer

signal end_turn_pressed

var _is_player: bool = false
var _hp_tween: Tween = null
var _status_label: Label = null
var _portrait_key: String = ""

@onready var _hbox: HBoxContainer = $HBox
@onready var _portrait_frame: PanelContainer = $HBox/PortraitFrame
@onready var _portrait: TextureRect = $HBox/PortraitFrame/Portrait
@onready var _info_box: VBoxContainer = $HBox/InfoBox
@onready var _name_label: Label = $HBox/InfoBox/NameLabel
@onready var _hp_bar: ProgressBar = $HBox/InfoBox/HPBar
@onready var _hp_label: Label = $HBox/InfoBox/HPBar/HPLabel
@onready var _energy_label: Label = $HBox/InfoBox/EnergyLabel
@onready var _end_turn_btn: Button = $HBox/InfoBox/EndTurnButton

func _ready() -> void:
	_end_turn_btn.pressed.connect(func(): end_turn_pressed.emit())
	_end_turn_btn.visible = false
	# Etichetta dinamica per icone status effect
	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.add_theme_font_size_override("font_size", 10)
	_status_label.visible = false
	$HBox/InfoBox.add_child(_status_label)
	# Posiziona dopo HPBar (indice 2)
	$HBox/InfoBox.move_child(_status_label, 2)

## Configura il pannello per il giocatore o il nemico
func setup(is_player: bool) -> void:
	_is_player = is_player
	_end_turn_btn.visible = false
	if not is_player:
		_end_turn_btn.queue_free()
	_portrait_key = "player_default" if is_player else "enemy_default"
	_portrait.texture = PortraitLibrary.load_portrait(_portrait_key, "combat")


func apply_layout(compact_touch_ui: bool, panel_height: float) -> void:
	custom_minimum_size.y = panel_height
	var horizontal_padding := 10.0 if compact_touch_ui else 8.0
	var vertical_padding := 8.0 if compact_touch_ui else 8.0
	var portrait_size := clampf(panel_height - 18.0, 70.0, 104.0 if compact_touch_ui else 82.0)
	_hbox.offset_left = horizontal_padding
	_hbox.offset_top = vertical_padding
	_hbox.offset_right = -horizontal_padding
	_hbox.offset_bottom = -vertical_padding
	_hbox.add_theme_constant_override("separation", 14 if compact_touch_ui else 12)
	_info_box.add_theme_constant_override("separation", 6 if compact_touch_ui else 4)
	_portrait_frame.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_portrait.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_name_label.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 16)
	_hp_bar.custom_minimum_size = Vector2(200.0, 26.0 if compact_touch_ui else 22.0)
	_hp_label.add_theme_font_size_override("font_size", 16 if compact_touch_ui else 14)
	_energy_label.add_theme_font_size_override("font_size", 16 if compact_touch_ui else 13)
	if _status_label != null:
		_status_label.add_theme_font_size_override("font_size", 14 if compact_touch_ui else 10)
	if is_instance_valid(_end_turn_btn):
		_end_turn_btn.custom_minimum_size = Vector2(150.0 if compact_touch_ui else 120.0, 44.0 if compact_touch_ui else 36.0)
		_end_turn_btn.add_theme_font_size_override("font_size", 16 if compact_touch_ui else 14)

## Aggiorna tutti i valori visualizzati.
## Se animate=true la HP bar scorre con un Tween fluido.
func update_actor(actor: ActorData, animate: bool = false) -> void:
	_name_label.text = actor.actor_name
	var portrait_key := actor.actor_name.to_snake_case().to_lower().replace("'", "")
	if portrait_key != _portrait_key:
		_portrait.texture = PortraitLibrary.load_named_portrait(actor.actor_name, "combat")
		_portrait_key = portrait_key
	_hp_bar.max_value = actor.max_hp
	_hp_label.text = "%d / %d" % [actor.hp, actor.max_hp]
	_energy_label.text = "⚡ Energia: %d / %d" % [actor.energy, actor.max_energy]

	var ratio := float(actor.hp) / float(actor.max_hp)
	if ratio > 0.6:
		_hp_bar.modulate = Color(0.2, 0.9, 0.3)
		_hp_label.add_theme_color_override("font_color", Color(0.02, 0.04, 0.10, 1))
	elif ratio > 0.3:
		_hp_bar.modulate = Color(0.9, 0.7, 0.1)
		_hp_label.add_theme_color_override("font_color", Color(0.02, 0.04, 0.10, 1))
	else:
		_hp_bar.modulate = Color(0.9, 0.2, 0.1)
		_hp_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))

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

## Aggiorna le icone degli effetti di stato
func update_status_effects(effects: Dictionary) -> void:
	if _status_label == null:
		return
	var parts: Array[String] = []
	if effects.get("burn", 0) > 0:    parts.append("🔥[%d]" % effects["burn"])
	if effects.get("poison", 0) > 0:  parts.append("☠[%d]" % effects["poison"])
	if effects.get("freeze", 0) > 0:  parts.append("❄")
	if effects.get("haste", 0) > 0:   parts.append("⚡+")
	if effects.get("blessed", 0) > 0: parts.append("✨")
	_status_label.text = " ".join(parts)
	_status_label.visible = parts.size() > 0
