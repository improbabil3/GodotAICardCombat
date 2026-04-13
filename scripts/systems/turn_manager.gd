## TurnManager — Macchina a stati finiti per la gestione dei turni
##
## Stati:
##   STATUS_START → danno veleno a inizio turno (prima del draw nemico)
##   ENEMY_DRAW   → il nemico pesca le carte (con FREEZE/HASTE applicato)
##   ENEMY_PLAY   → l'AI del nemico gioca (applica status effect delle carte)
##   PLAYER_DRAW  → il giocatore pesca le sue carte (con FREEZE/HASTE applicato)
##   PLAYER_PLAY  → il giocatore interagisce (attende "Fine Turno")
##   RESOLUTION   → risoluzione effetti (guarigione, attacco, contro-attacco; BLESSED impedisce morte)
##   TURN_END     → danno BURN, effetti BLESSED, reset energia/intenti
##   GAME_OVER    → stato terminale, non si avanza oltre
##
## Il segnale state_changed è l'unico punto di aggiornamento UI.

class_name TurnManager
extends RefCounted

enum State {
	STATUS_START,
	ENEMY_DRAW,
	ENEMY_PLAY,
	PLAYER_DRAW,
	PLAYER_PLAY,
	RESOLUTION,
	TURN_END,
	GAME_OVER
}

## Emesso quando lo stato cambia
signal state_changed(new_state: State)

## Emesso all'inizio di ogni nuovo turno numerico
signal turn_started(turn_number: int)

## Emesso quando la risoluzione è completata e la partita continua
signal turn_ended

## Emesso quando l'AI ha giocato le sue carte (per animazioni)
signal enemy_played_cards(cards: Array)

## Emesso quando la partita termina
signal game_over(player_won: bool)

## Emesso quando un effetto di stato infligge danno (per animazione UI)
signal status_damage(actor_name: String, effect_name: String, amount: int)

## Emesso quando un effetto di stato modifica l'energia (Freeze/Haste)
signal status_energy_changed(actor_name: String, effect_name: String, delta: int)

## Emesso quando un effetto di stato viene applicato a un attore
signal status_applied(actor_name: String, effect_name: String)

## Emesso quando un effetto di stato scade o viene rimosso
signal status_expired(actor_name: String, effect_name: String)

var current_state: State = State.STATUS_START
var turn_number: int = 0

var _player: ActorData = null
var _enemy: ActorData = null
var _deck_manager: DeckManager = null
var _enemy_ai: EnemyAI = null
var _resolver: CombatResolver = null

func setup(player: ActorData, enemy: ActorData) -> void:
	_player = player
	_enemy = enemy
	_deck_manager = DeckManager.new()
	_enemy_ai = EnemyAI.new()
	_resolver = CombatResolver.new()
	_resolver.game_over.connect(_on_game_over)
	DebugLogger.log_system("TurnManager: configurato")

## Avvia il primo turno
func start() -> void:
	DebugLogger.log_turn("TurnManager: avvio partita")
	_begin_turn()

## Avanza di stato. Chiamato dalla UI (button "Fine Turno") o automaticamente.
func advance_state() -> void:
	match current_state:
		State.STATUS_START:
			_transition(State.ENEMY_DRAW)
		State.ENEMY_DRAW:
			_transition(State.ENEMY_PLAY)
		State.ENEMY_PLAY:
			_transition(State.PLAYER_DRAW)
		State.PLAYER_DRAW:
			_transition(State.PLAYER_PLAY)
		State.PLAYER_PLAY:
			_transition(State.RESOLUTION)
		State.RESOLUTION:
			_transition(State.TURN_END)
		State.TURN_END:
			_begin_turn()
		State.GAME_OVER:
			pass  # Stato terminale

## Chiamato da GameScreen quando il giocatore gioca una carta con effetto di stato
func apply_player_card_status(card: CardData) -> void:
	_apply_card_status_effect(card, _player, _enemy)

func _begin_turn() -> void:
	turn_number += 1
	GameManager.turns_played = turn_number
	DebugLogger.separator()
	DebugLogger.log_turn("══ TURNO %d ══ Player:%d/%d [%s] | Enemy:%d/%d [%s]" % [
		turn_number,
		_player.hp, _player.max_hp, _player._status_summary(),
		_enemy.hp, _enemy.max_hp, _enemy._status_summary()
	])
	turn_started.emit(turn_number)
	_transition(State.STATUS_START)

func _transition(new_state: State) -> void:
	current_state = new_state
	var state_name: String = State.keys()[new_state]
	DebugLogger.log_turn("TurnManager: → %s" % state_name)
	state_changed.emit(new_state)
	_execute_state(new_state)

## Esecuzione automatica degli stati non interattivi
func _execute_state(state: State) -> void:
	match state:
		State.STATUS_START:
			_execute_status_start()
		State.ENEMY_DRAW:
			_execute_enemy_draw()
		State.ENEMY_PLAY:
			_execute_enemy_play()
		State.PLAYER_DRAW:
			_execute_player_draw()
		State.PLAYER_PLAY:
			pass  # Attende input utente
		State.RESOLUTION:
			_execute_resolution()
		State.TURN_END:
			_execute_turn_end()
		State.GAME_OVER:
			pass

