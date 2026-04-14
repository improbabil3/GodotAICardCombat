---
applyTo: '**'
---

# GodotAICardCombat — Istruzioni Codebase

Gioco di carte a turni sci-fi **Galactic Clash**, realizzato in **Godot 4.7 / GDScript**.

---

## Architettura generale

La struttura è divisa in cinque layer distinti. Non mescolarli.

| Layer | Cartella | Base class | Scopo |
|-------|----------|------------|-------|
| **Data** | `scripts/data/` | `Resource` / `RefCounted` | Stato puro, nessuna logica di scena |
| **Systems** | `scripts/systems/` | `RefCounted` | Logica di gioco stateless o quasi-stateless |
| **Autoloads** | `scripts/autoload/` | `Node` | Singleton globali (Config, GameManager, DebugLogger, ThemeBuilder) |
| **Screens** | `scripts/screens/` | `Control` | Orchestrano sistemi e UI per ogni schermata |
| **UI** | `scripts/ui/` | `Control` / `Node` | Componenti visivi riutilizzabili |

Regola critica: i layer **Data** e **Systems** non devono mai dipendere da nodi di scena. Non chiamare `get_tree()`, `get_node()` o `$` da `RefCounted`. I segnali sono l'unico punto di contatto verso l'alto.

---

## File e responsabilità chiave

### Autoloads (singleton)
- **`Config`** — tutti i valori modificabili (HP, energia, feature flag, velocità animazioni). Nessun altro script deve contenere costanti di bilanciamento hardcoded.
- **`DebugLogger`** — unico punto di log. Non usare mai `print()` diretto.
- **`GameManager`** — transizioni di scena, riferimenti attivi a `ActorData` player/enemy, contatore turni.
- **`ThemeBuilder`** — costruisce il tema sci-fi e lo applica all'albero.

### Data
- **`ActorData`** (`extends RefCounted`) — stato di un attore: `hp`, `max_hp`, `energy`, `max_energy`, `deck[]`, `hand[]`, `graveyard[]`, `current_intents{}`. Un'istanza per player, una per enemy.
- **`CardData`** (`extends Resource`) — dati immutabili di una carta: `card_name`, `damage`, `shield`, `heal`, `energy_cost`, `image_key`.
- **`DeckLoader`** — carica e valida JSON da `data/`. Richiede esattamente **20 carte** per mazzo.

### Systems
- **`TurnManager`** — FSM dei turni. Emette segnali; non tocca mai la UI direttamente.
- **`CombatResolver`** — risolve gli effetti in ordine: guarigione → attacco player → attacco enemy.
- **`DeckManager`** — operazioni su mazzo/mano/cimitero (draw, discard, shuffle Fisher-Yates). Tutti i metodi sono `static`.
- **`EnemyAI`** — strategia greedy con modalità aggressiva / sopravvivenza (soglia `SURVIVAL_HP_RATIO = 0.30`).
- **`AnimationManager`** — centralizza tutti i Tween (pesca, giocata, scarto, flash HP).

### UI
- **`CardUI`** — hover, click, texture procedurale, `fly_to` / `animate_draw`.
- **`HandUI`** — gestisce i nodi `CardUI` in mano; emette `card_played_from_hand`.
- **`ActorPanelUI`** — HP bar animata, shake al danno, portrait.
- **`IntentPanelUI`** — contatori intenti, flash per carta giocata.

---

## Flusso turno (FSM)

```
ENEMY_DRAW → ENEMY_PLAY → PLAYER_DRAW → PLAYER_PLAY → RESOLUTION → TURN_END → (loop)
```

Ogni transizione avviene tramite `TurnManager.advance_state()`. Lo stato `GAME_OVER` è terminale. Non aggiungere stati senza aggiornare sia il `match` in `advance_state()` sia il commento di intestazione del file.

