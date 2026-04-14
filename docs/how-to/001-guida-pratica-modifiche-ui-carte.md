# Guida pratica: modificare carte, layout, font e tooltip

Questa guida e pensata per lavorare sul progetto senza dover ogni volta riaprire tutto il codice a tentativi.

Obiettivo:
- capire dove modificare una carta
- capire dove modificare il layout delle schermate
- capire dove cambiare font, dimensioni, colori e tooltip
- capire il flusso tra scena `.tscn` e script `.gd`

## 1. Regola base del progetto

Per quasi ogni modifica UI devi guardare due cose:

1. il file scena `.tscn`
   Qui trovi nodi, gerarchia, ancore, contenitori, size flags, font override e dimensioni minime.

2. il file script `.gd`
   Qui trovi logica, refresh runtime, tooltip, resize, segnali, comportamento touch/mouse e calcoli responsive.

Se tocchi solo uno dei due, spesso il cambiamento non basta.

Esempio classico:
- in `scenes/card/card.tscn` cambi la dimensione base della carta
- in `scripts/ui/card_ui.gd` il metodo `apply_layout()` puo sovrascrivere la tua modifica a runtime

Quindi il punto corretto va sempre verificato prima.

## 2. Se vuoi modificare una carta

Ci sono tre livelli distinti:

1. dati della carta
2. aspetto grafico della carta
3. comportamento della carta in gioco

### 2.1 Modificare i dati di una carta

File principali:
- `scripts/data/card_data.gd`
- `scripts/data/deck_loader.gd`
- `data/*.json`

Se vuoi cambiare una carta concreta, di solito tocchi il JSON del mazzo.

Esempi:
- `data/deck_apex_striker_specific.json`
- `data/deck_omega_pilot_specific.json`
- `data/deck_player.json`
- `data/deck_enemy_*.json`

Campi usati nei JSON:

```json
{
  "name": "Ignition Strike",
  "damage": 2,
  "shield": 0,
  "heal": 0,
  "energy": 0,
  "image": "blink_strike",
  "status_effect": "burn",
  "status_target": "opponent"
}
```

Significato:
- `name`: nome mostrato nella UI
- `damage`: danno inflitto
- `shield`: scudo generato
- `heal`: guarigione
- `energy`: costo energia
- `image`: chiave immagine, usata per cercare `assets/images/cards/<image>.png`
- `status_effect`: effetto stato opzionale
- `status_target`: bersaglio dello stato, `self` oppure `opponent`

Se cambi i dati di una carta ma non la vedi diversa in UI, controlla anche:
- il file immagine corrispondente
- il testo/tooltip costruito in `card_ui.gd` o `game_screen.gd`

### 2.2 Modificare come una carta appare

File principali:
- `scenes/card/card.tscn`
- `scripts/ui/card_ui.gd`

`card.tscn` contiene:
- la struttura visiva della carta
- `ImageArea`
- `NameLabel`
- `EffectsBox`
- `EnergyLabel`

`card_ui.gd` contiene:
- refresh grafico dati -> testo
- immagine placeholder o immagine vera
- dimensione runtime della carta
- hover, click, long press
- simbolo status effect

Se vuoi modificare:

#### Dimensione della carta

Punto principale:
- `scripts/ui/card_ui.gd`, metodo `apply_layout()` / `_apply_layout()`

Campi importanti:
- `custom_minimum_size`
- `width`
- `height`
- `image_height`
- font di nome, effetti, energia

Se vuoi solo una dimensione base statica, puoi toccare anche:
- `scenes/card/card.tscn`

Ma se esiste `apply_layout()`, il runtime vince quasi sempre.

#### Colore della carta

Punti principali:
- `scripts/ui/card_ui.gd`
- eventuali `modulate`
- texture placeholder in `_get_placeholder_texture()`

Se vuoi differenziare tipi/status:
- modifica i colori in `_get_placeholder_texture()`
- oppure usa `modulate` o `theme overrides`

#### Immagine della carta

Punto principale:
- `scripts/ui/card_ui.gd`

Logica attuale:
- cerca `res://assets/images/cards/<image_key>.png`
- se non esiste, usa placeholder procedurale

Quindi per cambiare immagine:

1. metti l'immagine nella cartella giusta
2. usa il valore corretto in `image` nel JSON

### 2.3 Modificare il comportamento della carta

File principali:
- `scripts/screens/game_screen.gd`
- `scripts/systems/deck_manager.gd`
- `scripts/systems/turn_manager.gd`
- `scripts/systems/combat_resolver.gd`

