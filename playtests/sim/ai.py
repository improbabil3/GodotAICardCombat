from __future__ import annotations
from .actor import Actor
from .card import Card

SURVIVAL_HP_RATIO = 0.30


class GreedyAI:
    """
    Exact Python mirror of EnemyAI in enemy_ai.gd.

    Sort hand by priority score descending.
    Iterate: skip cards we cannot afford (continue), play cards we can afford.
    Stop early only when energy reaches exactly 0 (break).
    Discard remaining hand at the end.
    """

    def play_turn(self, actor: Actor) -> list[Card]:
        survival_mode = (actor.hp / actor.max_hp) <= SURVIVAL_HP_RATIO

        # Sort descending by priority – mirrors _sort_hand
        sorted_hand = sorted(
            actor.hand,
            key=lambda c: c.priority(survival_mode),
            reverse=True,
        )

        played: list[Card] = []
        for card in sorted_hand:
            if actor.energy < card.energy_cost:
                continue  # Cannot afford – skip, don't stop (mirrors GDScript continue)

            actor.spend_energy(card.energy_cost)
            actor.add_card_intents(card)
            actor.discard_card(card)
            played.append(card)

            if actor.energy == 0:
                break  # Energy exhausted – stop early (mirrors GDScript break)

        actor.discard_hand()  # Discard whatever remains
        return played
