## AnimationManager — Gestisce le animazioni delle carte
##
## Centralizza tutte le animazioni per non inquinare GameScreen.
## Usa Tween Godot 4. Ogni animazione ritorna la durata (in secondi) in modo
## che il caller possa attendere tramite await o segnale.

class_name AnimationManager
extends RefCounted

## Emesso quando tutte le animazioni in coda sono completate
signal all_done

var _pending: int = 0

# ── Pesca del mazzo ──────────────────────────────────────────────────────────

## Anima la pescata di una serie di cardUI, partendo dalla posizione del mazzo.
## Ritorna la durata totale dell'intera sequenza.
func animate_draw_sequence(
	card_uis: Array,
	deck_global_pos: Vector2,
	delay_between: float = 0.15
) -> float:
	var total_duration := 0.0
	for i in card_uis.size():
		var card_ui: CardUI = card_uis[i]
		var delay := i * delay_between * Config.animation_speed
		var draw_dur := 0.3 * Config.animation_speed

		# Posizione finale = quella corrente (già nel container)
		var target_pos := card_ui.global_position

		# Parte dalla posizione del mazzo
		card_ui.global_position = deck_global_pos
		card_ui.modulate.a = 0.0
		card_ui.scale = Vector2(0.4, 0.4)

		var tween := card_ui.create_tween()
		if delay > 0.0:
			tween.tween_interval(delay)
		tween.tween_property(card_ui, "global_position", target_pos, draw_dur).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card_ui, "modulate:a", 1.0, draw_dur)
		tween.parallel().tween_property(card_ui, "scale", Vector2.ONE, draw_dur).set_ease(Tween.EASE_OUT)

		total_duration = max(total_duration, delay + draw_dur)

	return total_duration

# ── Giocata carta ────────────────────────────────────────────────────────────

## Anima una carta che vola verso la zona intenti e svanisce.
func animate_card_played(
	card_ui: CardUI,
	target_global_pos: Vector2,
	on_complete: Callable = Callable()
) -> void:
	var dur := 0.35 * Config.animation_speed
	var tween := card_ui.create_tween()
	tween.tween_property(card_ui, "global_position", target_global_pos, dur).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(card_ui, "scale", Vector2(0.5, 0.5), dur)
	tween.parallel().tween_property(card_ui, "modulate:a", 0.0, dur * 0.8)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

# ── Scarto carta ─────────────────────────────────────────────────────────────

## Anima una carta che vola verso il cimitero.
func animate_discard(
	card_ui: CardUI,
	graveyard_global_pos: Vector2,
	delay: float = 0.0,
	on_complete: Callable = Callable()
) -> void:
	var dur := 0.25 * Config.animation_speed
	var tween := card_ui.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(card_ui, "global_position", graveyard_global_pos, dur).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(card_ui, "modulate:a", 0.0, dur)
	tween.parallel().tween_property(card_ui, "scale", Vector2(0.3, 0.3), dur)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

# ── Mischia mazzo ────────────────────────────────────────────────────────────

## Anima lo shake del nodo mazzo (riciclo cimitero).
func animate_shuffle(deck_node: Control, on_complete: Callable = Callable()) -> void:
	var origin := deck_node.position
	var tween := deck_node.create_tween()
	var amp := 8.0
	var d := 0.06 * Config.animation_speed
	tween.tween_property(deck_node, "position", origin + Vector2(amp, 0), d)
	tween.tween_property(deck_node, "position", origin - Vector2(amp, 0), d)
	tween.tween_property(deck_node, "position", origin + Vector2(amp * 0.5, 0), d)
	tween.tween_property(deck_node, "position", origin - Vector2(amp * 0.5, 0), d)
	tween.tween_property(deck_node, "position", origin, d)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

# ── Danno ricevuto ───────────────────────────────────────────────────────────

## Flash rosso + shake sul pannello attore che subisce danno.
func animate_damage_received(panel: ActorPanelUI) -> void:
	panel.flash(Color(1.5, 0.2, 0.2, 1))
	panel.shake()

## Flash verde per guarigione.
func animate_healed(panel: ActorPanelUI) -> void:
	panel.flash(Color(0.2, 1.5, 0.3, 1))

## Flash blu per scudo attivato.
func animate_shield_activated(panel: ActorPanelUI) -> void:
	panel.flash(Color(0.3, 0.5, 1.8, 1))

# ── HP Bar ───────────────────────────────────────────────────────────────────

## Tween fluido sulla ProgressBar HP.
func animate_hp_bar(hp_bar: ProgressBar, new_value: float) -> void:
	var tween := hp_bar.create_tween()
	tween.tween_property(hp_bar, "value", new_value, 0.4 * Config.animation_speed).set_ease(Tween.EASE_OUT)

# ── Counter flash ────────────────────────────────────────────────────────────

## Flash su un Label quando il suo valore cambia.
func flash_label(label: Label, flash_color: Color = Color(2.0, 2.0, 0.5, 1)) -> void:
	var tween := label.create_tween()
	tween.tween_property(label, "modulate", flash_color, 0.1)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2)
