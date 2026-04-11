import pytest
from playtests.sim.game import Game, GameResult, MAX_TURNS


class TestGameTermination:
    @pytest.fixture(autouse=True)
    def game(self):
        self.game = Game(record_history=False)

    def test_game_returns_game_result(self):
        result = self.game.run()
        assert isinstance(result, GameResult)

    def test_winner_is_valid_value(self):
        result = self.game.run()
        assert result.winner in ("player", "enemy", "stalemate")

    def test_turns_is_positive(self):
        result = self.game.run()
        assert result.turns >= 1

    def test_turns_never_exceeds_max(self):
        for _ in range(100):
            result = self.game.run()
            assert result.turns <= MAX_TURNS

    def test_loser_has_zero_or_less_hp(self):
        """The losing actor must be at 0 HP (or we hit the stalemate cap)."""
        for _ in range(50):
            result = self.game.run()
            if result.winner == "player":
                assert result.enemy_hp_final == 0
            elif result.winner == "enemy":
                assert result.player_hp_final == 0
            # stalemate: both could still be alive

    def test_winner_is_alive(self):
        for _ in range(50):
            result = self.game.run()
            if result.winner == "player":
                assert result.player_hp_final > 0
            elif result.winner == "enemy":
                assert result.enemy_hp_final > 0

    def test_multiple_runs_produce_different_results(self):
        """Two independent runs should not always give identical turn counts
        (extremely unlikely if the deck shuffler works correctly)."""
        turns = set(self.game.run().turns for _ in range(30))
        assert len(turns) > 1  # At least two distinct outcomes


class TestHistoryRecording:
    def test_history_disabled_by_default(self):
        game = Game(record_history=False)
        result = game.run()
        assert result.hp_history == []

    def test_history_has_correct_length(self):
        game = Game(record_history=True)
        result = game.run()
        # One snapshot per turn
        assert len(result.hp_history) == result.turns

    def test_history_snapshots_are_sensible(self):
        game = Game(record_history=True)
        result = game.run()
        for snap in result.hp_history:
            assert 0 <= snap.player_hp <= 20
            assert 0 <= snap.enemy_hp <= 20
            assert snap.turn >= 1
