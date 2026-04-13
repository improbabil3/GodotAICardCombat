## EnemyAI — Strategia greedy per il nemico
##
## Strategia:
##   - Se HP <= 30% max_HP: priorità guarigione > scudo > danno
##   - Altrimenti: danno > danno+scudo > scudo > guarigione
## Il nemico gioca tutte le carte che può permettersi finché non esaurisce l'energia.
## Le carte non giocate vengono scartate.

class_name EnemyAI
extends RefCounted

const SURVIVAL_HP_RATIO := 0.30

## Esegue il turno dell'AI. Aggiorna actor.current_intents e scarta le carte.
## Ritorna le carte giocate (per le animazioni UI).
func play_turn(actor: ActorData) -> Array[CardData]:
	DebugLogger.log_ai("=== Turno AI: %s — HP:%d/%d | ENE:%d | Mano:%d ====" % [
		actor.actor_name, actor.hp, actor.max_hp, actor.energy, actor.hand.size()
	])

	var survival_mode := float(actor.hp) / float(actor.max_hp) <= SURVIVAL_HP_RATIO
	if survival_mode:
		DebugLogger.log_ai("AI: modalità SOPRAVVIVENZA (HP ≤ 30%%) — priorità guarigione > scudo > danno")
	else:
		DebugLogger.log_ai("AI: modalità AGGRESSIVA — priorità danno > danno+scudo > scudo > guarigione")

	var sorted_hand := _sort_hand(actor.hand, survival_mode)
	var played: Array[CardData] = []

	for card in sorted_hand:
		if actor.energy < card.energy_cost:
			DebugLogger.log_ai("AI: [%s] troppo costosa (ENE:%d richiesta, disponibile:%d) — saltata" % [
				card.card_name, card.energy_cost, actor.energy
			])
			continue

		# Gioca la carta
		actor.spend_energy(card.energy_cost)
		actor.add_card_intents(card)
		DeckManager.discard_card(actor, card)
		played.append(card)

		DebugLogger.log_ai("AI: gioca [%s] — ENE rimasta:%d | Intenti ora: DAN:%d SCU:%d GUA:%d" % [
			card.describe(), actor.energy,
			actor.current_intents["damage"],
			actor.current_intents["shield"],
			actor.current_intents["heal"]
		])

		# Interrompi se energia esaurita
		if actor.energy == 0:
			DebugLogger.log_ai("AI: energia esaurita, fine giocate")
			break

	# Scarta le carte rimaste in mano
	if actor.hand.size() > 0:
		DebugLogger.log_ai("AI: scarta %d carta/e rimaste in mano" % actor.hand.size())
		DeckManager.discard_hand(actor)

	DebugLogger.log_ai("AI: turno completato — %d carta/e giocate | Intenti finali: DAN:%d SCU:%d GUA:%d" % [
		played.size(),
		actor.current_intents["damage"],
		actor.current_intents["shield"],
		actor.current_intents["heal"]
	])

	return played

## Ordina la mano in base alla strategia corrente.
func _sort_hand(hand: Array[CardData], survival_mode: bool) -> Array[CardData]:
	var sorted := hand.duplicate()
	sorted.sort_custom(func(a: CardData, b: CardData) -> bool:
		return _priority(a, survival_mode) > _priority(b, survival_mode)
	)
	return sorted

## Calcola il punteggio di priorità di una carta
func _priority(card: CardData, survival_mode: bool) -> float:
	var damage_val := float(card.damage)
	var shield_val := float(card.shield)
	var heal_val   := float(card.heal)
	var cost_penalty := float(card.energy_cost) * 0.1  # Leggero malus per alto costo
	# Bonus per carte con effetto di stato: priorità leggermente elevata
	var status_bonus := 1.5 if card.status_effect != "" else 0.0

	if survival_mode:
		# Guarigione → scudo → danno
		return (heal_val * 3.0) + (shield_val * 2.0) + damage_val + status_bonus - cost_penalty
	else:
		# Danno → danno+scudo → scudo → guarigione
		return (damage_val * 3.0) + (shield_val * 1.5) + (heal_val * 0.5) + status_bonus - cost_penalty
