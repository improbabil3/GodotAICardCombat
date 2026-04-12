## CharacterManager — Gestore dei personaggi disponibili
##
## Fornisce accesso ai 5 personaggi e ai loro dati

class_name CharacterManager
extends RefCounted

## Array di tutti i personaggi disponibili
static var characters: Array[CharacterData] = []

## Indice del personaggio selezionato
static var selected_character_index: int = 0

## Inizializza i personaggi (chiamato una sola volta)
static func init() -> void:
	if characters.size() > 0:
		return  # Già inizializzato

	# Crea i 3 personaggi
	var omega_pilot := CharacterData.new(
		"Omega Pilot",
		"omega_pilot",
		"Pilota equilibrato con attacchi moderati e difesa bilanciat"
	)
	
	var phoenix_guardian := CharacterData.new(
		"Phoenix Guardian",
		"phoenix_guardian",
		"Custode difensivo con focus su protezione e guarigione"
	)
	
	var apex_striker := CharacterData.new(
		"Apex Striker",
		"apex_striker",
		"Attaccante aggressivo con colpi devastanti"
	)

	var void_walker := CharacterData.new(
		"Void Walker",
		"void_walker",
		"Infiltrato del vuoto: drena la vita nemica per sopravvivere"
	)

	var cyber_mystic := CharacterData.new(
		"Cyber Mystic",
		"cyber_mystic",
		"Mago tecnologico con un arsenale misto di attacchi, scudi e cura"
	)

	# Carica le carte specifiche
	omega_pilot.load_specific_cards("res://data/deck_omega_pilot_specific.json")
	phoenix_guardian.load_specific_cards("res://data/deck_phoenix_guardian_specific.json")
	apex_striker.load_specific_cards("res://data/deck_apex_striker_specific.json")
	void_walker.load_specific_cards("res://data/deck_void_walker_specific.json")
	cyber_mystic.load_specific_cards("res://data/deck_cyber_mystic_specific.json")

	characters = [omega_pilot, phoenix_guardian, apex_striker, void_walker, cyber_mystic]
	selected_character_index = 0
	DebugLogger.log_system("CharacterManager: 5 personaggi inizializzati")

## Ritorna il elenco dei nomi dei personaggi
static func get_character_names() -> Array[String]:
	var names: Array[String] = []
	for char in characters:
		names.append(char.name)
	return names

## Ritorna il personaggio selezionato
static func get_selected_character() -> CharacterData:
	if selected_character_index < 0 or selected_character_index >= characters.size():
		selected_character_index = 0
	return characters[selected_character_index]

## Ritorna un personaggio per indice
static func get_character(index: int) -> CharacterData:
	if index < 0 or index >= characters.size():
		return characters[0]
	return characters[index]

## Imposta il personaggio selezionato
static func set_selected_character(index: int) -> void:
	if index >= 0 and index < characters.size():
		selected_character_index = index
		DebugLogger.log_system("CharacterManager: selezionato %s" % characters[index].name)
