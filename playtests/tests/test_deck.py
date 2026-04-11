import pytest
from playtests.sim.card import Card
from playtests.sim.actor import Actor


def _card(name: str = "X", energy: int = 1) -> Card:
    return Card(name=name, damage=1, shield=0, heal=0, energy_cost=energy)


def _actor_with_deck(cards: list[Card]) -> Actor:
    return Actor(name="P", max_hp=20, max_energy=3, starting_deck=cards)


class TestDrawCards:
    def test_draw_from_fresh_deck(self):
        deck = [_card(str(i)) for i in range(10)]
        actor = _actor_with_deck(deck)
        actor.draw_cards(5)
        assert len(actor.hand) == 5
        assert len(actor.deck) == 5

    def test_draw_does_not_exceed_deck_size(self):
        deck = [_card("A"), _card("B")]
        actor = _actor_with_deck(deck)
        actor.draw_cards(10)
        assert len(actor.hand) == 2
        assert len(actor.deck) == 0

    def test_graveyard_recycled_when_deck_exhausted(self):
        # 5-card deck; draw 5 to empty it, then draw 3 more via graveyard recycle
        deck = [_card(str(i)) for i in range(5)]
        actor = _actor_with_deck(deck)
        actor.draw_cards(5)
        # Manually discard hand to populate graveyard
        actor.discard_hand()
        assert len(actor.graveyard) == 5
        assert len(actor.deck) == 0
        # Draw again – should recycle graveyard
        actor.draw_cards(3)
        assert len(actor.hand) == 3
        # After recycle, graveyard cleared, remaining go to deck
        assert len(actor.graveyard) == 0
        assert len(actor.deck) == 2

    def test_no_draw_when_completely_empty(self):
        actor = _actor_with_deck([])
        actor.draw_cards(5)
        assert actor.hand == []


class TestDiscardOperations:
    def test_discard_card_moves_to_graveyard(self):
        c = _card("X")
        actor = _actor_with_deck([c])
        actor.draw_cards(1)
        actor.discard_card(c)
        assert c not in actor.hand
        assert c in actor.graveyard

    def test_discard_hand_moves_all(self):
        deck = [_card(str(i)) for i in range(5)]
        actor = _actor_with_deck(deck)
        actor.draw_cards(5)
        actor.discard_hand()
        assert actor.hand == []
        assert len(actor.graveyard) == 5

    def test_discard_card_not_in_hand_still_adds_to_graveyard(self):
        """Calling discard_card for a card not in hand shouldn't raise."""
        c = _card("Ghost")
        actor = _actor_with_deck([])
        actor.discard_card(c)
        assert c in actor.graveyard


class TestMultiCycleIntegrity:
    def test_all_cards_accounted_for_across_cycles(self):
        """After N draws the total count of deck+hand+graveyard never changes."""
        deck_size = 20
        deck = [_card(str(i)) for i in range(deck_size)]
        actor = _actor_with_deck(deck)

        for _ in range(6):
            actor.reset_for_turn()
            actor.draw_cards(5)
            actor.discard_hand()

        total = len(actor.deck) + len(actor.hand) + len(actor.graveyard)
        assert total == deck_size

    def test_deck_reshuffled_after_recycle(self):
        """Cards don't disappear after multiple graveyard recycles."""
        deck = [_card(str(i)) for i in range(5)]
        actor = _actor_with_deck(deck)
        draws = 0
        for _ in range(4):  # 4 cycles × 5 cards = 20 draws from a 5-card deck
            actor.draw_cards(5)
            draws += len(actor.hand)
            actor.discard_hand()
        assert draws == 20
