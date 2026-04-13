## DeckLoader — Carica e valida un mazzo da file JSON
##
## Formato JSON atteso: { "deck_name": "...", "cards": [ { ... }, ... ] }
## Ogni carta: { "name": str, "damage": int, "shield": int, "heal": int, "energy": int, "image": str }
##
## Uso:
##   var cards := DeckLoader.load_deck("res://data/deck_player.json")

class_name DeckLoader
extends RefCounted

## Carica il mazzo da file JSON. Ritorna array vuoto se fallisce.
static func load_deck(path: String) -> Array[CardData]:
	if not FileAccess.file_exists(path):
		DebugLogger.log_error("DeckLoader: file non trovato — %s" % path)
		return []

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		DebugLogger.log_error("DeckLoader: impossibile aprire — %s (errore: %d)" % [path, FileAccess.get_open_error()])
		return []

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		DebugLogger.log_error("DeckLoader: JSON non valido in %s — riga %d: %s" % [
			path, json.get_error_line(), json.get_error_message()
		])
		return []

	var data: Dictionary = json.get_data()
	if not data.has("cards") or not data["cards"] is Array:
		DebugLogger.log_error("DeckLoader: struttura JSON non valida in %s — campo 'cards' mancante" % path)
		return []

	var deck_name: String = data.get("deck_name", "Unnamed Deck")
	var raw_cards: Array = data["cards"]
	var result: Array[CardData] = []

	for i in raw_cards.size():
		var raw: Dictionary = raw_cards[i]
		var card := _parse_card(raw, i, path)
		if card != null:
			result.append(card)

	# Validazione dimensione mazzo
	if result.size() != 20:
		DebugLogger.log_error("DeckLoader: il mazzo '%s' ha %d carte anziché 20 — %s" % [
			deck_name, result.size(), path
		])
		# Non bloccante: continuiamo comunque con le carte caricate

	DebugLogger.log_system("DeckLoader: mazzo '%s' caricato — %d carte da %s" % [
		deck_name, result.size(), path
	])
	return result

## Parsa una singola carta dal dizionario JSON. Ritorna null se invalida.
static func _parse_card(raw: Dictionary, index: int, source_path: String) -> CardData:
	var card_name: String = raw.get("name", "")
	if card_name.is_empty():
		DebugLogger.log_error("DeckLoader: carta %d in %s non ha nome — saltata" % [index, source_path])
		return null

	var damage: int = int(raw.get("damage", 0))
	var shield: int = int(raw.get("shield", 0))
	var heal: int = int(raw.get("heal", 0))
	var energy: int = int(raw.get("energy", 0))
	var image: String = raw.get("image", "default")
	var status_effect: String = raw.get("status_effect", "")
	var status_target: String = raw.get("status_target", "")

	# Validazione valori
	var errors: Array[String] = []
	if damage < 0 or damage > 5:
		errors.append("damage=%d fuori range [0,5]" % damage)
	if shield < 0 or shield > 3:
		errors.append("shield=%d fuori range [0,3]" % shield)
	if heal < 0 or heal > 2:
		errors.append("heal=%d fuori range [0,2]" % heal)
	if energy < 0 or energy > 2:
		errors.append("energy=%d fuori range [0,2]" % energy)

	var effect_count := (1 if damage > 0 else 0) + (1 if shield > 0 else 0) + (1 if heal > 0 else 0)
	if effect_count == 0:
		errors.append("nessun effetto attivo (damage+shield+heal = 0)")
	if effect_count > 2:
		errors.append("troppi effetti (%d > 2)" % effect_count)

	# Validazione status_effect
	const _VALID_STATUS := ["", "burn", "poison", "freeze", "haste", "blessed"]
	const _VALID_TARGET := ["", "self", "opponent"]
	if not status_effect in _VALID_STATUS:
		errors.append("status_effect='%s' non valido" % status_effect)
	if status_effect != "" and not status_target in _VALID_TARGET:
		errors.append("status_target='%s' non valido" % status_target)
	if status_effect != "" and status_target == "":
		errors.append("status_effect='%s' senza status_target" % status_effect)

	if errors.size() > 0:
		DebugLogger.log_error("DeckLoader: carta '%s' (indice %d) invalida: %s — saltata" % [
			card_name, index, ", ".join(errors)
		])
		return null

	return CardData.create(card_name, damage, shield, heal, energy, image, status_effect, status_target)
