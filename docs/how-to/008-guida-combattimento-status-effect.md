# Guida completa: combattimento e status effect

Questa guida descrive come funziona il combattimento del progetto e dove intervenire se vuoi cambiarne il comportamento.

## 1. File principali del combattimento

### Struttura e UI
- `scenes/board/game_board.tscn`
- `scenes/board/actor_panel.tscn`
- `scenes/board/intent_panel.tscn`
- `scenes/board/hand_area.tscn`
- `scripts/screens/game_screen.gd`
- `scripts/ui/actor_panel_ui.gd`
- `scripts/ui/intent_panel_ui.gd`
- `scripts/ui/hand_ui.gd`
- `scripts/ui/card_ui.gd`

### Logica di stato e risoluzione
- `scripts/data/actor_data.gd`
- `scripts/systems/turn_manager.gd`
- `scripts/systems/combat_resolver.gd`
- `scripts/systems/deck_manager.gd`
- `scripts/systems/animation_manager.gd`
- `scripts/autoload/game_manager.gd`

## 2. Flusso reale del combattimento

Stati principali del `TurnManager`:
- `STATUS_START`
- `ENEMY_DRAW`
- `ENEMY_PLAY`
- `PLAYER_DRAW`
- `PLAYER_PLAY`
- `RESOLUTION`
- `TURN_END`
- `GAME_OVER`

Punto di controllo principale:
- `scripts/systems/turn_manager.gd`

Se vuoi cambiare quando succede qualcosa, quasi sempre parti da qui.

## 3. Dove si decide cosa succede in ogni fase

### Inizio turno
- `TurnManager._execute_status_start()`
- qui parte il danno da `poison`

### Pesca nemico
- `TurnManager._execute_enemy_draw()`
- reset intenti nemico
- applicazione `freeze` / `haste`
- pesca carte

### Giocata nemico
- `TurnManager._execute_enemy_play()`
- uso AI nemico
- applicazione status effect delle carte giocate

### Pesca player
- `TurnManager._execute_player_draw()`
- reset intenti player
- applicazione `freeze` / `haste`
- pesca carte

### Risoluzione
- `CombatResolver.resolve()`
- guarigione
- attacco player
- attacco enemy

### Fine turno
- `TurnManager._execute_turn_end()`
- danno da `burn`
- effetto `blessed`
- reset energia

## 4. Dove vivono HP, energia, mano, mazzo, cimitero, intenti e status

File:
- `scripts/data/actor_data.gd`

Contiene:
- `hp`
- `max_hp`
- `energy`
- `max_energy`
- `deck`
- `hand`
- `graveyard`
- `current_intents`
- `status_effects`

Se vuoi cambiare la struttura dati dell'attore, questo e il file centrale.

## 5. Status effect attuali

Supportati:
- `burn`
- `poison`
- `freeze`
- `haste`
- `blessed`

### Dove sono definiti e gestiti

#### Dato e durata
- `ActorData.status_effects`
- `ActorData.apply_status()`

#### Applicazione da carta
- `TurnManager._apply_card_status_effect()`

#### Effetto a inizio/fine turno
- `TurnManager._apply_poison_damage()`
- `TurnManager._apply_burn_damage()`
- `TurnManager._apply_freeze_haste()`
- `TurnManager._apply_blessed_effects()`

#### Visualizzazione UI
- `scripts/ui/card_ui.gd` -> simbolo carta
- `scripts/ui/actor_panel_ui.gd` -> stato attore attivo
- `scripts/screens/game_screen.gd` -> testo tooltip

## 6. Come aggiungere un nuovo status effect

Questa modifica e trasversale. Non basta aggiungere il valore nel JSON.

Devi toccare almeno:

1. `scripts/data/card_data.gd`
   A livello di schema dati e descrizione testuale.

2. `scripts/data/deck_loader.gd`
   Per validare il nuovo valore in input.

3. `scripts/data/actor_data.gd`
   Per aggiungere la chiave dentro `status_effects` e l'eventuale durata iniziale.

4. `scripts/systems/turn_manager.gd`
   Per decidere quando lo stato si applica, quando scade e che effetto ha.

5. `scripts/ui/card_ui.gd`
   Per simbolo o resa visiva sulla carta.

6. `scripts/ui/actor_panel_ui.gd`
   Per visualizzare lo stato sul pannello attore.

7. `scripts/screens/game_screen.gd`
   Per tooltip combattimento.

8. `scripts/screens/card_selection_screen.gd`
   Per tooltip selezione e cue visiva in selezione carte.

## 7. Come cambiare l'ordine di risoluzione del combattimento

File:
- `scripts/systems/combat_resolver.gd`

Ordine attuale:
1. guarigione
2. attacco player
3. attacco enemy

Se vuoi cambiare questo ordine, tocchi direttamente `CombatResolver.resolve()`.

Attenzione:
- cambiando l'ordine cambi il bilanciamento del gioco
- potresti dover aggiornare anche i playtest Python

## 8. Come cambiare il layout del combattimento

### Struttura del board

File:
- `scenes/board/game_board.tscn`

Qui cambi:
- ordine dei blocchi
- presenza action bar
- presenza background
- posizione intenti rispetto a mani e pannelli

### Dimensioni responsive

File:
- `scripts/screens/game_screen.gd`

Qui cambi:
- `panel_height`
- `hand_card_width`
- `hand_card_height`
- `hand_height`
- `intent_height`
- dimensioni tooltip

## 9. Come cambiare le animazioni del combattimento

### Animazioni carta

File:
- `scripts/ui/card_ui.gd`
- `scripts/systems/animation_manager.gd`

`AnimationManager` contiene:
- `animate_draw_sequence()`
- `animate_card_played()`
- `animate_discard()`
- `animate_damage_received()`
- `animate_healed()`
- `animate_status_damage()`

### Velocita globale

File:
- `scripts/autoload/config.gd`

Campo:
- `animation_speed`

## 10. Desktop vs mobile nel combattimento

### Desktop
- tende ad avere troppo spazio laterale o verticale se non usi bene il board
- puoi permetterti carte piu larghe
- tooltip a hover o vicino al mouse e accettabile

### Mobile
- richiede hit area piu grandi
- richiede tooltip con trigger esplicito
- soffre layout troppo alti e troppo testo contemporaneo

Punti da guardare:
- `game_screen.gd`
- `card_ui.gd`
- `hand_ui.gd`

## 11. Checklist per debug rapido del combattimento

Se qualcosa non va:

### HP o energia non aggiornati
- controlla `ActorData`
- controlla `_refresh_actor_panels()` in `game_screen.gd`
- controlla `actor_panel_ui.gd`

### Intenti sbagliati
- controlla `ActorData.current_intents`
- controlla `add_card_intents()`
- controlla `IntentPanelUI.update_intents()`

### Status effect non visibile o non applicato
- controlla `TurnManager._apply_card_status_effect()`
- controlla `ActorData.apply_status()`
- controlla tooltip e simboli UI

### Carte non si vedono bene
- controlla `game_screen.gd` per size mano
- controlla `card_ui.gd` per layout interno
