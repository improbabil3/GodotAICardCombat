from __future__ import annotations
import statistics
from ..sim.game import GameResult, RunResult

# ── Balance KPI thresholds ─────────────────────────────────────────────────
KPI_AVG_TURNS_MAX = 20
KPI_PLAYER_WIN_RATE_MIN = 0.30
KPI_PLAYER_WIN_RATE_MAX = 0.70
KPI_STALEMATE_RATE_MAX = 0.01
KPI_P95_TURNS_MAX = 40


def generate_report(results: list[GameResult]) -> dict:
    """
    Compute aggregated statistics from a list of GameResult objects.
    Returns a plain dict so callers can assert on individual values.
    """
    n = len(results)
    if n == 0:
        raise ValueError("results is empty")

    player_wins = sum(1 for r in results if r.winner == "player")
    enemy_wins  = sum(1 for r in results if r.winner == "enemy")
    stalemates  = sum(1 for r in results if r.winner == "stalemate")

    all_turns = sorted(r.turns for r in results)

    def percentile(sorted_seq: list[int], p: float) -> float:
        idx = int(len(sorted_seq) * p)
        return float(sorted_seq[min(idx, len(sorted_seq) - 1)])

    return {
        "total_games":       n,
        "player_wins":       player_wins,
        "enemy_wins":        enemy_wins,
        "stalemates":        stalemates,
        "player_win_rate":   player_wins / n,
        "enemy_win_rate":    enemy_wins  / n,
        "stalemate_rate":    stalemates  / n,
        "avg_turns":         statistics.mean(all_turns),
        "median_turns":      statistics.median(all_turns),
        "p95_turns":         percentile(all_turns, 0.95),
        "min_turns":         min(all_turns),
        "max_turns":         max(all_turns),
    }


def print_report(results: list[GameResult]) -> None:
    stats = generate_report(results)

    W = 60
    print("\n" + "=" * W)
    print("  PLAYTEST SIMULATION REPORT")
    print("=" * W)
    print(f"  Games simulated:   {stats['total_games']:>8,}")
    print(f"  Player wins:       {stats['player_wins']:>8,}  ({stats['player_win_rate']:.1%})")
    print(f"  Enemy wins:        {stats['enemy_wins']:>8,}  ({stats['enemy_win_rate']:.1%})")
    print(f"  Stalemates (≥200): {stats['stalemates']:>8,}  ({stats['stalemate_rate']:.1%})")
    print("-" * W)
    print(f"  Avg turns:         {stats['avg_turns']:>8.1f}")
    print(f"  Median turns:      {stats['median_turns']:>8.1f}")
    print(f"  P95 turns:         {stats['p95_turns']:>8.1f}")
    print(f"  Min / Max turns:   {stats['min_turns']:>4} / {stats['max_turns']:>4}")
    print("=" * W)

    # ── KPI assessment ────────────────────────────────────────────────────
    checks = [
        (
            "Avg turns ≤ 20",
            stats["avg_turns"] <= KPI_AVG_TURNS_MAX,
            f"{stats['avg_turns']:.1f} (target ≤ {KPI_AVG_TURNS_MAX})",
        ),
        (
            "Player win rate 30–70 %",
            KPI_PLAYER_WIN_RATE_MIN <= stats["player_win_rate"] <= KPI_PLAYER_WIN_RATE_MAX,
            f"{stats['player_win_rate']:.1%}",
        ),
        (
            "Stalemate rate < 1 %",
            stats["stalemate_rate"] < KPI_STALEMATE_RATE_MAX,
            f"{stats['stalemate_rate']:.1%}",
        ),
        (
            "P95 turns ≤ 40",
            stats["p95_turns"] <= KPI_P95_TURNS_MAX,
            f"{stats['p95_turns']:.1f}",
        ),
    ]

    print("\n  BALANCE KPIs")
    print("-" * W)

    all_pass = True
    for label, passed, detail in checks:
        status = "PASS" if passed else "FAIL"
        if not passed:
            all_pass = False
        print(f"  [{status}]  {label:<30}  {detail}")

    print("-" * W)
    print(f"  Overall: {'ALL PASS ✓' if all_pass else 'NEEDS WORK ✗'}")
    print("=" * W + "\n")


