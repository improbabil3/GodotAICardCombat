# Esempi pratici di modifiche comuni

Questo documento contiene esempi operativi reali, con il punto corretto dove intervenire.

## Matrice rapida desktop/mobile

| Voglio cambiare... | File principali | Desktop | Mobile | Cosa toccare davvero |
|---|---|---|---|---|
| Dimensione carte in combattimento | `game_screen.gd`, `hand_ui.gd`, `card_ui.gd` | Si | Si | `hand_card_width`, `hand_card_height`, `_apply_layout()` |
| Rapporto larghezza:altezza carte in combattimento | `scripts/autoload/config.gd`, `scripts/screens/game_screen.gd` | Si | Si | `combat_card_aspect_ratio`, `Config.get_combat_card_height()` |
| Dimensione carte in selezione | `card_selection_screen.gd` | Si | Si | colonne, `layout_width`, `_card_button_size`, `scroll_height`, tooltip |
| Leggibilita generale su mobile | `title_screen.gd`, `character_selection_screen.gd`, `card_selection_screen.gd`, `game_screen.gd` | Rifinitura | Ramo dedicato | clamp, font, bottoni, altezze pannelli |
| Distanza tra aree del combat | `game_board.tscn`, `game_screen.gd` | Si | Si | `separation`, altezze pannelli, mano nemico, mano player, intent |
| Bottoni piu tondi | `theme_builder.gd` | Si | Si | `corner_radius`, colori, bordo, hover |
| Tooltip migliore | `game_screen.gd`, `card_selection_screen.gd`, `card_ui.gd` | Si | Si | trigger, posizione, dimensione popup, contenuto |
| Background o immagine di sfondo | `game_board.tscn`, `scenes/screens/*.tscn` | Si | Si | `ColorRect`, `TextureRect`, asset |
| Transizioni e animazioni | `config.gd`, `animation_manager.gd`, `card_ui.gd` | Si | Si | velocita, tween, callback |
| Font piu leggibili | scene `.tscn`, `card_ui.gd`, `actor_panel_ui.gd`, `intent_panel_ui.gd` | Si | Si | `font_size`, `outline_size`, override runtime |

## 1. Rendere una carta del combattimento piu larga e piu leggibile

File coinvolti:
- `scripts/screens/game_screen.gd`
- `scripts/ui/hand_ui.gd`
- `scripts/ui/card_ui.gd`

Flusso reale:

1. `game_screen.gd` decide la dimensione desiderata della carta in mano
2. passa la size a `HandUI.set_card_size(...)`
3. `HandUI` la inoltra a ogni `CardUI`
4. `CardUI._apply_layout()` ridisegna immagine, font e padding interni

Se vuoi allargare ancora le carte del combattimento:

- apri `scripts/screens/game_screen.gd`
- trova `_apply_responsive_layout()`
- cerca queste variabili:

```gdscript
var hand_card_width: float = ...
var hand_card_height: float = ...
```

Se vuoi carte piu larghe:
- aumenta `hand_card_width`
- aumenta anche `hand_card_height` in proporzione

Se la carta si allarga ma i contenuti interni restano brutti:
- apri `scripts/ui/card_ui.gd`
- modifica `_apply_layout()`

Punti da toccare in `_apply_layout()`:
- `image_height`
- `name_font`
- `effect_font`
- `padding`
- `separation`

## 2. Fare in modo che l'immagine occupi meta carta o piu

File:
- `scripts/ui/card_ui.gd`

Punto:

```gdscript
var image_height: float = clampf(height * 0.50, 96.0, 170.0)
```

Significato:
- `height * 0.52` = percentuale verticale della carta occupata dall'immagine
- i valori `98.0` e `168.0` sono min/max di sicurezza

Se vuoi piu immagine:
- aumenta `0.50` a `0.56` o `0.60`

Se vuoi meno immagine:
- riducilo a `0.45` o `0.48`

## 3. Cambiare il font della carta in combattimento

File:
- `scripts/ui/card_ui.gd`

Punto:

```gdscript
var name_font: int = ...
var effect_font: int = ...
var energy_font: int = ...
```

Se vuoi font piu grandi:
- aumenta questi valori

Se vuoi logica diversa per breakpoint:
- cambia le condizioni basate su `width`

## 4. Cambiare il layout del combattimento

File strutturali:
- `scenes/board/game_board.tscn`
- `scripts/screens/game_screen.gd`

Se vuoi spostare un blocco in alto o in basso:
- cambia l'ordine dei nodi in `game_board.tscn`

Se vuoi cambiare altezza relativa dei blocchi:
- usa `game_screen.gd` -> `_apply_responsive_layout()`

Variabili importanti:
- `panel_height`
- `hand_height`
- `intent_height`

Se vuoi piu aria su desktop:
- aumenta larghezza carte
- riduci un po la frammentazione verticale
- usa meglio la larghezza del board

Se vuoi piu compattezza su mobile:
- riduci spaziatura verticale
- riduci altezze rigide
- evita tooltip larghi o troppo bassi

## 5. Spostare la label fase turno

Caso tipico gia fatto:
- prima era sopra
- poi e stata spostata in basso nella `ActionBar`

File da toccare:
- `scenes/board/game_board.tscn`
- `scripts/screens/game_screen.gd`

Se vuoi portarla altrove:
- sposta il nodo `TurnLabel` nella scena
- aggiorna l'onready path in `game_screen.gd`

## 6. Cambiare il pulsante Fine Turno

File:
- `scenes/board/game_board.tscn`
- `scripts/screens/game_screen.gd`

Struttura attuale:
- il pulsante non vive piu nel pannello player come punto principale
- vive nella `ActionBar`