# ── Effetti di stato all'inizio del turno (POISON) ───────────────────────────

func _execute_status_start() -> void:
	DebugLogger.log_turn("TurnManager: Status start — controllo veleno")
	var continues := _apply_poison_damage()
	if continues:
		advance_state()

## Applica danno da veleno. Nemico prima, poi giocatore (se nemico vivo).
## Ritorna false se la partita è terminata.
func _apply_poison_damage() -> bool:
	var enemy_poisoned := _enemy.has_status("poison")
	var player_poisoned := _player.has_status("poison")

	if not enemy_poisoned and not player_poisoned:
		return true

	DebugLogger.log_resolution("── Veleno: fase danno ──")

	# Nemico prima
	if enemy_poisoned:
		_enemy.status_effects["poison"] -= 1
		status_damage.emit(_enemy.actor_name, "poison", 1)
		if _enemy.has_status("blessed"):
			_enemy.hp = max(1, _enemy.hp - 1)
			DebugLogger.log_damage("%s subisce veleno ma benedizione impedisce la morte (HP: %d)" % [_enemy.actor_name, _enemy.hp])
		else:
			_enemy.take_damage(1)
			DebugLogger.log_damage("%s subisce 1 danno da veleno (HP: %d)" % [_enemy.actor_name, _enemy.hp])
		if _enemy.status_effects["poison"] <= 0:
			status_expired.emit(_enemy.actor_name, "poison")
		if not _enemy.is_alive():
			DebugLogger.log_resolution("☠ %s: veleno fatale — VITTORIA del giocatore!" % _enemy.actor_name)
			_transition(State.GAME_OVER)
			game_over.emit(true)
			return false

	# Giocatore (solo se nemico ancora vivo)
	if player_poisoned:
		_player.status_effects["poison"] -= 1
		status_damage.emit(_player.actor_name, "poison", 1)
		if _player.has_status("blessed"):
			_player.hp = max(1, _player.hp - 1)
			DebugLogger.log_damage("%s subisce veleno ma benedizione impedisce la morte (HP: %d)" % [_player.actor_name, _player.hp])
		else:
			_player.take_damage(1)
			DebugLogger.log_damage("%s subisce 1 danno da veleno (HP: %d)" % [_player.actor_name, _player.hp])
		if _player.status_effects["poison"] <= 0:
			status_expired.emit(_player.actor_name, "poison")
		if not _player.is_alive():
			DebugLogger.log_resolution("☠ %s: veleno fatale — SCONFITTA!" % _player.actor_name)
			_transition(State.GAME_OVER)
			game_over.emit(false)
			return false

	return true

# ── Fase turno nemico ────────────────────────────────────────────────────────

func _execute_enemy_draw() -> void:
	_enemy.reset_intents()
	# Freeze/Haste: modifica energia dopo il reset
	_apply_freeze_haste(_enemy)
	DeckManager.draw_cards(_enemy, Config.cards_per_draw)
	# Se animate_enemy_turn, GameScreen gestisce il timing e chiama advance_state()
	if not Config.animate_enemy_turn:
		advance_state()

func _execute_enemy_play() -> void:
	var played := _enemy_ai.play_turn(_enemy)
	# Applica gli effetti di stato delle carte giocate dal nemico
	for card in played:
		_apply_card_status_effect(card as CardData, _enemy, _player)
	enemy_played_cards.emit(played)
	# Se animate_enemy_turn, GameScreen anima le carte e poi chiama advance_state()
	if not Config.animate_enemy_turn:
		advance_state()

# ── Fase turno giocatore ─────────────────────────────────────────────────────

func _execute_player_draw() -> void:
	_player.reset_intents()
	# Freeze/Haste: modifica energia dopo il reset
	_apply_freeze_haste(_player)
	DeckManager.draw_cards(_player, Config.cards_per_draw)
	advance_state()

func _execute_resolution() -> void:
	var match_continues := _resolver.resolve(_player, _enemy)
	if match_continues:
		advance_state()
	# Se la partita è finita, _on_game_over viene chiamato tramite segnale

# ── Fine turno (BURN + BLESSED + reset) ─────────────────────────────────────

func _execute_turn_end() -> void:
	# ── 1. Danno BURN (nemico prima, poi giocatore) ────────────────────────
	var continues := _apply_burn_damage()
	if not continues:
		return  # GAME_OVER già emesso

	# ── 2. Effetti BLESSED (+1 HP, cura burn/poison, rimozione blessed) ────
	_apply_blessed_effects()

	# ── 3. Reset energia / intenti ────────────────────────────────────────
	_player.reset_energy()
	_enemy.reset_energy()
	DebugLogger.log_turn("TurnManager: reset energia — Player:%d | Enemy:%d" % [
		_player.energy, _enemy.energy
	])
	turn_ended.emit()
	advance_state()

