from __future__ import annotations
from collections.abc import Callable
from ..sim.game import Game, GameResult


def run_simulations(
    n: int = 10_000,
    record_history: bool = False,
    progress_callback: Callable[[int], None] | None = None,
) -> list[GameResult]:
    """
    Run n independent game simulations and return all results.

    A single Game instance is reused because its state is fully reset
    inside Game.run() on each call (fresh Actors, fresh shuffled decks).

    Args:
        n: Number of games to simulate.
        record_history: Whether to record per-turn HP snapshots.
        progress_callback: Optional callable invoked every 1 000 games
            with the number of completed games so far.
    """
    game = Game(record_history=record_history)
    results: list[GameResult] = []
    for i in range(n):
        results.append(game.run())
        if progress_callback and (i + 1) % 1_000 == 0:
            progress_callback(i + 1)
    return results
