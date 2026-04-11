from __future__ import annotations
from dataclasses import dataclass


@dataclass(frozen=True)
class Card:
    """Immutable card data – mirrors CardData in GDScript."""
    name: str
    damage: int
    shield: int
    heal: int
    energy_cost: int

    def priority(self, survival_mode: bool) -> float:
        """
        Priority score used by GreedyAI to sort the hand.
        Mirrors EnemyAI._priority() in enemy_ai.gd.

        Aggressive (default): damage > damage+shield > shield > heal
        Survival (hp ≤ 30%):  heal > shield > damage
        """
        cost_penalty = self.energy_cost * 0.1
        if survival_mode:
            return self.heal * 3.0 + self.shield * 2.0 + self.damage - cost_penalty
        return self.damage * 3.0 + self.shield * 1.5 + self.heal * 0.5 - cost_penalty

    def __str__(self) -> str:
        return (
            f"{self.name} [dmg={self.damage} shd={self.shield} "
            f"heal={self.heal} ene={self.energy_cost}]"
        )