Esempi:
- click carta del player: `game_screen.gd` -> `_on_player_card_played()`
- discard: `deck_manager.gd`
- intenti: `ActorData` + `IntentPanelUI`
- status effect: `TurnManager` e logica correlata

## 3. Se vuoi cambiare il layout

Quando parli di layout nel progetto, devi prima capire in quale schermata sei.

### 3.0 Come capire se una modifica impatta desktop, mobile o entrambi

Regola pratica:

- se tocchi solo un `.tscn`, quasi sempre impatti sia desktop sia mobile
- se tocchi uno script con breakpoint basati su `viewport_size`, potresti cambiare desktop e mobile in modo diverso
- se vedi controlli come `OS.has_feature("mobile")` o `get_viewport_rect().size.x <= ...`, quella parte ha gia una biforcazione desktop/mobile

Controlla soprattutto:
- `card_ui.gd` per interazione touch e layout interno carta
- `game_screen.gd` per carte in combattimento, tooltip e responsive del board
- `card_selection_screen.gd` per griglia, tooltip selezione e colonne desktop/mobile

### 3.1 Selezione personaggio

File:
- `scenes/screens/character_selection_screen.tscn`
- `scripts/screens/character_selection_screen.gd`

Usa questi file per:
- posizione carosello
- dimensione pannello personaggio
- distanza tra frecce e pannello
- responsive desktop/mobile della schermata selezione personaggio

Regola:
- struttura base in `.tscn`
- calcolo resize in `.gd`

### 3.2 Selezione carte

File:
- `scenes/screens/card_selection_screen.tscn`
- `scripts/screens/card_selection_screen.gd`

Usa questi file per:
- posizione box centrale
- numero colonne della griglia
- grandezza delle card nella selezione
- bottone `Conferma Mazzo`
- tooltip selezione carte

Punto chiave:
- `card_selection_screen.gd` e il posto corretto per cambiare il numero di colonne e la dimensione delle carte in selezione

Impatto desktop/mobile:
- desktop: puoi spesso aumentare colonne e sfruttare piu larghezza orizzontale
- mobile: devi quasi sempre ridurre colonne, aumentare leggibilita del tooltip e semplificare il trigger input

### 3.3 Combattimento

File:
- `scenes/screens/game_screen.tscn`
- `scenes/board/game_board.tscn`
- `scripts/screens/game_screen.gd`

Usa questi file per:
- struttura verticale generale del combat
- ordine pannello nemico / mano nemico / intenti / mano player / pannello player / action bar
- label fase turno
- posizione e logica del bottone `Fine Turno`
- tooltip delle carte in combattimento

Regola pratica:
- `game_board.tscn` = struttura del board
- `game_screen.gd` = comportamento del board, resize runtime, tooltip, hand size, flusso stati

Impatto desktop/mobile:
- desktop: tende a soffrire di troppo spazio vuoto e carte troppo strette se la larghezza non viene usata bene
- mobile: soffre di tooltip fragili, hit area piccole e layout troppo alti

## 4. Se vuoi cambiare font o testo

Ci sono tre posti possibili.

### 4.1 Font di un nodo specifico

Nel `.tscn` cerca:
- `theme_override_font_sizes/font_size`
- `theme_override_colors/font_color`
- `theme_override_colors/font_outline_color`
- `theme_override_constants/outline_size`

Questo vale per:
- label HP
- label intenti
- tooltip
- nomi delle carte
- bottoni

### 4.2 Font applicato via script

Nel `.gd` cerca:
- `add_theme_font_size_override(...)`
- `add_theme_color_override(...)`
- `add_theme_constant_override(...)`

Questo e il caso tipico delle carte responsive: il font cambia con la dimensione della carta.

### 4.3 Tema globale

File:
- `scripts/autoload/theme_builder.gd`

Usalo per:
- stile globale dei `Button`
- stile globale dei `PanelContainer`
- colori di default dei `Label`
- stile base dei `ProgressBar`

Se vuoi un cambiamento generale coerente, parti da qui.
Se vuoi un cambiamento locale, tocca il file scena o script specifico.

## 5. Se vuoi cambiare il tooltip

### Tooltip combattimento

File:
- `scripts/screens/game_screen.gd`

Metodi chiave:
- `_on_card_hovered()`
- `_on_card_long_pressed()`
- `_show_tooltip()`
- `_reposition_tooltip()`
- `_is_touch_tooltip_mode()`

Desktop:
- hover mouse

Mobile:
- long press

Se vuoi cambiare posizione tooltip:
- modifica `_reposition_tooltip()`

