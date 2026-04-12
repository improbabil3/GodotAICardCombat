from __future__ import annotations
from collections.abc import Callable
from ..sim.game import Game, GameResult, RunGame, RunResult


def run_simulations(
    n: int = 10_000,
    record_history: bool = False,
    progress_callback: Callable[[int], None] | None = None,
) -> list[GameResult]:
    """
    Run n independent single-encounter simulations.

    A single Game instance is reused because its state is fully reset
    inside Game.run() on each call (fresh Actors, fresh shuffled decks).
    """
    game = Game(record_history=record_history)
    results: list[GameResult] = []
    for i in range(n):
        results.append(game.run())
        if progress_callback and (i + 1) % 1_000 == 0:
            progress_callback(i + 1)
    return results


def run_run_simulations(
    n: int = 10_000,
    record_history: bool = False,
    progress_callback: Callable[[int], None] | None = None,
) -> list[RunResult]:
    """
    Run n independent full-run simulations (4 sequential encounters).
    Mirrors the GameManager run lifecycle in GDScript.
    """
    run_game = RunGame(record_history=record_history)
    results: list[RunResult] = []
    for i in range(n):
        results.append(run_game.run())
        if progress_callback and (i + 1) % 1_000 == 0:
            progress_callback(i + 1)
    return results

