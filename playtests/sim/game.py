from __future__ import annotations
import random
from dataclasses import dataclass, field

from .actor import Actor
from .ai import GreedyAI
from .combat import CombatResolver
from .deck_loader import load_player_deck, load_deck

# ── Constants (mirrors config.gd) ─────────────────────────────────────────
PLAYER_MAX_HP = 20
PLAYER_MAX_ENERGY = 3
ENEMY_MAX_HP = 20
ENEMY_MAX_ENERGY = 3
CARDS_PER_DRAW = 5
MAX_TURNS = 200  # Safety cap; hitting this is counted as "stalemate"

# Score / rating (mirrors config.gd)
SCORE_BASE_ENEMY = 100
SCORE_ELITE_ENEMY = 250
SCORE_BOSS_ENEMY = 500
RATING_B_THRESHOLD = 200
RATING_A_THRESHOLD = 600
RATING_S_THRESHOLD = 1200


@dataclass
class EnemySpec:
    """Mirrors EnemyData in GDScript."""
    name: str
    deck_file: str
    max_hp: int
    max_energy: int
    base_score: int


# ── Enemy pools (mirrors GameManager._build_enemy_roster) ─────────────────

_BASE_POOL: list[EnemySpec] = [
    EnemySpec("Nexus Warlord",  "deck_enemy.json",               20, 3, SCORE_BASE_ENEMY),
    EnemySpec("Scrap Raider",   "deck_enemy_scrap_raider.json",  20, 3, SCORE_BASE_ENEMY),
    EnemySpec("Void Drone",     "deck_enemy_void_drone.json",    20, 3, SCORE_BASE_ENEMY),
    EnemySpec("Plasma Grunt",   "deck_enemy_plasma_grunt.json",  20, 3, SCORE_BASE_ENEMY),
    EnemySpec("Phase Stalker",  "deck_enemy_phase_stalker.json", 20, 3, SCORE_BASE_ENEMY),
]

_ELITE_POOL: list[EnemySpec] = [
    EnemySpec("Iron Enforcer", "deck_enemy_elite_iron_enforcer.json", 25, 3, SCORE_ELITE_ENEMY),
    EnemySpec("Void Overlord", "deck_enemy_elite_void_overlord.json", 25, 3, SCORE_ELITE_ENEMY),
]

_BOSS: EnemySpec = EnemySpec(
    "Galactic Tyrant", "deck_enemy_boss_galactic_tyrant.json", 30, 3, SCORE_BOSS_ENEMY
)


def _build_roster() -> list[EnemySpec]:
    """Pick 2 random base + 1 random elite + fixed boss."""
    base = random.sample(_BASE_POOL, 2)
    elite = random.choice(_ELITE_POOL)
    return [base[0], base[1], elite, _BOSS]


def _calculate_score(base_score: int, hp_remaining: int, turns: int) -> float:
    """Mirrors GameManager._calculate_score."""
    t = max(1, turns)
    return base_score * (hp_remaining / 20.0) * (10.0 / t)


def _run_rating(run_scores: list[float], defeated_at: int) -> str:
    """Mirrors GameManager.run_rating."""
    if defeated_at >= 0:
        if defeated_at == 3:
            return "D"
        elif defeated_at == 2:
            return "E"
        else:
            return "F"
    total = sum(run_scores)
    if total >= RATING_S_THRESHOLD:
        return "S"
    elif total >= RATING_A_THRESHOLD:
        return "A"
    elif total >= RATING_B_THRESHOLD:
        return "B"
    return "C"


# ── Per-encounter data structures ─────────────────────────────────────────

@dataclass
class TurnSnapshot:
    turn: int
    player_hp: int
    enemy_hp: int
    player_intents: tuple[int, int, int]  # (damage, shield, heal) BEFORE resolution
    enemy_intents: tuple[int, int, int]


@dataclass
class GameResult:
    winner: str          # "player" | "enemy" | "stalemate"
    turns: int
    player_hp_final: int
    enemy_hp_final: int
    hp_history: list[TurnSnapshot] = field(default_factory=list)


