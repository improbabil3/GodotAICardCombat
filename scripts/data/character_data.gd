## CharacterData — Definisce un personaggio giocabile
##
## Ogni personaggio ha:
## - Nome e descrizione
## - Mazzi specifici di 10 carte (scelte dal giocatore)
## - Associazione al file dei dati

class_name CharacterData
extends RefCounted

## Nome del personaggio
var name: String

## Descrizione breve
var description: String

## ID univoco (per caricamento risorse)
var character_id: String

## Array di 10 carte specifiche del personaggio (da cui il giocatore sceglie)
var specific_cards: Array[CardData] = []

func _init(p_name: String, p_id: String, p_description: String) -> void:
	name = p_name
	character_id = p_id
	description = p_description

## Carica le carte specifiche da un file JSON interno
func load_specific_cards(path: String) -> bool:
	specific_cards = DeckLoader.load_deck(path)
	DebugLogger.log_system("CharacterData: %s caricato — %d carte da %s" % [name, specific_cards.size(), path])
	if specific_cards.size() < 10 or specific_cards.size() > 20:
		DebugLogger.log_error("CharacterData: il personaggio '%s' dovrebbe avere 10-20 carte specifiche, ne ha %d" % [name, specific_cards.size()])
		return false
	return true
