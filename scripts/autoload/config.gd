## Configurazione — Galactic Clash Alpha
##
## Tutti i valori modificabili senza toccare la logica di gioco.
## Puoi cambiarli nell'Inspector di Godot (nodo autoload Config) oppure qui.

extends Node

# ── Attori ───────────────────────────────────────────────────────────────────

## HP massimi del giocatore
@export var player_max_hp: int = 20

## HP massimi del nemico
@export var enemy_max_hp: int = 20

## Energia massima giocabile per turno (giocatore)
@export var player_max_energy: int = 3

## Energia massima giocabile per turno (nemico)
@export var enemy_max_energy: int = 3

# ── Mazzo / Turno ────────────────────────────────────────────────────────────

## Carte pescate a ogni turno da entrambi gli attori
@export_range(1, 10, 1) var cards_per_draw: int = 5

## Se true, l'energia non usata si accumula nel turno successivo.
@export var accumulate_energy: bool = false

# ── UI / Feature flags ───────────────────────────────────────────────────────

## Mostra o nasconde la mano del nemico (utile per playtest / difficoltà)
@export var show_enemy_hand: bool = true

## Mostra i dettagli delle carte nemico (nome, effetti, costo).
## Se false le carte appaiono come dorso coperto.
@export var show_enemy_card_details: bool = false

# ── Animazioni ───────────────────────────────────────────────────────────────

## Moltiplicatore velocità animazioni (1.0 = normale, 0.0 = istantanee)
@export_range(0.0, 2.0, 0.1) var animation_speed: float = 1.0

## Delay tra carte pescate dal giocatore (secondi)
@export_range(0.0, 0.5, 0.05) var card_draw_delay: float = 0.15

## Se true, il turno nemico viene animato carta per carta.
@export var animate_enemy_turn: bool = true

## Pausa (secondi) dopo che il nemico ha pescato, prima che inizi a giocare.
@export_range(0.2, 3.0, 0.1) var enemy_draw_pause: float = 1.0

## Delay (secondi) tra una carta nemico e la successiva durante ENEMY_PLAY.
@export_range(0.1, 2.0, 0.1) var enemy_card_play_delay: float = 0.7

func _ready() -> void:
	DebugLogger.log_system("[Config] player_hp=%d | enemy_hp=%d | energy=%d/%d | draw=%d | animate_enemy=%s" % [
		player_max_hp, enemy_max_hp, player_max_energy, enemy_max_energy,
		cards_per_draw, animate_enemy_turn
	])
