## GameManager — Singleton globale
##
## Responsabilità:
## - Tenere i riferimenti attivi di ActorData per player e nemico
## - Gestire le transizioni di scena
## - Comunicare il risultato del combattimento alle schermate di esito

extends Node

## Riferimenti agli attori attivi (valorizzati da GameScreen all'inizio del combattimento)
var player: ActorData = null
var enemy: ActorData = null

## Personaggio selezionato dal giocatore
var selected_character: CharacterData = null

## Mazzo finale del player (dopo selezione carte)
var player_deck: Array[CardData] = []

## Statistiche partita corrente
var turns_played: int = 0
var _combat_won: bool = false

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

## Avvia una nuova partita (dopo che il personaggio e mazzo sono stati scelti)
func start_game() -> void:
	turns_played = 0
	DebugLogger.log_turn("GameManager: avvio nuova partita")
	_change_scene(SCENE_GAME)

## Chiamato da TurnManager/CombatResolver quando la partita finisce
func end_game(player_won: bool) -> void:
	_combat_won = player_won
	var outcome := "VITTORIA" if player_won else "SCONFITTA"
	DebugLogger.separator()
	DebugLogger.log_turn("GameManager: partita terminata — %s dopo %d turni" % [outcome, turns_played])
	if player_won:
		_change_scene(SCENE_VICTORY)
	else:
		_change_scene(SCENE_DEFEAT)

## Torna al menu principale
func return_to_menu() -> void:
	player = null
	enemy = null
	selected_character = null
	player_deck.clear()
	turns_played = 0
	DebugLogger.log_system("GameManager: ritorno al menu principale")
	_change_scene(SCENE_TITLE)

## Ritorna true se il giocatore ha vinto l'ultima partita
func player_won() -> bool:
	return _combat_won

## Riporta HP del player come stringa per le schermate di esito
func player_hp_summary() -> String:
	if player == null:
		return "N/A"
	return "%d/%d" % [player.hp, player.max_hp]

## Cambia scena con un piccolo log
func _change_scene(path: String) -> void:
	DebugLogger.log_system("GameManager: cambio scena → %s" % path)
	get_tree().change_scene_to_file(path)
