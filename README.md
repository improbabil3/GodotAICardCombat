# GodotAICardCombat

Turn-based sci-fi card combat prototype built with Godot 4.7

Repository: https://github.com/improbabil3/GodotAICardCombat

## Overview

This project is an alpha prototype of a turn-based card combat game implemented in Godot (GDScript). It contains game logic, UI, simple enemy AI and animations—suitable for demos and iteration.

## Features

- Turn FSM (enemy draw/play → player draw/play → resolution)
- Card intents system (damage / shield / heal)
- Animated enemy turn with per-card playback
- Configurable UI and feature flags

## Requirements

- Godot Engine 4.7 (or compatible 4.x)

## Run locally

1. Open Godot and select this project folder (open `project.godot`).
2. Press `Play` (F5) in the editor to run the main scene.

Alternatively, from command line (headless check):

```bash
godot --version
# or validate project path
godot --path . --version
```

## Release workflow

We include simple release scripts under `scripts/`:

- `scripts/release.sh` — create tag, push and optionally create a GitHub release (uses `gh` CLI if available)
- `scripts/release.ps1` — Windows PowerShell equivalent

Example (Unix):

```bash
# create a release tag v0.1.0 and push
bash scripts/release.sh 0.1.0
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to open issues and PRs.

## License

MIT — see [LICENSE](LICENSE)# Galactic Clash — Alpha

Gioco di carte a turni sci-fi realizzato in **Godot 4.7 / GDScript**.

---

## Requisiti

| Tool | Versione |
|------|----------|
| Godot | 4.3+ (testato su 4.7) |
| OS | Windows / macOS / Linux |

---

## Avvio rapido

1. Aprire **Godot Engine**
2. **Import** → Selezionare questa cartella (`GodotPlayTest/`)
3. Premere **Run** (F5) o **Play Selected Scene** su `scenes/screens/title_screen.tscn`

---

## Struttura del progetto

```
GodotPlayTest/
├── assets/
│   └── icon.svg                   # Icona del progetto
├── data/
│   ├── deck_player.json           # Mazzo Omega Pilot (20 carte)
│   └── deck_enemy.json            # Mazzo Nexus Warlord (20 carte)
├── scenes/
│   ├── board/
│   │   ├── game_board.tscn        # Layout principale del campo di battaglia
│   │   ├── actor_panel.tscn       # Pannello HP/energia attore
│   │   ├── hand_area.tscn         # Area mazzo + mano + cimitero
│   │   └── intent_panel.tscn      # Pannello intenti accumulati
│   ├── card/
│   │   └── card.tscn              # Card UI con texture procedurale
│   └── screens/
│       ├── title_screen.tscn      # Menu principale
│       ├── game_screen.tscn       # Wrapper battaglia (istanza game_board)
│       ├── victory_screen.tscn    # Schermata vittoria
│       └── defeat_screen.tscn     # Schermata sconfitta
└── scripts/
    ├── autoload/
    │   ├── config.gd              # Feature flags (show_enemy_hand, animate_enemy_turn…)
    │   ├── debug_logger.gd        # Log colorati via print_rich()
    │   └── game_manager.gd        # Singleton globale: stato partita + transizioni
    ├── data/
    │   ├── card_data.gd           # Resource: card_name, damage, shield, heal, energy_cost
    │   ├── actor_data.gd          # RefCounted: hp, hand[], deck[], intents
    │   └── deck_loader.gd         # Loader + validatore JSON (esattamente 20 carte)
    ├── systems/
    │   ├── deck_manager.gd        # draw_cards, discard, shuffle (Fisher-Yates)
    │   ├── combat_resolver.gd     # Fase heal → attacco player → attacco enemy
    │   ├── enemy_ai.gd            # AI Greedy: max danno; HP<30% → cura/scudo prima
    │   ├── turn_manager.gd        # FSM: ENEMY_DRAW→ENEMY_PLAY→PLAYER_DRAW→PLAYER_PLAY→…
    │   └── animation_manager.gd   # Tween centralizzati (pesca, giocata, scarto, flash HP)
    └── ui/
        ├── card_ui.gd             # Hover, click, texture procedurale, fly_to/animate_draw
        ├── hand_ui.gd             # Gestione nodi CardUI, map CardData→CardUI
        ├── actor_panel_ui.gd      # HP bar animata, flash colore, shake danno, portrait
        └── intent_panel_ui.gd     # Contatori intenti, flash per carta giocata
```

---

## Meccaniche di gioco

### Turno
```
ENEMY_DRAW → ENEMY_PLAY → PLAYER_DRAW → PLAYER_PLAY → RESOLUTION → TURN_END → (loop)
```

- **ENEMY_DRAW**: il nemico pesca 5 carte e le gioca automaticamente (AI Greedy)
- **PLAYER_DRAW**: il giocatore pesca 5 carte
- **PLAYER_PLAY**: il giocatore gioca carte (costo energia) e preme "Fine Turno"
- **RESOLUTION**: guarigione → player attacca → enemy attacca

### Risoluzione combattimento
1. Guarigione: `hp = min(max_hp, hp + heal)`
2. Attacco player su enemy: `danno = max(0, player_damage - enemy_shield)`
   - Se enemy muore → **VITTORIA** (salto step 3)
3. Attacco enemy su player: `danno = max(0, enemy_damage - player_shield)`
   - Se player muore → **SCONFITTA**

### AI Greedy
- Gioca carta con priorità massima in base a HP:
  - HP > 30%: `damage > shield > heal`
  - HP ≤ 30%: `heal > shield > damage`

---

## Feature flags (`scripts/autoload/config.gd`)

| Flag | Default | Descrizione |
|------|---------|-------------|
| `show_enemy_hand` | `true` | Mostra le carte del nemico |
| `accumulate_energy` | `false` | Energia si accumula tra turni |
| `animation_speed` | `1.0` | Moltiplicatore velocità animazioni (0.0 = no animazioni) |
| `card_draw_delay` | `0.15` | Delay secondi tra carte pescate |
| `animate_enemy_turn` | `true` | Anima il turno nemico |

---

## Mazzi JSON

I mazzi si trovano in `data/`. Ogni mazzo deve avere **esattamente 20 carte**.

```json
{
  "deck_name": "Nome Mazzo",
  "cards": [
    {
      "card_name": "Nome Carta",
      "damage": 0,
      "shield": 0,
      "heal": 0,
      "energy_cost": 1,
      "image_key": "chiave_immagine"
    }
  ]
}
```

**Vincoli di validazione**:
- `damage` ∈ [0, 3]
- `shield` ∈ [0, 3]
- `heal` ∈ [0, 2]
- `energy_cost` ∈ [0, 2]
- Almeno 1 effetto attivo per carta (damage + shield + heal ≥ 1)

---

## Modifiche rapide

**Cambiare difficoltà AI**: modificare `SURVIVAL_HP_RATIO` in `scripts/systems/enemy_ai.gd`

**Aggiungere carte**: modificare i file JSON in `data/` (rispettare esattamente 20 carte)

**Disabilitare animazioni**: impostare `Config.animation_speed = 0.0` in `config.gd`

**Mostrare/nascondere mano nemico**: impostare `Config.show_enemy_hand = false` in `config.gd`