Se vuoi cambiarne:
- posizione: scena `.tscn`
- testo/font/dimensione: scena `.tscn` o script
- logica visibilita: `game_screen.gd`

## 7. Cambiare il tooltip desktop del combattimento

File:
- `scripts/screens/game_screen.gd`

Punti importanti:
- `_show_tooltip()` costruisce i contenuti
- `_reposition_tooltip()` decide dove appare

Se vuoi cambiare il testo:
- modifica `_show_tooltip()`

Se vuoi cambiare la posizione:
- modifica `_reposition_tooltip()`

## 8. Cambiare il tooltip mobile del combattimento

File:
- `scripts/ui/card_ui.gd`
- `scripts/ui/hand_ui.gd`
- `scripts/screens/game_screen.gd`

Catena reale:
- `CardUI` rileva long press
- `HandUI` rilancia il segnale
- `GameScreen` apre il tooltip

Quindi se non funziona:
- verifica l'input in `card_ui.gd`
- verifica che `HandUI` rilanci il segnale
- verifica che `GameScreen` abbia collegato il segnale

## 9. Cambiare il tooltip della selezione carte

File:
- `scripts/screens/card_selection_screen.gd`

Desktop attuale:
- tasto destro sulla carta

Mobile attuale:
- preview sulla pressione della carta

Punti chiave:
- `_setup_tooltip_ui()`
- `_show_tooltip()`
- `_reposition_tooltip()`
- `_on_card_button_gui_input()`

Desktop:
- preferisci un trigger separato dal click sinistro se la griglia e densa
- il default attuale usa il tasto destro

Mobile:
- usa preview sulla pressione e chiusura al rilascio
- evita tooltip stretchati a bordo schermo
- meglio popup compatti ancorati alla card o centrati in zona sicura

## 9.b Aumentare o diminuire la distanza tra le varie aree

Se vuoi piu o meno distanza tra blocchi UI:

### Combattimento
- `scenes/board/game_board.tscn` -> `theme_override_constants/separation`
- `scripts/screens/game_screen.gd` -> altezze di panel, hand e intent

### Selezione carte
- `scripts/screens/card_selection_screen.gd` -> `spacing`, `grid_gap`

### Interno carta
- `scripts/ui/card_ui.gd` -> `padding`, `separation`

## 9.c Fare bottoni meno aggressivi e piu tondi

File:
- `scripts/autoload/theme_builder.gd`

Punti:
- `btn_normal.bg_color`
- `btn_hover.bg_color`
- `btn_pressed.bg_color`
- `set_corner_radius_all(...)`
- `border_color`

Se vuoi un look piu morbido:
- riduci il contrasto hover
- aumenta il raggio angoli
- riduci spessore bordo

## 9.d Aggiungere un background o un'immagine

Se vuoi un background statico:
- usa `ColorRect` o `TextureRect` nella scena

File tipici:
- `scenes/board/game_board.tscn`
- `scenes/screens/*.tscn`

Se vuoi uno sfondo globale coerente:
- aggiorna anche il tema e la palette in `theme_builder.gd`

## 9.e Gestire meglio animazioni e transizioni

Punti principali:
- `scripts/autoload/config.gd` per velocita globale
- `scripts/ui/card_ui.gd` per draw/fly/hover
- `scripts/systems/animation_manager.gd` se vuoi centralizzare ancora di piu

Se vuoi animazioni piu rapide su mobile:
- usa un ramo dedicato oppure abbassa `Config.animation_speed`

Se vuoi animazioni piu leggibili su desktop:
- aumenta la distanza di movimento ma non per forza la durata

## 10. Mostrare un cue visivo per uno status effect nella selezione carte

File:
- `scripts/screens/card_selection_screen.gd`

Punti chiave:
- `_status_symbol(card)`
- `_status_tint(card)`
- `_apply_card_button_style(btn, card, selected)`

Se vuoi un comportamento diverso:

### Solo simbolo
- lascia `_status_symbol()`
- riduci o elimina il tint in `_status_tint()`

### Solo colore
- rimuovi il simbolo nel titolo
- lascia `_status_tint()`

### Simbolo + bordo + colore
- estendi `_apply_card_button_style()`

## 11. Cambiare una carta nei dati

File:
- `data/*.json`

Esempio:
- vuoi che `Ignition Strike` faccia `3` danni invece di `2`

Modifica:

```json
"damage": 3
```

Se vuoi aggiungere uno stato:

```json
"status_effect": "burn",
"status_target": "opponent"
```

Poi verifica che:
- il loader non la scarti
- il tooltip la descriva come previsto
- la UI mostri simbolo/colore corretti

## 12. Aumentare la leggibilita di HP e intenti

File:
- `scenes/board/actor_panel.tscn`
- `scripts/ui/actor_panel_ui.gd`
- `scenes/board/intent_panel.tscn`

Per HP:
- cambia `font_size`, `outline_size`, `font_outline_color`
- se vuoi contrasto dinamico, usa `actor_panel_ui.gd`

Per intenti:
- cambia font e colori in `intent_panel.tscn`
- cambia il refresh numerico in `intent_panel_ui.gd`

## 13. Come capire velocemente se devi toccare scena o script

Tocca la scena `.tscn` se:
- vuoi cambiare gerarchia
- vuoi cambiare ordine nodi
- vuoi cambiare dimensioni statiche
- vuoi cambiare font statico di un nodo preciso

Tocca lo script `.gd` se:
- il valore cambia con il resize
- il tooltip e dinamico
- la carta cambia size in base al viewport
- il comportamento dipende da mouse/touch
- il look cambia in base allo stato del gioco
