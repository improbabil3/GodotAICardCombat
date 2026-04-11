from __future__ import annotations
from dataclasses import dataclass, field

from .actor import Actor
from .ai import GreedyAI
from .combat import CombatResolver
from .deck_loader import load_player_deck, load_enemy_deck

# ── Constants (mirrors config.gd) ─────────────────────────────────────────
PLAYER_MAX_HP = 20
PLAYER_MAX_ENERGY = 3
ENEMY_MAX_HP = 20
ENEMY_MAX_ENERGY = 3
CARDS_PER_DRAW = 5
MAX_TURNS = 200  # Safety cap; hitting this is counted as "stalemate"


@dataclass
class TurnSnapshot:
    turn: int
    player_hp: int
    enemy_hp: int
    player_intents: tuple[int, int, int]  # (damage, shield, heal) BEFORE resolution
    enemy_intents: tuple[int, int, int]


@dataclass
class GameResult:
    winner: str          # "player" | "enemy" | "stalemate"
    turns: int
    player_hp_final: int
    enemy_hp_final: int
    hp_history: list[TurnSnapshot] = field(default_factory=list)


class Game:
    """
    Full game loop – mirrors TurnManager in GDScript.

    Both sides are controlled by GreedyAI for simulation purposes.
    Each call to run() is independent: fresh Actors, fresh shuffled decks.
    """

    def __init__(self, record_history: bool = False) -> None:
        self._ai = GreedyAI()
        self._resolver = CombatResolver()
        self._record_history = record_history
        # Load decks once – they're immutable Card lists
        self._player_deck = load_player_deck()
        self._enemy_deck = load_enemy_deck()

    def run(self) -> GameResult:
        player = Actor(
            name="Player",
            max_hp=PLAYER_MAX_HP,
            max_energy=PLAYER_MAX_ENERGY,
            starting_deck=self._player_deck,
        )
        enemy = Actor(
            name="Enemy",
            max_hp=ENEMY_MAX_HP,
            max_energy=ENEMY_MAX_ENERGY,
            starting_deck=self._enemy_deck,
        )

        history: list[TurnSnapshot] = []

        for turn in range(1, MAX_TURNS + 1):
            # ── Start of turn ──────────────────────────────────────────────
            player.reset_for_turn()
            enemy.reset_for_turn()

            # ── Draw ──────────────────────────────────────────────────────
            player.draw_cards(CARDS_PER_DRAW)
            enemy.draw_cards(CARDS_PER_DRAW)

            # ── AI plays ──────────────────────────────────────────────────
            self._ai.play_turn(player)
            self._ai.play_turn(enemy)

            # ── Optional snapshot (pre-resolution HP for analysis) ────────
            if self._record_history:
                history.append(
                    TurnSnapshot(
                        turn=turn,
                        player_hp=player.hp,
                        enemy_hp=enemy.hp,
                        player_intents=(
                            player.intent_damage,
                            player.intent_shield,
                            player.intent_heal,
                        ),
                        enemy_intents=(
                            enemy.intent_damage,
                            enemy.intent_shield,
                            enemy.intent_heal,
                        ),
                    )
                )

            # ── Resolve ───────────────────────────────────────────────────
            result = self._resolver.resolve(player, enemy)
            if not result.continues:
                winner = "player" if result.player_won else "enemy"
                return GameResult(
                    winner=winner,
                    turns=turn,
                    player_hp_final=player.hp,
                    enemy_hp_final=enemy.hp,
                    hp_history=history,
                )

        # Reached MAX_TURNS → stalemate
        return GameResult(
            winner="stalemate",
            turns=MAX_TURNS,
            player_hp_final=player.hp,
            enemy_hp_final=enemy.hp,
            hp_history=history,
        )
