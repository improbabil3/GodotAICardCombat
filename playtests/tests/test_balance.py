"""
Balance KPI tests.

These tests intentionally FAIL with the current deck configuration –
that is the point: they document the balance problems so you can verify
whether a deck change actually fixes them.

Run with:
    python -m pytest playtests/tests/test_balance.py -v

All four KPIs must pass for the game to be considered balanced.
"""
import pytest
from playtests.analysis.runner import run_simulations
from playtests.analysis.report import (
    generate_report,
    KPI_AVG_TURNS_MAX,
    KPI_PLAYER_WIN_RATE_MIN,
    KPI_PLAYER_WIN_RATE_MAX,
    KPI_STALEMATE_RATE_MAX,
    KPI_P95_TURNS_MAX,
)

N_GAMES = 5_000  # Fast enough for CI; increase to 20 000 for final verification


@pytest.fixture(scope="module")
def stats():
    """Run simulations once and share results across all tests in this module."""
    results = run_simulations(n=N_GAMES)
    return generate_report(results)


class TestBalanceKPIs:
    def test_average_turns_at_most_20(self, stats):
        avg = stats["avg_turns"]
        assert avg <= KPI_AVG_TURNS_MAX, (
            f"Average game length {avg:.1f} turns exceeds target ≤ {KPI_AVG_TURNS_MAX}. "
            "The heal/shield economy is keeping both sides alive too long."
        )

    def test_player_win_rate_is_fair(self, stats):
        pwr = stats["player_win_rate"]
        assert KPI_PLAYER_WIN_RATE_MIN <= pwr <= KPI_PLAYER_WIN_RATE_MAX, (
            f"Player win rate {pwr:.1%} outside fair range "
            f"[{KPI_PLAYER_WIN_RATE_MIN:.0%}, {KPI_PLAYER_WIN_RATE_MAX:.0%}]. "
            "Deck asymmetry or AI logic mismatch detected."
        )

    def test_stalemate_rate_below_1_percent(self, stats):
        sr = stats["stalemate_rate"]
        assert sr < KPI_STALEMATE_RATE_MAX, (
            f"Stalemate rate {sr:.1%} exceeds {KPI_STALEMATE_RATE_MAX:.0%}. "
            f"{stats['stalemates']:,} of {stats['total_games']:,} games hit the "
            "200-turn cap. This is the exact bug reported at turn 38."
        )

    def test_p95_turns_at_most_40(self, stats):
        p95 = stats["p95_turns"]
        assert p95 <= KPI_P95_TURNS_MAX, (
            f"95th-percentile game length {p95:.0f} turns exceeds target ≤ {KPI_P95_TURNS_MAX}. "
            "Even in the long tail, games are running too long."
        )


class TestBalanceDiagnostics:
    """
    Diagnostic tests that always pass but print useful data.
    They help you understand *why* the KPI tests fail.
    """

    def test_print_full_report(self, stats):
        """Print the full report so it appears in pytest -s output."""
        print(f"\n  total={stats['total_games']} "
              f"player_wins={stats['player_wins']} ({stats['player_win_rate']:.1%}) "
              f"enemy_wins={stats['enemy_wins']} ({stats['enemy_win_rate']:.1%}) "
              f"stalemates={stats['stalemates']} ({stats['stalemate_rate']:.1%})")
        print(f"  avg={stats['avg_turns']:.1f}  "
              f"median={stats['median_turns']:.1f}  "
              f"p95={stats['p95_turns']:.1f}  "
              f"min={stats['min_turns']}  max={stats['max_turns']}")
        # This test always passes; it's just for visibility.

    def test_some_games_finish_quickly(self, stats):
        """At least 1 % of games should finish in ≤ 10 turns.
        If zero games finish that fast the deck has no burst potential at all."""
        results = run_simulations(n=1_000)
        fast = sum(1 for r in results if r.turns <= 10)
        assert fast >= 5, (
            f"Only {fast}/1000 games ended within 10 turns. "
            "The deck has no reliable burst damage path."
        )
