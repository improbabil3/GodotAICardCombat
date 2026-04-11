#!/usr/bin/env python3
"""
run_playtests.py — CLI entry point for the balance simulation suite.

Usage:
    python playtests/run_playtests.py
    python playtests/run_playtests.py --games 20000
    python playtests/run_playtests.py --games 1000 --csv results.csv
    python playtests/run_playtests.py --history  # record per-turn HP snapshots (slower)

Run from the project root (e.g. e:\\Source\\GodotPlayTest):
    python -m playtests.run_playtests --games 10000
"""
from __future__ import annotations

import argparse
import csv
import sys
import time
from pathlib import Path


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run balance simulations for GodotAICardCombat."
    )
    parser.add_argument(
        "--games",
        type=int,
        default=10_000,
        metavar="N",
        help="Number of games to simulate (default: 10 000).",
    )
    parser.add_argument(
        "--csv",
        dest="csv_path",
        metavar="PATH",
        default=None,
        help="Optional: export per-game results to a CSV file.",
    )
    parser.add_argument(
        "--history",
        action="store_true",
        default=False,
        help="Record per-turn HP snapshots (increases memory use).",
    )
    return parser.parse_args()


def _progress(n: int) -> None:
    print(f"  ... {n:,} games done", end="\r", flush=True)


def _export_csv(results, path: str) -> None:
    fieldnames = ["game", "winner", "turns", "player_hp_final", "enemy_hp_final"]
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for i, r in enumerate(results, 1):
            writer.writerow(
                {
                    "game": i,
                    "winner": r.winner,
                    "turns": r.turns,
                    "player_hp_final": r.player_hp_final,
                    "enemy_hp_final": r.enemy_hp_final,
                }
            )
    print(f"  CSV exported → {path}")


def main() -> None:
    # Import here so path issues surface with a clear message
    try:
        from playtests.analysis.runner import run_simulations
        from playtests.analysis.report import print_report, print_balance_recommendations
    except ImportError as exc:
        print(
            f"Import error: {exc}\n"
            "Make sure you run this from the project root directory:\n"
            "  cd e:\\Source\\GodotPlayTest\n"
            "  python -m playtests.run_playtests",
            file=sys.stderr,
        )
        sys.exit(1)

    args = _parse_args()

    print(f"\nRunning {args.games:,} simulations …")
    t0 = time.perf_counter()
    results = run_simulations(
        n=args.games,
        record_history=args.history,
        progress_callback=_progress,
    )
    elapsed = time.perf_counter() - t0
    print(f"  Done in {elapsed:.1f}s ({args.games / elapsed:,.0f} games/s)    ")

    print_report(results)
    print_balance_recommendations(results)

    if args.csv_path:
        _export_csv(results, args.csv_path)


if __name__ == "__main__":
    main()
