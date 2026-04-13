from __future__ import annotations
import json
import os
from .card import Card

# Resolve path relative to this file: playtests/sim/ → ../../data/
_DATA_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "..", "data")
)


def load_deck(filename: str) -> list[Card]:
    """Load a deck JSON from the data/ directory and return a list of Card."""
    path = os.path.join(_DATA_DIR, filename)
    with open(path, encoding="utf-8") as f:
        raw = json.load(f)

    cards: list[Card] = []
    for entry in raw["cards"]:
        cards.append(
            Card(
                name=entry["name"],
                damage=int(entry.get("damage", 0)),
                shield=int(entry.get("shield", 0)),
                heal=int(entry.get("heal", 0)),
                energy_cost=int(entry.get("energy", 0)),
                status_effect=str(entry.get("status_effect", "")),
                status_target=str(entry.get("status_target", "")),
            )
        )
    return cards


def load_player_deck() -> list[Card]:
    return load_deck("deck_player.json")


def load_enemy_deck() -> list[Card]:
    return load_deck("deck_enemy.json")