Se vuoi cambiare contenuto tooltip:
- modifica `_show_tooltip()`

Se vuoi una UX diversa tra desktop e mobile:
- desktop: mantieni hover o tasto destro
- mobile: usa long press o tap esplicito, non hover simulato

### Tooltip selezione carte

File:
- `scripts/screens/card_selection_screen.gd`

Logica attuale:
- desktop: tasto destro
- mobile: long press

Metodi chiave:
- `_setup_tooltip_ui()`
- `_show_tooltip()`
- `_hide_tooltip()`
- `_reposition_tooltip()`
- `_on_card_button_gui_input()`

## 6. Se vuoi cambiare HP, energia, balance o ritmo del gioco

File:
- `scripts/autoload/config.gd`

Qui cambi:
- HP massimi
- energia massima
- carte pescate per turno
- animazioni
- enemy hand visibile o no
- velocita turno nemico
- soglie rating

Questo file e il punto corretto per numeri globali.
Non spargere numeri hardcoded in UI o systems.

## 7. Workflow consigliato per modifiche comuni

### Voglio cambiare qualcosa solo lato mobile

Controlla in ordine:

1. esiste gia una funzione che distingue mobile/desktop?
2. il codice usa `OS.has_feature("mobile")`?
3. il codice usa una soglia viewport, per esempio `size.x <= 900`?

Se si, modifica il ramo mobile senza toccare quello desktop.

Esempi tipici:
- carte troppo piccole su mobile: `game_screen.gd` o `card_selection_screen.gd`
- tooltip scomodo su mobile: `game_screen.gd` o `card_selection_screen.gd`
- spaziature troppo grandi su mobile: riduci `custom_minimum_size`, `spacing`, `separation`, altezze pannelli

### Voglio cambiare qualcosa solo lato desktop

Controlla in ordine:

1. c'e un breakpoint per viewport larga?
2. la UI usa tutta la larghezza disponibile o resta troppo compressa?
3. i font vengono aumentati per width piu grandi?

Esempi tipici:
- in combattimento le carte sembrano troppo strette: `game_screen.gd` -> `hand_card_width`
- in selezione puoi mostrare piu carte per riga: `card_selection_screen.gd` -> colonne e calcolo griglia
- i bottoni sembrano troppo aggressivi: `theme_builder.gd`

### Cambiare una carta esistente

1. trova il deck JSON giusto in `data/`
2. modifica valori (`damage`, `shield`, `heal`, `energy`, `status_effect`)
3. se cambi immagine, aggiorna `image`
4. se serve, aggiungi il PNG in `assets/images/cards/`
5. avvia il gioco e controlla:
   - selezione carte
   - tooltip
   - comportamento in combattimento

### Rendere le carte piu grandi o piu piccole

1. per la mano in combattimento:
   - `scripts/screens/game_screen.gd`
   - cerca `hand_card_width` e `hand_card_height`
2. per la resa interna della carta:
   - `scripts/ui/card_ui.gd`
   - cerca `_apply_layout()`
3. per la selezione carte:
   - `scripts/screens/card_selection_screen.gd`
   - cerca `_card_button_size`, colonne e calcolo griglia

### Cambiare font di una specifica area

1. se il font e statico, modifica il `.tscn`
2. se il font cambia con il resize, modifica il `.gd`
3. se vuoi un look globale, usa `theme_builder.gd`

### Cambiare il layout del combattimento

1. `scenes/board/game_board.tscn` per l'ordine dei blocchi
2. `scripts/screens/game_screen.gd` per altezze, tooltip, resize runtime
3. `scenes/board/hand_area.tscn` per deck/graveyard/hand container
4. `scenes/board/actor_panel.tscn` per barra HP/energia/nome

## 8. Errori tipici da evitare

- Modificare solo `.tscn` quando lo script rimette tutto a runtime
- Cambiare un font nella scena ma averlo poi sovrascritto via `add_theme_font_size_override()`
- Cambiare una card nel JSON ma dimenticare che il loader la valida e puo scartarla
- Toccare il layout della mano senza aggiornare `CardUI.apply_layout()`
- Trovare un problema su mobile e sistemarlo solo per mouse

## 9. Regola pratica finale

Quando vuoi modificare qualcosa, chiediti sempre:

1. E un dato?
   Vai su JSON / `CardData` / `Config`

2. E una struttura?
   Vai sul `.tscn`

3. E un comportamento dinamico o responsive?
   Vai sul `.gd`

4. E un look globale?
   Vai su `theme_builder.gd`
