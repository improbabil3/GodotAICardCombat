## DeckManager — Gestione mazzo, mano e cimitero
##
## Opera su un ActorData. Non ha stato proprio — è un servizio stateless.
## Usato da TurnManager e GameScreen.

class_name DeckManager
extends RefCounted

## Pesca N carte per l'attore. Gestisce il riciclo automatico del cimitero.
## Se le carte nel mazzo non bastano, si riciclano quelle del cimitero.
static func draw_cards(actor: ActorData, count: int) -> void:
	DebugLogger.log_card("%s: pesca %d carta/e — Mazzo: %d | Cimitero: %d" % [
		actor.actor_name, count, actor.deck.size(), actor.graveyard.size()
	])

	var remaining := count
	while remaining > 0:
		# Se il mazzo è vuoto, ricicla il cimitero
		if actor.deck.is_empty():
			if actor.graveyard.is_empty():
				DebugLogger.log_error("DeckManager: %s — mazzo e cimitero vuoti, impossibile pescare" % actor.actor_name)
				break
			_recycle_graveyard(actor)

		# Pesca una carta
		var card: CardData = actor.deck.pop_back()
		actor.hand.append(card)
		DebugLogger.log_card("%s: pescata [%s]" % [actor.actor_name, card.describe()])
		remaining -= 1

	DebugLogger.log_card("%s: fine pescata — Mazzo: %d | Mano: %d | Cimitero: %d" % [
		actor.actor_name, actor.deck.size(), actor.hand.size(), actor.graveyard.size()
	])

## Scarta una carta dalla mano al cimitero
static func discard_card(actor: ActorData, card: CardData) -> void:
	var idx := actor.hand.find(card)
	if idx == -1:
		DebugLogger.log_error("DeckManager: carta '%s' non trovata nella mano di %s" % [card.card_name, actor.actor_name])
		return
	actor.hand.remove_at(idx)
	actor.graveyard.append(card)
	DebugLogger.log_card("%s: scartata [%s] → cimitero (%d carte)" % [
		actor.actor_name, card.card_name, actor.graveyard.size()
	])

## Scarta tutta la mano nel cimitero
static func discard_hand(actor: ActorData) -> void:
	var count := actor.hand.size()
	for card in actor.hand:
		actor.graveyard.append(card)
	actor.hand.clear()
	DebugLogger.log_card("%s: intera mano scartata (%d carte) → cimitero (%d totali)" % [
		actor.actor_name, count, actor.graveyard.size()
	])

## Ricicla il cimitero come nuovo mazzo (mischiato), svuotando il cimitero
static func _recycle_graveyard(actor: ActorData) -> void:
	DebugLogger.log_system("%s: riciclo cimitero → %d carte mischiiate → nuovo mazzo" % [
		actor.actor_name, actor.graveyard.size()
	])
	actor.deck = actor.graveyard.duplicate()
	actor.graveyard.clear()
	_shuffle(actor.deck)

## Fisher-Yates shuffle su un Array[CardData]
static func _shuffle(cards: Array[CardData]) -> void:
	var n := cards.size()
	for i in range(n - 1, 0, -1):
		var j := randi() % (i + 1)
		var tmp: CardData = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp

## Utility: mischia un array di CardData in-place (esposto per uso esterno)
static func shuffle_deck(cards: Array[CardData]) -> void:
	_shuffle(cards)