def print_balance_recommendations(results: list[GameResult]) -> None:
    """
    Print actionable balance suggestions based on the raw numbers.
    Does NOT modify any game files; output is advisory only.
    """
    stats = generate_report(results)

    print("\n  BALANCE RECOMMENDATIONS")
    print("-" * 60)

    if stats["avg_turns"] > KPI_AVG_TURNS_MAX:
        print(f"  ⚠ Average game length is {stats['avg_turns']:.1f} turns (target ≤ 20).")
        print("    Root cause candidates:")
        print("    • Free 0-energy heal/shield cards (Nano Heal, Ion Strike, Deflect Field)")
        print("      allow both sides to play for free every turn, negating net damage.")
        print("    • Both decks are structurally symmetric → no escalation pressure.")
        print("    Suggested fixes (choose 1–2):")
        print("    1. Remove healing from both decks entirely; replace with utility cards.")
        print("    2. Give free (energy=0) cards a drawback, e.g., damage the caster by 1.")
        print("    3. Add a passive 'bleed' mechanic: each turn both actors lose 1 HP.")
        print("    4. Reduce max_hp from 20 → 12 to compress the game window.")
        print("    5. Cap shield per turn at 2 so heal cards can't hold damage to zero.")

    if not (KPI_PLAYER_WIN_RATE_MIN <= stats["player_win_rate"] <= KPI_PLAYER_WIN_RATE_MAX):
        pwr = stats["player_win_rate"]
        direction = "too high" if pwr > 0.50 else "too low"
        print(f"\n  ⚠ Player win rate {pwr:.1%} is {direction} (target 30–70 %).")
        print("    Both decks are mirrors, so this should be near 50 % in a large sample.")
        print("    High deviation may indicate a deck-loading or shuffle bug.")

    if stats["stalemate_rate"] >= KPI_STALEMATE_RATE_MAX:
        print(f"\n  ⚠ {stats['stalemate_rate']:.1%} of games hit the 200-turn stalemate cap.")
        print("    This is the main reported symptom. The healing/shield economy is the cause.")

    print()


# ── Run-level report ──────────────────────────────────────────────────────

def generate_run_report(results: list[RunResult]) -> dict:
    """Compute aggregated statistics from a list of RunResult objects."""
    n = len(results)
    if n == 0:
        raise ValueError("results is empty")

    completed = sum(1 for r in results if r.defeated_at < 0)
    defeated  = n - completed

    rating_counts: dict[str, int] = {}
    for r in results:
        rating_counts[r.rating] = rating_counts.get(r.rating, 0) + 1

    all_scores = [r.total_score for r in results]
    defeat_positions = [r.defeated_at for r in results if r.defeated_at >= 0]

    return {
        "total_runs":        n,
        "runs_completed":    completed,
        "runs_defeated":     defeated,
        "completion_rate":   completed / n,
        "avg_score":         statistics.mean(all_scores),
        "median_score":      statistics.median(all_scores),
        "rating_counts":     rating_counts,
        "avg_defeat_at":     statistics.mean(defeat_positions) if defeat_positions else None,
    }


def print_run_report(results: list[RunResult]) -> None:
    stats = generate_run_report(results)
    W = 60
    print("\n" + "=" * W)
    print("  RUN SIMULATION REPORT  (4-encounter sequential)")
    print("=" * W)
    print(f"  Runs simulated:    {stats['total_runs']:>8,}")
    print(f"  Runs completed:    {stats['runs_completed']:>8,}  ({stats['completion_rate']:.1%})")
    print(f"  Runs aborted:      {stats['runs_defeated']:>8,}  ({1 - stats['completion_rate']:.1%})")
    print("-" * W)
    print(f"  Avg total score:   {stats['avg_score']:>8.1f}")
    print(f"  Median score:      {stats['median_score']:>8.1f}")
    if stats["avg_defeat_at"] is not None:
        print(f"  Avg defeat at enc: {stats['avg_defeat_at']:>8.2f}  (0=first base)")
    print("-" * W)
    print("  Rating distribution:")
    for rating in ("S", "A", "B", "C", "D", "E", "F"):
        count = stats["rating_counts"].get(rating, 0)
        pct = count / stats["total_runs"]
        print(f"    {rating}: {count:>7,}  ({pct:.1%})")
    print("=" * W + "\n")