@dataclass
class RunResult:
    """Result of a full 4-encounter run."""
    encounter_results: list[GameResult]  # up to 4 entries (last may be a loss)
    scores: list[float]                  # one per won encounter
    defeated_at: int                     # -1 if run completed, else encounter index
    rating: str
    total_score: float
    roster: list[EnemySpec]


# ── Single-encounter game ─────────────────────────────────────────────────

class Game:
    """
    Full game loop for a single encounter – mirrors TurnManager in GDScript.

    Both sides are controlled by GreedyAI for simulation purposes.
    Each call to run() is independent: fresh Actors, fresh shuffled decks.
    """

    def __init__(self, record_history: bool = False) -> None:
        self._ai = GreedyAI()
        self._resolver = CombatResolver()
        self._record_history = record_history
        # Load decks once – they're immutable Card lists
        self._player_deck = load_player_deck()
        self._enemy_deck = load_deck("deck_enemy.json")

    def run(self) -> GameResult:
        return self._run_encounter(self._player_deck, self._enemy_deck, ENEMY_MAX_HP, ENEMY_MAX_ENERGY)

    def _run_encounter(
        self,
        player_deck_cards: list,
        enemy_deck_cards: list,
        enemy_hp: int,
        enemy_energy: int,
    ) -> GameResult:
        player = Actor(
            name="Player",
            max_hp=PLAYER_MAX_HP,
            max_energy=PLAYER_MAX_ENERGY,
            starting_deck=player_deck_cards,
        )
        enemy = Actor(
            name="Enemy",
            max_hp=enemy_hp,
            max_energy=enemy_energy,
            starting_deck=enemy_deck_cards,
        )

        history: list[TurnSnapshot] = []

        for turn in range(1, MAX_TURNS + 1):
            # ── STATUS_START: POISON damage (enemy first) ──────────────────
            game_over = _apply_poison_damage(player, enemy)
            if game_over is not None:
                return GameResult(
                    winner=game_over,
                    turns=turn,
                    player_hp_final=player.hp,
                    enemy_hp_final=enemy.hp,
                    hp_history=history,
                )

            # ── ENEMY_DRAW: reset intents, apply FREEZE/HASTE, draw cards ─
            enemy.intent_damage = 0
            enemy.intent_shield = 0
            enemy.intent_heal = 0
            enemy.energy = enemy.max_energy
            _apply_freeze_haste(enemy)
            enemy.draw_cards(CARDS_PER_DRAW)

            # ── ENEMY_PLAY: AI plays cards, applies status effects ─────────
            played_by_enemy = self._ai.play_turn(enemy)
            for card in played_by_enemy:
                _apply_card_status(card, caster=enemy, opponent=player)

            # ── PLAYER_DRAW: reset intents, apply FREEZE/HASTE, draw cards ─
            player.intent_damage = 0
            player.intent_shield = 0
            player.intent_heal = 0
            player.energy = player.max_energy
            _apply_freeze_haste(player)
            player.draw_cards(CARDS_PER_DRAW)

            # ── PLAYER_PLAY: AI plays cards, applies status effects ────────
            played_by_player = self._ai.play_turn(player)
            for card in played_by_player:
                _apply_card_status(card, caster=player, opponent=enemy)

            if self._record_history:
                history.append(
                    TurnSnapshot(
                        turn=turn,
                        player_hp=player.hp,
                        enemy_hp=enemy.hp,
                        player_intents=(player.intent_damage, player.intent_shield, player.intent_heal),
                        enemy_intents=(enemy.intent_damage, enemy.intent_shield, enemy.intent_heal),
                    )
                )

            # ── RESOLUTION ─────────────────────────────────────────────────
            result = self._resolver.resolve(player, enemy)
            if not result.continues:
                winner = "player" if result.player_won else "enemy"
                return GameResult(
                    winner=winner,
                    turns=turn,
                    player_hp_final=player.hp,
                    enemy_hp_final=enemy.hp,
                    hp_history=history,
                )

            # ── TURN_END: BURN damage, then BLESSED, then ready next turn ──
            game_over = _apply_burn_damage(player, enemy)
            if game_over is not None:
                return GameResult(
                    winner=game_over,
                    turns=turn,
                    player_hp_final=player.hp,
                    enemy_hp_final=enemy.hp,
                    hp_history=history,
                )
            _apply_blessed_effects(player)
            _apply_blessed_effects(enemy)

        return GameResult(
            winner="stalemate",
            turns=MAX_TURNS,
            player_hp_final=player.hp,
            enemy_hp_final=enemy.hp,
            hp_history=history,
        )


