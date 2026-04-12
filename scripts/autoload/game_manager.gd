## GameManager — Singleton globale
##
## Responsabilità:
## - Tenere i riferimenti attivi di ActorData per player e nemico
## - Gestire le transizioni di scena
## - Gestire lo stato della run sequenziale (4 scontri)
## - Comunicare il risultato della run alle schermate di esito

extends Node

## Riferimenti agli attori attivi (valorizzati da GameScreen all'inizio del combattimento)
var player: ActorData = null
var enemy: ActorData = null

## Personaggio selezionato dal giocatore
var selected_character: CharacterData = null

## Mazzo finale del player (dopo selezione carte)
var player_deck: Array[CardData] = []

## Statistiche turni combattimento corrente
var turns_played: int = 0

# ── Stato della Run ──────────────────────────────────────────────────────────

## Indice dell'incontro corrente nella sequenza (0-3)
var encounter_index: int = 0

## Punteggi accumulati per ogni incontro vinto (float per precisione)
var run_scores: Array[float] = []

## Indice dell'incontro in cui il giocatore è stato sconfitto (-1 = non ancora)
var run_defeated_at: int = -1

## Roster dei 4 nemici per questa run (scelti all'avvio)
var enemy_roster: Array[EnemyData] = []

## Scene registrate
const SCENE_TITLE       := "res://scenes/screens/title_screen.tscn"
const SCENE_CHARACTER   := "res://scenes/screens/character_selection_screen.tscn"
const SCENE_CARD        := "res://scenes/screens/card_selection_screen.tscn"
const SCENE_GAME        := "res://scenes/screens/game_screen.tscn"
const SCENE_VICTORY     := "res://scenes/screens/victory_screen.tscn"
const SCENE_DEFEAT      := "res://scenes/screens/defeat_screen.tscn"

func _ready() -> void:
	DebugLogger.log_system("GameManager: avviato")
	# Applica tema sci-fi all'intera app (si propaga a tutti i nodi Control)
	get_tree().root.theme = ThemeBuilder.build()
	# Inizializza il CharacterManager
	CharacterManager.init()

## Mostra la schermata di selezione personaggio
func start_character_selection() -> void:
	DebugLogger.log_system("GameManager: inizio selezione personaggio")
	_change_scene(SCENE_CHARACTER)

## Mostra la schermata di selezione carte
func start_card_selection() -> void:
	DebugLogger.log_system("GameManager: inizio selezione carte")
	_change_scene(SCENE_CARD)

## Avvia una nuova run sequenziale (chiamata dopo la selezione del mazzo)
func start_run() -> void:
	encounter_index = 0
	run_scores.clear()
	run_defeated_at = -1
	turns_played = 0
	_build_enemy_roster()
	DebugLogger.log_turn("GameManager: avvio run — %d incontri preparati" % enemy_roster.size())
	_change_scene(SCENE_GAME)

## Avvia l'incontro corrente nella run (usato internamente dopo ogni vittoria)
func start_game() -> void:
	turns_played = 0
	DebugLogger.log_turn("GameManager: avvio incontro %d/%d — %s" % [
		encounter_index + 1, enemy_roster.size(),
		_current_enemy_name()
	])
	_change_scene(SCENE_GAME)

## Chiamato da GameScreen quando il giocatore vince uno scontro
func complete_encounter(turns: int, player_hp_remaining: int) -> void:
	var enemy_data := get_current_enemy()
	var score := _calculate_score(enemy_data.base_score, player_hp_remaining, turns)
	run_scores.append(score)
	DebugLogger.log_turn("GameManager: scontro %d vinto — score=%.1f (base=%d hp=%d turns=%d)" % [
		encounter_index + 1, score, enemy_data.base_score, player_hp_remaining, turns
	])
	encounter_index += 1
	if encounter_index >= enemy_roster.size():
		# Run completata: vittoria!
		DebugLogger.separator()
		DebugLogger.log_turn("GameManager: RUN COMPLETATA — punteggio totale=%.0f" % total_score())
		_change_scene(SCENE_VICTORY)
	else:
		# Prossimo incontro
		start_game()

## Chiamato da GameScreen quando il giocatore viene sconfitto
func fail_encounter() -> void:
	run_defeated_at = encounter_index
	DebugLogger.log_turn("GameManager: sconfitta all'incontro %d (%s)" % [
		encounter_index + 1, _current_enemy_name()
	])
	_change_scene(SCENE_DEFEAT)

## Torna al menu principale e resetta tutto lo stato della run
func return_to_menu() -> void:
	player = null
	enemy = null
	selected_character = null
	player_deck.clear()
	turns_played = 0
	encounter_index = 0
	run_scores.clear()
	run_defeated_at = -1
	enemy_roster.clear()
	DebugLogger.log_system("GameManager: ritorno al menu principale")
	_change_scene(SCENE_TITLE)

