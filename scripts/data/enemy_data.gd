## EnemyData — Definisce un nemico da affrontare nella run
##
## Contiene tutte le informazioni per istanziare l'ActorData del nemico
## e calcolare il punteggio dello scontro.

class_name EnemyData
extends RefCounted

## Tipo di nemico: influenza il punteggio base e la posizione nella run
enum Type { BASE, ELITE, BOSS }

# ── Variabili pubbliche ───────────────────────────────────────────────────────

## Nome visualizzato del nemico
var enemy_name: String

## Percorso del file JSON del mazzo (res://)
var deck_path: String

## HP massimi del nemico
var max_hp: int

## Energia massima del nemico per turno
var max_energy: int

## Tipo di nemico
var enemy_type: Type

## Punteggio base per questo scontro (moltiplicato per HP e turni)
var base_score: int

# ── Costruttore ───────────────────────────────────────────────────────────────

func _init(
	p_name: String,
	p_deck_path: String,
	p_max_hp: int,
	p_max_energy: int,
	p_type: Type,
	p_base_score: int
) -> void:
	enemy_name = p_name
	deck_path = p_deck_path
	max_hp = p_max_hp
	max_energy = p_max_energy
	enemy_type = p_type
	base_score = p_base_score

## Ritorna una stringa descrittiva del tipo nemico
func type_label() -> String:
	match enemy_type:
		Type.BASE:  return "Nemico"
		Type.ELITE: return "Elite"
		Type.BOSS:  return "BOSS"
	return "?"