## Applica danno da bruciatura a fine turno. Ritorna false se la partita è terminata.
func _apply_burn_damage() -> bool:
	var enemy_burning := _enemy.has_status("burn")
	var player_burning := _player.has_status("burn")

	if not enemy_burning and not player_burning:
		return true

	DebugLogger.log_resolution("── Bruciatura: fase danno ──")

	# Nemico prima
	if enemy_burning:
		_enemy.status_effects["burn"] -= 1
		status_damage.emit(_enemy.actor_name, "burn", 1)
		if _enemy.has_status("blessed"):
			_enemy.hp = max(1, _enemy.hp - 1)
			DebugLogger.log_damage("%s subisce bruciatura ma benedizione impedisce la morte (HP: %d)" % [_enemy.actor_name, _enemy.hp])
		else:
			_enemy.take_damage(1)
			DebugLogger.log_damage("%s subisce 1 danno da bruciatura (HP: %d)" % [_enemy.actor_name, _enemy.hp])
		if _enemy.status_effects["burn"] <= 0:
			status_expired.emit(_enemy.actor_name, "burn")
		if not _enemy.is_alive():
			DebugLogger.log_resolution("☠ %s: bruciatura fatale — VITTORIA del giocatore!" % _enemy.actor_name)
			_transition(State.GAME_OVER)
			game_over.emit(true)
			return false

	# Giocatore (solo se nemico ancora vivo)
	if player_burning:
		_player.status_effects["burn"] -= 1
		status_damage.emit(_player.actor_name, "burn", 1)
		if _player.has_status("blessed"):
			_player.hp = max(1, _player.hp - 1)
			DebugLogger.log_damage("%s subisce bruciatura ma benedizione impedisce la morte (HP: %d)" % [_player.actor_name, _player.hp])
		else:
			_player.take_damage(1)
			DebugLogger.log_damage("%s subisce 1 danno da bruciatura (HP: %d)" % [_player.actor_name, _player.hp])
		if _player.status_effects["burn"] <= 0:
			status_expired.emit(_player.actor_name, "burn")
		if not _player.is_alive():
			DebugLogger.log_resolution("☠ %s: bruciatura fatale — SCONFITTA!" % _player.actor_name)
			_transition(State.GAME_OVER)
			game_over.emit(false)
			return false

	return true

## Applica gli effetti della benedizione (+1 HP, cura burn/poison, rimuove blessed)
func _apply_blessed_effects() -> void:
	for actor in [_player, _enemy]:
		if actor.has_status("blessed"):
			actor.heal_hp(1)
			DebugLogger.log_heal("%s: benedizione — +1 HP (HP: %d/%d)" % [actor.actor_name, actor.hp, actor.max_hp])
			var burn_was_active: bool = actor.has_status("burn")
			var poison_was_active: bool = actor.has_status("poison")
			actor.clear_status("burn")
			actor.clear_status("poison")
			actor.clear_status("blessed")
			if burn_was_active:   status_expired.emit(actor.actor_name, "burn")
			if poison_was_active: status_expired.emit(actor.actor_name, "poison")
			status_expired.emit(actor.actor_name, "blessed")

# ── Helper status effect ─────────────────────────────────────────────────────

## Applica Freeze (-1 energia) o Haste (+1 energia) all'inizio del round dell'attore
func _apply_freeze_haste(actor: ActorData) -> void:
	if actor.has_status("freeze"):
		var old_energy := actor.energy
		actor.energy = max(0, actor.energy - 1)
		actor.clear_status("freeze")
		status_energy_changed.emit(actor.actor_name, "freeze", actor.energy - old_energy)
		status_expired.emit(actor.actor_name, "freeze")
		DebugLogger.log_turn("%s: FREEZE — energia ridotta da %d a %d" % [actor.actor_name, old_energy, actor.energy])
	if actor.has_status("haste"):
		var old_energy := actor.energy
		actor.energy += 1  # può superare il massimo
		actor.clear_status("haste")
		status_energy_changed.emit(actor.actor_name, "haste", 1)
		status_expired.emit(actor.actor_name, "haste")
		DebugLogger.log_turn("%s: HASTE — energia aumentata da %d a %d" % [actor.actor_name, old_energy, actor.energy])

## Applica l'effetto di stato di una carta giocata al bersaglio corretto
func _apply_card_status_effect(card: CardData, caster: ActorData, opponent: ActorData) -> void:
	if card.status_effect.is_empty():
		return
	var target: ActorData = opponent if card.status_target == "opponent" else caster
	target.apply_status(card.status_effect)
	DebugLogger.log_system("Status '%s' applicato a %s da carta [%s]" % [
		card.status_effect, target.actor_name, card.card_name
	])
	status_applied.emit(target.actor_name, card.status_effect)

func _on_game_over(player_won: bool) -> void:
	_transition(State.GAME_OVER)
	game_over.emit(player_won)
	# GameScreen._on_game_over gestisce l'animazione finale e la transizione di scena