# ── Status effect helpers (mirrors TurnManager logic) ────────────────────

def _apply_freeze_haste(actor: "Actor") -> None:
    """Apply FREEZE (-1 energy) or HASTE (+1 energy) at the start of actor's draw phase."""
    if actor.has_status("freeze"):
        actor.energy = max(0, actor.energy - 1)
        actor.clear_status("freeze")
    if actor.has_status("haste"):
        actor.energy += 1  # intentionally can exceed max
        actor.clear_status("haste")


def _apply_card_status(card: "Card", caster: "Actor", opponent: "Actor") -> None:
    """Apply status effect from a played card to the correct target."""
    if not card.status_effect:
        return
    target = opponent if card.status_target == "opponent" else caster
    target.apply_status(card.status_effect)


def _apply_poison_damage(player: "Actor", enemy: "Actor") -> "str | None":
    """
    Apply poison at turn start. Enemy first, then player.
    Returns winner string if a death occurs, else None.
    """
    if enemy.has_status("poison"):
        enemy.status_effects["poison"] -= 1
        if enemy.has_status("blessed"):
            enemy.hp = max(1, enemy.hp - 1)
        else:
            enemy.take_damage(1)
            if not enemy.is_alive():
                return "player"

    if player.has_status("poison"):
        player.status_effects["poison"] -= 1
        if player.has_status("blessed"):
            player.hp = max(1, player.hp - 1)
        else:
            player.take_damage(1)
            if not player.is_alive():
                return "enemy"

    return None


def _apply_burn_damage(player: "Actor", enemy: "Actor") -> "str | None":
    """
    Apply burn at turn end. Enemy first, then player.
    Returns winner string if a death occurs, else None.
    """
    if enemy.has_status("burn"):
        enemy.status_effects["burn"] -= 1
        if enemy.has_status("blessed"):
            enemy.hp = max(1, enemy.hp - 1)
        else:
            enemy.take_damage(1)
            if not enemy.is_alive():
                return "player"

    if player.has_status("burn"):
        player.status_effects["burn"] -= 1
        if player.has_status("blessed"):
            player.hp = max(1, player.hp - 1)
        else:
            player.take_damage(1)
            if not player.is_alive():
                return "enemy"

    return None


def _apply_blessed_effects(actor: "Actor") -> None:
    """Apply blessed: +1 HP, cure burn/poison, remove blessed."""
    if actor.has_status("blessed"):
        actor.heal_hp(1)
        actor.clear_status("burn")
        actor.clear_status("poison")
        actor.clear_status("blessed")


# ── Multi-encounter run ───────────────────────────────────────────────────

class RunGame:
    """
    Simulates a full 4-encounter run: 2 base → 1 elite → boss.
    Mirrors GameManager.start_run / complete_encounter / fail_encounter.
    Player starts each encounter at full HP.
    """

    def __init__(self, record_history: bool = False) -> None:
        self._game = Game(record_history=record_history)
        self._player_deck = load_player_deck()

    def run(self) -> RunResult:
        roster = _build_roster()
        scores: list[float] = []
        results: list[GameResult] = []
        defeated_at = -1

        for i, spec in enumerate(roster):
            enemy_deck = load_deck(spec.deck_file)
            result = self._game._run_encounter(
                self._player_deck, enemy_deck, spec.max_hp, spec.max_energy
            )
            results.append(result)

            if result.winner == "player":
                score = _calculate_score(spec.base_score, result.player_hp_final, result.turns)
                scores.append(score)
            else:
                # Defeat or stalemate ends the run
                defeated_at = i
                break

        total = sum(scores)
        rating = _run_rating(scores, defeated_at)
        return RunResult(
            encounter_results=results,
            scores=scores,
            defeated_at=defeated_at,
            rating=rating,
            total_score=total,
            roster=roster,
        )

