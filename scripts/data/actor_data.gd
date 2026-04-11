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
	return "%s — HP: %d/%d | ENE: %d/%d | Mazzo: %d | Mano: %d | Cimitero: %d | Intenti: DAN%d SCU%d GUA%d" % [
		actor_name, hp, max_hp, energy, max_energy,
		deck.size(), hand.size(), graveyard.size(),
		current_intents["damage"], current_intents["shield"], current_intents["heal"]
	]