### Risoluzione effetti (ordine obbligatorio)
1. **Guarigione** — entrambi gli attori recuperano HP (`min(hp + heal, max_hp)`)
2. **Attacco player** — `dg = max(0, player.damage - enemy.shield)` → se il nemico muore, vittoria immediata, skip step 3
3. **Attacco enemy** — `dn = max(0, enemy.damage - player.shield)` → se il player muore, sconfitta immediata

---

## Convenzioni GDScript

### Struttura file
```gdscript
## NomeClasse — descrizione breve una riga
##
## Dettagli estesi se necessari.

class_name NomeClasse
extends RefCounted  # o Node, Control, Resource

# ── Segnali ──────────────────────────────────────────────────────────────────
signal nome_evento(argomento: TipoArgomento)

# ── Costanti ─────────────────────────────────────────────────────────────────
const NOME_COSTANTE := valore

# ── Export / variabili pubbliche ─────────────────────────────────────────────
@export var valore_pubblico: int = 0

# ── Variabili private ────────────────────────────────────────────────────────
var _variabile_privata: String = ""

# ── Metodi pubblici ──────────────────────────────────────────────────────────
func metodo_pubblico() -> void:
    pass

# ── Metodi privati ───────────────────────────────────────────────────────────
func _metodo_privato() -> void:
    pass
```

### Regole di stile
- **`##`** per doc comment su ogni classe e ogni variabile/metodo pubblico.
- **`#`** per commenti inline.
- Separatori di sezione: `# ── Nome ──────────────────────────────────────────`
- Variabili private: prefisso `_`.
- Typed arrays: `Array[CardData]`, `Array[TurnManager.State]`, mai `Array` non tipizzato.
- Tipo di ritorno sempre dichiarato: `func foo() -> void`, `func bar() -> int`.
- `@onready` solo nei nodi di scena (`Node`, `Control`). Mai in `RefCounted`.
- Usare `match` invece di catene `if/elif` per stati e enum.
- `static func` per operazioni stateless sui dati (vedi `DeckManager`).

### Regola responsive obbligatoria
- Per qualunque schermata o componente responsive, separare sempre il layout **desktop** e il layout **mobile** in rami o funzioni distinte (`_apply_desktop_layout`, `_apply_mobile_layout`, ecc.).
- Non mantenere formule miste desktop/mobile nello stesso blocco di layout: rende facile rompere un caso mentre si sistema l'altro.
- Quando si corregge un problema visivo specifico a uno dei due ambienti, intervenire prima solo sul ramo interessato e verificare che l'altro resti invariato.

---

## Debug logging

Usare **sempre** `DebugLogger` con la categoria corretta. Mai `print()`.

| Metodo | Colore | Uso |
|--------|--------|-----|
| `log_damage(msg)` | rosso | danni subiti/inflitti |
| `log_shield(msg)` | blu | scudo applicato |
| `log_heal(msg)` | verde | guarigione |
| `log_turn(msg)` | giallo | inizio/fine turno, transizioni FSM |
| `log_card(msg)` | cyan | pesca, giocata, scarto carte |
| `log_ai(msg)` | magenta | decisioni EnemyAI |
| `log_system(msg)` | arancione | eventi di sistema / inizializzazione |
| `log_error(msg)` | rosso bold | errori non fatali |
| `log_resolution(msg)` | gold bold | fasi della risoluzione combattimento |
| `separator()` | grigio | linea divisoria prima/dopo blocchi di risoluzione |

---

## Feature flags e configurazione

Tutti i valori di gioco vivono in `scripts/autoload/config.gd` come `@export`. Non inserire mai costanti di bilanciamento in altri file. Le feature flag rilevanti sono:

| Flag | Default | Effetto |
|------|---------|---------|
| `show_enemy_hand` | `true` | Mostra/nasconde la mano del nemico |
| `show_enemy_card_details` | `false` | Mostra/nasconde i dettagli delle carte nemico |
| `accumulate_energy` | `false` | Energia residua si accumula al turno successivo |
| `animation_speed` | `1.0` | Moltiplicatore velocità (0.0 = istantaneo) |
| `animate_enemy_turn` | `true` | Anima turno nemico carta per carta |
| `card_draw_delay` | `0.15` | Delay secondi tra pescate |
| `enemy_draw_pause` | `1.0` | Pausa dopo pescata nemico |
| `enemy_card_play_delay` | `0.7` | Delay tra carte nemico |

