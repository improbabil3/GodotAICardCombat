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
3. Premere **Run** (F5) sia **Play Selected Scene** su `scenes/screens/title_screen.tscn`

Il flow di gioco:
- **Title Screen** → Pulsante "Gioca" → **Character Selection Screen** (carousel 3 personaggi)
- Selezionare personaggio → **Card Selection Screen** (scegli 10 di 20 carte specifiche)
- Conferma mazzo → **Game Screen** (combattimento)
- Vittoria/Sconfitta → Ritorna a Character Selection

---

## Nuovi Personaggi (Multi-Character System)

Nel gioco ora sono disponibili **3 personaggi giocabili**, ciascuno con un **pool di 20 carte specifiche** da cui il giocatore seleziona 10. Le restanti 10 carte del mazzo di combattimento vengono scelte casualmente dal *base deck* generico.

### Personaggi

| Personaggio | File Specifiche | Strategia | Descrizione |
|-------------|-----------------|-----------|-------------|
| **Omega Pilot** | `data/deck_omega_pilot_specific.json` | Equilibrato | Pilota potenziato con attacchi e difesa moderati |
| **Phoenix Guardian** | `data/deck_phoenix_guardian_specific.json` | Difesa/Guarigione | Paladino specializzato in scudi e cura |
| **Apex Striker** | `data/deck_apex_striker_specific.json` | Aggressivo | Guerriero con focus su attacchi potenti |

### Deck Structure

Ogni personaggio ha:
- **20 carte specifiche** (in `data/deck_*_specific.json`)
- Il giocatore **sceglie 10** dalla griglia di selezione
- Sistema aggiunge automaticamente **10 carte casuali dal base deck** (`data/deck_player.json`)
- **Total: 20 carte** per il combattimento

---

## Struttura del progetto

```
GodotPlayTest/
├── assets/
│   └── icon.svg                           # Icona del progetto
├── data/
│   ├── deck_player.json                   # Mazzo base generico (20 carte)
│   ├── deck_enemy.json                    # Mazzo nemico (20 carte)
│   ├── deck_omega_pilot_specific.json     # Pool 20 carte Omega Pilot
│   ├── deck_phoenix_guardian_specific.json # Pool 20 carte Phoenix Guardian
│   └── deck_apex_striker_specific.json    # Pool 20 carte Apex Striker
├── scenes/
│   ├── board/
│   │   ├── game_board.tscn                # Layout campo di battaglia
│   │   ├── actor_panel.tscn               # Pannello HP/energia attore
│   │   ├── hand_area.tscn                 # Area mazzo + mano + cimitero
│   │   └── intent_panel.tscn              # Pannello intenti accumulate
│   ├── card/
│   │   └── card.tscn                      # Card UI con texture procedurale
│   └── screens/
│       ├── title_screen.tscn              # Menu principale
│       ├── character_selection_screen.tscn # Selezione personaggio (carousel)
│       ├── card_selection_screen.tscn     # Selezione 10 di 20 carte carattere
│       ├── game_screen.tscn               # Wrapper battaglia (istanza game_board)
│       ├── victory_screen.tscn            # Schermata vittoria
│       └── defeat_screen.tscn             # Schermata sconfitta
└── scripts/
    ├── autoload/
    │   ├── config.gd              # Feature flags (show_enemy_hand, animate_enemy_turn…)
    │   ├── debug_logger.gd        # Log colorati via print_rich()
    │   └── game_manager.gd        # Singleton globale: stato partita + transizioni
    ├── data/
    │   ├── card_data.gd                # Resource: card_name, damage, shield, heal, energy_cost
    │   ├── actor_data.gd               # RefCounted: hp, hand[], deck[], intents
    │   ├── character_data.gd           # RefCounted: nome, descrizione, specific_cards[] (20 carte)
    │   ├── deck_loader.gd              # Loader + validatore JSON (esattamente 20 carte)
    │   └── character_manager.gd        # Static: gestisce 3 personaggi + selezione attuale
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

---

## Documentazione Tecnica & Lesson Learned

Consultare i documenti di approfondimento per capire le decisioni architetturali e evitare errori comuni:

- **[`docs/001-game-description.md`](docs/001-game-description.md)** — descrizione meccaniche di gioco
- **[`docs/002-multiple-characters.md`](docs/002-multiple-characters.md)** — design del sistema multi-personaggio
- **[`docs/003-godot-layout-responsive.md`](docs/003-godot-layout-responsive.md)** — layout responsive in Godot 4.7 — **lezioni apprese**, errori comuni e best practices per container, anchor e dynamic sizing

---

## Contributing

Se contribuisci, leggi attentamente:
1. [`.github/instructions/codebase.instructions.md`](.github/instructions/codebase.instructions.md) — architettura e convenzioni di codice
2. [`.github/instructions/voices.instructions.md`](.github/instructions/voices.instructions.md) — tone e feedback critico
3. Rispettare la struttura a 5 layer (Data / Systems / Autoloads / Screens / UI)
4. Non mescolare logica di dati con nodi di scena
