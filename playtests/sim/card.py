from __future__ import annotations
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Card:
    """Immutable card data – mirrors CardData in GDScript."""
    name: str
    damage: int
    shield: int
    heal: int
    energy_cost: int
    status_effect: str = ""   # "burn"|"poison"|"freeze"|"haste"|"blessed"|""
    status_target: str = ""   # "self"|"opponent"|""

    def priority(self, survival_mode: bool) -> float:
        """
        Priority score used by GreedyAI to sort the hand.
        Mirrors EnemyAI._priority() in enemy_ai.gd.

        Aggressive (default): damage > damage+shield > shield > heal
        Survival (hp ≤ 30%):  heal > shield > damage
        Status cards get a +1.5 bonus to encourage their use.
        """
        cost_penalty = self.energy_cost * 0.1
        status_bonus = 1.5 if self.status_effect else 0.0
        if survival_mode:
            return self.heal * 3.0 + self.shield * 2.0 + self.damage + status_bonus - cost_penalty
        return self.damage * 3.0 + self.shield * 1.5 + self.heal * 0.5 + status_bonus - cost_penalty

    def has_status_effect(self) -> bool:
        return bool(self.status_effect)

    def __str__(self) -> str:
        status_str = f" [{self.status_effect}→{self.status_target}]" if self.status_effect else ""
        return (
            f"{self.name} [dmg={self.damage} shd={self.shield} "
            f"heal={self.heal} ene={self.energy_cost}]{status_str}"
        )
