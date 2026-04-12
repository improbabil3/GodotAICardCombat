#!/usr/bin/env python3
"""
run_character_stats.py

Esegui N run (default 5000) per ogni personaggio disponibile e riporta:
- quante run battono il primo nemico (>=1)
- quante battono entrambi i nemici base (>=2)
- quante battono i 2 nemici + l'elité (>=3)
- quante completano la run (>=4)

Lo script replica il comportamento di build mazzo: 10 carte specifiche scelte a caso
+ 10 carte dal mazzo base (`deck_player.json`).

Uso:
    python -m playtests.analysis.run_character_stats --runs 5000
"""
from __future__ import annotations
import argparse
import random
import time
from typing import List, Tuple

from playtests.sim.game import Game, _build_roster
from playtests.sim.deck_loader import load_deck

CHARACTER_DECKS: List[Tuple[str, str]] = [
    ("Omega Pilot", "deck_omega_pilot_specific.json"),
    ("Phoenix Guardian", "deck_phoenix_guardian_specific.json"),
    ("Apex Striker", "deck_apex_striker_specific.json"),
    ("Void Walker", "deck_void_walker_specific.json"),
    ("Cyber Mystic", "deck_cyber_mystic_specific.json"),
]


def build_player_final_deck(specific_file: str):
    specific_cards = load_deck(specific_file)
    if len(specific_cards) < 10:
        raise RuntimeError(f"Specific deck {specific_file} has < 10 cards")
    selected_specific = random.sample(specific_cards, 10)

    base_cards = load_deck("deck_player.json")
    if len(base_cards) < 10:
        raise RuntimeError("Base deck has < 10 cards")
    base_selected = random.sample(base_cards, 10)

    return selected_specific + base_selected


def run_for_character(specific_file: str, runs: int) -> List[int]:
    # counts[i] = numero di run che hanno battuto almeno i+1 incontri
    counts = [0, 0, 0, 0]
    for _ in range(runs):
        player_deck = build_player_final_deck(specific_file)
        roster = _build_roster()
        successes = 0
        for spec in roster:
            enemy_deck = load_deck(spec.deck_file)
            game = Game(record_history=False)
            result = game._run_encounter(player_deck, enemy_deck, spec.max_hp, spec.max_energy)
            if result.winner == "player":
                successes += 1
            else:
                break
        for i in range(successes):
            counts[i] += 1
    return counts


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--runs", type=int, default=5000)
    p.add_argument("--seed", type=int, default=None)
    p.add_argument("--character", type=str, default=None, 
                   help="Specify character name (e.g. 'Omega Pilot'). If omitted, runs all.")
    args = p.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    total_start = time.time()
    
    # Filter characters if specified
    chars_to_run = CHARACTER_DECKS
    if args.character:
        chars_to_run = [c for c in CHARACTER_DECKS if c[0] == args.character]
        if not chars_to_run:
            print(f"ERROR: Character '{args.character}' not found.")
            print(f"Available: {', '.join(c[0] for c in CHARACTER_DECKS)}")
            return
    
    print(f"Running {args.runs} runs per character (total characters: {len(chars_to_run)})")

    for name, deck_file in chars_to_run:
        start = time.time()
        counts = run_for_character(deck_file, args.runs)
        elapsed = time.time() - start
        print("\nCharacter: %s" % name)
        print("Runs: %d" % args.runs)
        print("Beat >=1: %d (%.2f%%)" % (counts[0], counts[0] / args.runs * 100.0))
        print("Beat >=2: %d (%.2f%%)" % (counts[1], counts[1] / args.runs * 100.0))
        print("Beat >=3: %d (%.2f%%)" % (counts[2], counts[2] / args.runs * 100.0))
        print("Beat >=4 (complete run): %d (%.2f%%)" % (counts[3], counts[3] / args.runs * 100.0))
        print("Elapsed: %.1fs" % elapsed)

    print("\nTotal elapsed: %.1fs" % (time.time() - total_start))


if __name__ == "__main__":
    main()
