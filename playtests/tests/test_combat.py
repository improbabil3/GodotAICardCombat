import pytest
from playtests.sim.card import Card
from playtests.sim.actor import Actor
from playtests.sim.combat import CombatResolver


@pytest.fixture
def resolver() -> CombatResolver:
    return CombatResolver()


def _make_actor(name: str = "P", hp: int = 20, max_hp: int = 20) -> Actor:
    a = Actor(name=name, max_hp=max_hp, max_energy=3, starting_deck=[])
    a.hp = hp
    return a


class TestPhase1Healing:
    def test_player_heals(self, resolver):
        p = _make_actor("P", hp=15)
        e = _make_actor("E")
        p.intent_heal = 3
        resolver.resolve(p, e)
        assert p.hp == 18

    def test_healing_capped_at_max_hp(self, resolver):
        p = _make_actor("P", hp=19)
        e = _make_actor("E")
        p.intent_heal = 5
        resolver.resolve(p, e)
        assert p.hp == 20

    def test_enemy_heals(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E", hp=10)
        e.intent_heal = 4
        resolver.resolve(p, e)
        assert e.hp == 14

    def test_no_heal_when_zero(self, resolver):
        p = _make_actor("P", hp=12)
        e = _make_actor("E")
        p.intent_heal = 0
        resolver.resolve(p, e)
        assert p.hp == 12  # Unchanged


class TestPhase2PlayerAttack:
    def test_player_kills_enemy(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E", hp=3)
        p.intent_damage = 5
        result = resolver.resolve(p, e)
        assert not result.continues
        assert result.player_won
        assert e.hp == 0

    def test_shield_fully_cancels_damage(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E")
        p.intent_damage = 3
        e.intent_shield = 3
        result = resolver.resolve(p, e)
        assert result.continues
        assert e.hp == 20

    def test_shield_exceeds_damage_no_negative_hp_loss(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E")
        p.intent_damage = 2
        e.intent_shield = 5
        result = resolver.resolve(p, e)
        assert result.continues
        assert e.hp == 20  # No healing from excess shield

    def test_net_positive_damage(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E")
        p.intent_damage = 5
        e.intent_shield = 2
        resolver.resolve(p, e)
        assert e.hp == 17  # 20 - (5-2) = 17


class TestPhase3EnemyAttack:
    def test_enemy_kills_player(self, resolver):
        p = _make_actor("P", hp=2)
        e = _make_actor("E")
        e.intent_damage = 5
        result = resolver.resolve(p, e)
        assert not result.continues
        assert not result.player_won

    def test_player_shield_blocks_enemy(self, resolver):
        p = _make_actor("P")
        e = _make_actor("E")
        p.intent_shield = 4
        e.intent_damage = 4
        result = resolver.resolve(p, e)
        assert result.continues
        assert p.hp == 20


class TestResolutionOrder:
    def test_heal_applied_before_damage(self, resolver):
        """Player at 1 HP, heals 3, then takes 2 dmg → survives."""
        p = _make_actor("P", hp=1)
        e = _make_actor("E")
        p.intent_heal = 3
        e.intent_damage = 2
        result = resolver.resolve(p, e)
        # After heal: 4 HP. After 2 dmg: 2 HP. Still alive.
        assert result.continues
        assert p.hp == 2

    def test_enemy_not_hit_if_already_dead(self, resolver):
        """Enemy die in phase 2; player should never take damage in phase 3."""
        p = _make_actor("P")
        e = _make_actor("E", hp=1)
        p.intent_damage = 10
        e.intent_damage = 10  # Would wipe the player, but enemy dies first
        result = resolver.resolve(p, e)
        assert result.player_won
        assert p.hp == 20  # Player never took damage

    def test_both_survive_zero_nets(self, resolver):
        """Zero-net turn: no damage gets through on either side."""
        p = _make_actor("P")
        e = _make_actor("E")
        p.intent_damage = 3
        e.intent_shield = 3
        e.intent_damage = 3
        p.intent_shield = 3
        result = resolver.resolve(p, e)
        assert result.continues
        assert p.hp == 20
        assert e.hp == 20
