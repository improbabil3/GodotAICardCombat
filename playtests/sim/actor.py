from __future__ import annotations
import random
from .card import Card


class Actor:
    """
    Tracks runtime state for one combatant.
    Mirrors ActorData + DeckManager logic in GDScript.
    """

    def __init__(
        self,
        name: str,
        max_hp: int,
        max_energy: int,
        starting_deck: list[Card],
    ) -> None:
        self.name = name
        self.max_hp = max_hp
        self.max_energy = max_energy
        self._starting_deck = list(starting_deck)

        # Runtime state – reset via reset_for_game()
        self.hp: int = max_hp
        self.energy: int = max_energy
        self.deck: list[Card] = []
        self.hand: list[Card] = []
        self.graveyard: list[Card] = []

        # Per-turn intents – reset via reset_for_turn()
        self.intent_damage: int = 0
        self.intent_shield: int = 0
        self.intent_heal: int = 0

        self._init_deck()

    # ── Initialisation ──────────────────────────────────────────────────────

    def _init_deck(self) -> None:
        self.deck = list(self._starting_deck)
        self.hand = []
        self.graveyard = []
        random.shuffle(self.deck)

    # ── Turn lifecycle ───────────────────────────────────────────────────────

    def reset_for_turn(self) -> None:
        """Reset energy and intents at the start of every turn."""
        self.energy = self.max_energy
        self.intent_damage = 0
        self.intent_shield = 0
        self.intent_heal = 0

    def draw_cards(self, n: int) -> None:
        """
        Draw n cards from deck.  When the deck runs out the graveyard is
        reshuffled into it (mirrors DeckManager.draw_cards).
        """
        for _ in range(n):
            if not self.deck:
                if not self.graveyard:
                    return  # Genuinely no cards anywhere
                self.deck = list(self.graveyard)
                self.graveyard = []
                random.shuffle(self.deck)
            self.hand.append(self.deck.pop())

    # ── Card operations ──────────────────────────────────────────────────────

    def spend_energy(self, amount: int) -> None:
        self.energy -= amount

    def add_card_intents(self, card: Card) -> None:
        self.intent_damage += card.damage
        self.intent_shield += card.shield
        self.intent_heal += card.heal

    def discard_card(self, card: Card) -> None:
        """Remove one instance of card from hand → graveyard."""
        try:
            self.hand.remove(card)
        except ValueError:
            pass
        self.graveyard.append(card)

    def discard_hand(self) -> None:
        """Move entire remaining hand to graveyard."""
        self.graveyard.extend(self.hand)
        self.hand = []

    # ── HP operations ────────────────────────────────────────────────────────

    def take_damage(self, amount: int) -> None:
        self.hp = max(0, self.hp - amount)

    def heal_hp(self, amount: int) -> None:
        self.hp = min(self.max_hp, self.hp + amount)

    def is_alive(self) -> bool:
        return self.hp > 0

    # ── Debug ────────────────────────────────────────────────────────────────

    def __repr__(self) -> str:
        return (
            f"Actor({self.name!r}, hp={self.hp}/{self.max_hp}, "
            f"ene={self.energy}, hand={len(self.hand)}, "
            f"intents=dmg{self.intent_damage}/shd{self.intent_shield}/heal{self.intent_heal})"
        )