---

## Vincoli carte (CardData)

| Campo | Range | Note |
|-------|-------|------|
| `damage` | [0, 3] | |
| `shield` | [0, 3] | |
| `heal` | [0, 2] | |
| `energy_cost` | [0, 2] | |
| effetti attivi | ≥ 1 | `damage + shield + heal ≥ 1` |
| effetti attivi | ≤ 2 | combinazioni valide: D, S, G, D+S, D+G, S+G |

---

## Formato JSON mazzi (`data/`)

```json
{
  "deck_name": "Nome Mazzo",
  "cards": [
    {
      "card_name": "Nome",
      "damage": 0,
      "shield": 0,
      "heal": 0,
      "energy_cost": 1,
      "image_key": "chiave"
    }
  ]
}
```

- Ogni mazzo deve contenere **esattamente 20 carte**.
- `DeckLoader` valida il formato al caricamento e logga errori con `DebugLogger.log_error`.

---

## Python playtest (`playtests/`)

La cartella `playtests/` contiene una simulazione Python che **deve specchiare fedelmente** la logica GDScript:
- Stesse costanti di bilanciamento di `config.gd` (`PLAYER_MAX_HP = 20`, `CARDS_PER_DRAW = 5`, ecc.)
- Stesso ordine di risoluzione di `CombatResolver`
- Stessa strategia greedy di `EnemyAI` (`SURVIVAL_HP_RATIO = 0.30`)
- Quando si modifica la logica GDScript, aggiornare il corrispondente modulo Python.

Avvio: `python playtests/run_playtests.py --games 10000`

---

## Pattern e anti-pattern

### Da fare
- Emettere segnali da `TurnManager` e ascoltarli in `GameScreen` per aggiornare la UI.
- Usare `call_deferred` quando si cambiano scene o si accede all'albero subito dopo `_ready`.
- Creare `ActorData` in `GameScreen._setup_actors()` e passarli a `GameManager` per esporli alle schermate di esito.
- Animare con `AnimationManager` (Tween centralizzati), non con Tween sparsi nei nodi UI.
- Bloccare l'input durante le animazioni con il flag `_animating` in `GameScreen`.

### Da non fare
- Non usare `print()` — solo `DebugLogger`.
- Non estendere `Node` per dati puri — usare `RefCounted`.
- Non accedere a `get_tree()` da `RefCounted`.
- Non hardcodare HP, energia, numero di carte o soglie AI fuori da `config.gd`.
- Non aggiungere logica di combattimento in script UI.
- Non modificare `ActorData.current_intents` direttamente — usare `actor.add_card_intents(card)`.
- Non chiamare `DeckManager.draw_cards` senza verificare che l'attore abbia carte o cimitero disponibili (il metodo gestisce il riciclo, ma logga errori se entrambi sono vuoti).

---

## Scene principali

| Scena | Script | Ruolo |
|-------|--------|-------|
| `scenes/screens/title_screen.tscn` | `title_screen.gd` | Menu iniziale |
| `scenes/screens/game_screen.tscn` | `game_screen.gd` | Wrapper battaglia (istanza `game_board.tscn`) |
| `scenes/screens/victory_screen.tscn` | `victory_screen.gd` | Risultato vittoria |
| `scenes/screens/defeat_screen.tscn` | `defeat_screen.gd` | Risultato sconfitta |
| `scenes/board/game_board.tscn` | — | Layout principale campo di battaglia |
| `scenes/card/card.tscn` | `card_ui.gd` | Carta UI istanziata da `HandUI` |

Le transizioni di scena passano sempre per `GameManager.start_game()`, `GameManager.end_game(bool)`, `GameManager.return_to_menu()`.