## Ritorna l'EnemyData del nemico corrente
func get_current_enemy() -> EnemyData:
	if encounter_index < enemy_roster.size():
		return enemy_roster[encounter_index]
	return null

## Ritorna il punteggio totale della run
func total_score() -> float:
	var total: float = 0.0
	for s in run_scores:
		total += s
	return total

## Calcola il rating della run
func run_rating() -> String:
	# D/E/F: sconfitta, basato su dove è avvenuta
	if run_defeated_at >= 0:
		# Posizione 3 = boss (indice 3)
		if run_defeated_at == 3:
			return "D"
		# Posizione 2 = elite (indice 2)
		elif run_defeated_at == 2:
			return "E"
		else:
			# Posizioni 0 o 1 = nemico base
			return "F"
	# C/B/A/S: run completata, basato su punteggio
	var score := total_score()
	if score >= Config.rating_s_threshold:
		return "S"
	elif score >= Config.rating_a_threshold:
		return "A"
	elif score >= Config.rating_b_threshold:
		return "B"
	else:
		return "C"

## Descrizione testuale del rating
func rating_description(rating: String) -> String:
	match rating:
		"S": return "Run Perfetta"
		"A": return "Run Quasi Perfetta"
		"B": return "Run Buona"
		"C": return "Run Sufficiente"
		"D": return "Run Mediocre"
		"E": return "Run Scadente"
		"F": return "Run Scellerata"
	return ""

## Riporta HP del player come stringa per le schermate di esito
func player_hp_summary() -> String:
	if player == null:
		return "N/A"
	return "%d/%d" % [player.hp, player.max_hp]

# ── Costruzione roster ───────────────────────────────────────────────────────

func _build_enemy_roster() -> void:
	# Pool base: 5 nemici — ne scegliamo 2 a caso
	var base_pool: Array[EnemyData] = [
		EnemyData.new("Nexus Warlord", "res://data/deck_enemy.json",
			20, 3, EnemyData.Type.BASE, Config.score_base_enemy),
		EnemyData.new("Scrap Raider", "res://data/deck_enemy_scrap_raider.json",
			20, 3, EnemyData.Type.BASE, Config.score_base_enemy),
		EnemyData.new("Void Drone", "res://data/deck_enemy_void_drone.json",
			20, 3, EnemyData.Type.BASE, Config.score_base_enemy),
		EnemyData.new("Plasma Grunt", "res://data/deck_enemy_plasma_grunt.json",
			20, 3, EnemyData.Type.BASE, Config.score_base_enemy),
		EnemyData.new("Phase Stalker", "res://data/deck_enemy_phase_stalker.json",
			20, 3, EnemyData.Type.BASE, Config.score_base_enemy),
	]
	# Pool elite: 2 nemici — ne scegliamo 1
	var elite_pool: Array[EnemyData] = [
		EnemyData.new("Iron Enforcer", "res://data/deck_enemy_elite_iron_enforcer.json",
			25, 3, EnemyData.Type.ELITE, Config.score_elite_enemy),
		EnemyData.new("Void Overlord", "res://data/deck_enemy_elite_void_overlord.json",
			25, 3, EnemyData.Type.ELITE, Config.score_elite_enemy),
	]
	# Boss fisso
	var boss := EnemyData.new("Galactic Tyrant", "res://data/deck_enemy_boss_galactic_tyrant.json",
		30, 3, EnemyData.Type.BOSS, Config.score_boss_enemy)

	# Seleziona 2 base casuali (senza ripetizioni)
	var base_copy := base_pool.duplicate()
	base_copy.shuffle()
	var base1: EnemyData = base_copy[0]
	var base2: EnemyData = base_copy[1]

	# Seleziona 1 elite casuale
	var elite_copy := elite_pool.duplicate()
	elite_copy.shuffle()
	var elite: EnemyData = elite_copy[0]

	enemy_roster = [base1, base2, elite, boss]
	DebugLogger.log_system("GameManager: roster → %s | %s | %s | %s" % [
		base1.enemy_name, base2.enemy_name, elite.enemy_name, boss.enemy_name
	])

func _calculate_score(base_score: int, hp_remaining: int, turns: int) -> float:
	if turns <= 0:
		turns = 1
	return base_score * (float(hp_remaining) / 20.0) * (10.0 / float(turns))

func _current_enemy_name() -> String:
	var ed := get_current_enemy()
	return ed.enemy_name if ed != null else "?"

## Cambia scena con un piccolo log
func _change_scene(path: String) -> void:
	DebugLogger.log_system("GameManager: cambio scena → %s" % path)
	get_tree().change_scene_to_file(path)

