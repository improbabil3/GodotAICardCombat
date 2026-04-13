from __future__ import annotations
from dataclasses import dataclass
from .actor import Actor


@dataclass
class CombatResult:
    continues: bool
    player_won: bool  # Only meaningful when continues is False


class CombatResolver:
    """
    Exact Python mirror of CombatResolver in combat_resolver.gd.

    Resolution order:
      1. Heal both actors
      2. Player attacks enemy  → if enemy dies: player wins, stop
      3. Enemy attacks player  → if player dies: enemy wins, stop
      4. Both alive            → continues = True
    """

    def resolve(self, player: Actor, enemy: Actor) -> CombatResult:
        # ── Phase 1: Healing ──────────────────────────────────────────────
        if player.intent_heal > 0:
            player.heal_hp(player.intent_heal)
        if enemy.intent_heal > 0:
            enemy.heal_hp(enemy.intent_heal)

        # ── Phase 2: Player → Enemy ───────────────────────────────────────
        net_to_enemy = player.intent_damage - enemy.intent_shield
        if net_to_enemy > 0:
            enemy.take_damage(net_to_enemy)
        if not enemy.is_alive():
            if enemy.has_status("blessed"):
                enemy.hp = 1  # Blessed: survive with 1 HP
            else:
                return CombatResult(continues=False, player_won=True)

        # ── Phase 3: Enemy → Player ───────────────────────────────────────
        net_to_player = enemy.intent_damage - player.intent_shield
        if net_to_player > 0:
            player.take_damage(net_to_player)
        if not player.is_alive():
            if player.has_status("blessed"):
                player.hp = 1  # Blessed: survive with 1 HP
            else:
                return CombatResult(continues=False, player_won=False)

        return CombatResult(continues=True, player_won=False)
