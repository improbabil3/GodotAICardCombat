## CardData — Dati di una singola carta
##
## Uso: crea un CardData via CardData.new() oppure tramite DeckLoader.load_deck()
## I valori 0 indicano "effetto assente" per damage, shield, heal.

class_name CardData
extends Resource

## Nome della carta (es. "Laser Blast")
@export var card_name: String = ""

## Danno inflitto (0 = assente, 1-5)
@export_range(0, 5) var damage: int = 0

## Scudo fornito (0 = assente, 1-3)
@export_range(0, 3) var shield: int = 0

## Guarigione fornita (0 = assente, 1-2)
@export_range(0, 2) var heal: int = 0

## Costo in energia per giocare la carta (0-2)
@export_range(0, 2) var energy_cost: int = 0

## Chiave immagine (usata per caricare l'asset in assets/images/cards/)
@export var image_key: String = "default"

## Costruttore di convenienza usato da DeckLoader
static func create(p_name: String, p_damage: int, p_shield: int, p_heal: int, p_energy: int, p_image: String) -> CardData:
	var c := CardData.new()
	c.card_name = p_name
	c.damage = p_damage
	c.shield = p_shield
	c.heal = p_heal
	c.energy_cost = p_energy
	c.image_key = p_image
	return c

## Ritorna true se la carta ha almeno un effetto attivo
func is_valid() -> bool:
	return (damage + shield + heal) > 0

## Numero di effetti attivi (max 2)
func effect_count() -> int:
	var n := 0
	if damage > 0: n += 1
	if shield > 0: n += 1
	if heal > 0: n += 1
	return n

## Ritorna una stringa descrittiva degli effetti
func describe() -> String:
	var parts: Array[String] = []
	if damage > 0: parts.append("DAN +%d" % damage)
	if shield > 0: parts.append("SCU +%d" % shield)
	if heal > 0: parts.append("GUA +%d" % heal)
	return "%s [ENE:%d] — %s" % [card_name, energy_cost, " | ".join(parts)]
