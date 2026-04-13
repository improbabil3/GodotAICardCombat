## ActorData — Stato di un attore (Giocatore o Nemico)
##
## Non è un nodo — è dati puri. Un'istanza per giocatore, una per il nemico.
## Viene creata e tenuta viva da GameManager.

class_name ActorData
extends RefCounted

## Identificatore testuale ("Player" o "Enemy")
var actor_name: String = ""

## HP correnti
var hp: int = 20

## HP massimi
var max_hp: int = 20

## Energia corrente (punti da spendere per giocare carte)
var energy: int = 5

## Energia massima (valore di reset a fine turno)
var max_energy: int = 5

## Mazzo — carte non ancora pescate
var deck: Array[CardData] = []

## Mano — carte attualmente in mano
var hand: Array[CardData] = []

## Cimitero — carte già giocate o scartate
var graveyard: Array[CardData] = []

## Intenti del turno corrente (accumulati mentre gioca le carte)
var current_intents: Dictionary = {"damage": 0, "shield": 0, "heal": 0}

## Effetti di stato attivi. Valore = turni rimanenti (0 = inattivo).
## Burn: 3 turni | Poison: 2 turni | Freeze: 1 turno | Haste: 1 turno | Blessed: 1 turno
var status_effects: Dictionary = {
	"burn": 0,
	"poison": 0,
	"freeze": 0,
	"haste": 0,
	"blessed": 0
}

func _init(p_name: String, p_hp: int, p_energy: int) -> void:
	actor_name = p_name
	hp = p_hp
	max_hp = p_hp
	energy = p_energy
	max_energy = p_energy

## Applica danno (non va sotto 0)
func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)

## Applica guarigione (non supera max_hp)
func heal_hp(amount: int) -> void:
	hp = min(max_hp, hp + amount)

## Spende energia (non va sotto 0 — il controllo di validità è esterno)
func spend_energy(amount: int) -> void:
	energy = max(0, energy - amount)

## Resetta energia a fine turno
func reset_energy() -> void:
	if Config.accumulate_energy:
		energy = min(max_energy, energy + max_energy)
	else:
		energy = max_energy

## Resetta gli intenti del turno corrente
func reset_intents() -> void:
	current_intents = {"damage": 0, "shield": 0, "heal": 0}

## Aggiunge gli effetti di una carta agli intenti
func add_card_intents(card: CardData) -> void:
	current_intents["damage"] += card.damage
	current_intents["shield"] += card.shield
	current_intents["heal"] += card.heal

## Ritorna true se l'attore è vivo
func is_alive() -> bool:
	return hp > 0

## Ritorna true se può giocare la carta (energia sufficiente)
func can_play(card: CardData) -> bool:
	return energy >= card.energy_cost

## Stato sintetico per debug
func debug_state() -> String:
	return "%s — HP: %d/%d | ENE: %d/%d | Mazzo: %d | Mano: %d | Cimitero: %d | Intenti: DAN%d SCU%d GUA%d | Status: %s" % [
		actor_name, hp, max_hp, energy, max_energy,
		deck.size(), hand.size(), graveyard.size(),
		current_intents["damage"], current_intents["shield"], current_intents["heal"],
		_status_summary()
	]

# ── Effetti di stato ─────────────────────────────────────────────────────────

## Applica un effetto di stato. Se già attivo, resetta il contatore.
func apply_status(effect: String) -> void:
	match effect:
		"burn":    status_effects["burn"]    = 3
		"poison":  status_effects["poison"]  = 2
		"freeze":  status_effects["freeze"]  = 1
		"haste":   status_effects["haste"]   = 1
		"blessed": status_effects["blessed"] = 1
		_:
			DebugLogger.log_error("ActorData: effetto stato sconosciuto '%s'" % effect)

## Ritorna true se l'effetto di stato è attivo (turni > 0)
func has_status(effect: String) -> bool:
	return status_effects.get(effect, 0) > 0

## Rimuove (azzera) un effetto di stato
func clear_status(effect: String) -> void:
	if status_effects.has(effect):
		status_effects[effect] = 0

## Stringa riassuntiva degli effetti attivi (per debug)
func _status_summary() -> String:
	var parts: Array[String] = []
	if status_effects["burn"]    > 0: parts.append("BURN[%d]" % status_effects["burn"])
	if status_effects["poison"]  > 0: parts.append("POISON[%d]" % status_effects["poison"])
	if status_effects["freeze"]  > 0: parts.append("FREEZE")
	if status_effects["haste"]   > 0: parts.append("HASTE")
	if status_effects["blessed"] > 0: parts.append("BLESSED")
	return " ".join(parts) if parts.size() > 0 else "nessuno"
