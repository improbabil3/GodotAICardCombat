## TurnManager — Macchina a stati finiti per la gestione dei turni
##
## Stati:
##   ENEMY_DRAW   → il nemico pesca le carte
##   ENEMY_PLAY   → l'AI del nemico gioca
##   PLAYER_DRAW  → il giocatore pesca le sue carte
##   PLAYER_PLAY  → il giocatore interagisce (attende "Fine Turno")
##   RESOLUTION   → risoluzione effetti (guarigione, attacco, contro-attacco)
##   TURN_END     → reset energia, reset intenti, incremento contatore turni
##   GAME_OVER    → stato terminale, non si avanza oltre
##
## Il segnale state_changed è l'unico punto di aggiornamento UI.

class_name TurnManager
extends RefCounted

enum State {
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

var current_state: State = State.ENEMY_DRAW
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

## Avanza di stato. Chiamato dalla UI (button "Fine Turno") o automaticamente dopo ENEMY_PLAY.
func advance_state() -> void:
	match current_state:
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

func _begin_turn() -> void:
	turn_number += 1
	GameManager.turns_played = turn_number
	DebugLogger.separator()
	DebugLogger.log_turn("══ TURNO %d ══ Player:%d/%d | Enemy:%d/%d" % [
		turn_number,
		_player.hp, _player.max_hp,
		_enemy.hp, _enemy.max_hp
	])
	turn_started.emit(turn_number)
	_transition(State.ENEMY_DRAW)

func _transition(new_state: State) -> void:
	current_state = new_state
	var state_name: String = State.keys()[new_state]
	DebugLogger.log_turn("TurnManager: → %s" % state_name)
	state_changed.emit(new_state)
	_execute_state(new_state)

## Esecuzione automatica degli stati non interattivi
func _execute_state(state: State) -> void:
	match state:
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

func _execute_enemy_draw() -> void:
	_enemy.reset_intents()
	DeckManager.draw_cards(_enemy, Config.cards_per_draw)
	# Se animate_enemy_turn, GameScreen gestisce il timing e chiama advance_state()
	if not Config.animate_enemy_turn:
		advance_state()

func _execute_enemy_play() -> void:
	var played := _enemy_ai.play_turn(_enemy)
	enemy_played_cards.emit(played)
	# Se animate_enemy_turn, GameScreen anima le carte e poi chiama advance_state()
	if not Config.animate_enemy_turn:
		advance_state()

func _execute_player_draw() -> void:
	_player.reset_intents()
	DeckManager.draw_cards(_player, Config.cards_per_draw)
	advance_state()

func _execute_resolution() -> void:
	var match_continues := _resolver.resolve(_player, _enemy)
	if match_continues:
		advance_state()
	# Se la partita è finita, _on_game_over viene chiamato tramite segnale

func _execute_turn_end() -> void:
	_player.reset_energy()
	_enemy.reset_energy()
	DebugLogger.log_turn("TurnManager: reset energia — Player:%d | Enemy:%d" % [
		_player.energy, _enemy.energy
	])
	turn_ended.emit()
	advance_state()

func _on_game_over(player_won: bool) -> void:
	_transition(State.GAME_OVER)
	game_over.emit(player_won)
	# GameScreen._on_game_over gestisce l'animazione finale e la transizione di scena
