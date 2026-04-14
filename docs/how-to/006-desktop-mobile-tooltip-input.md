# Desktop vs Mobile: input, tooltip e comportamento responsive

Questo documento spiega come funziona l'interazione su desktop e mobile, e dove intervenire se vuoi cambiarla.

## 1. Regola generale

Nel progetto desktop e mobile non devono usare la stessa UX in modo cieco.

Perche:
- desktop ha hover vero
- mobile non ha hover vero
- mobile usa preview sulla pressione e posizionamento tooltip piu robusto

## 2. Dove viene deciso se siamo in modalita touch

### In `card_ui.gd`

Metodo:

```gdscript
func _uses_touch_interaction() -> bool:
    return OS.has_feature("mobile")
```

Significato:
- se l'OS e mobile, usa il comportamento touch
- se l'OS non e mobile, resta comportamento desktop anche con finestra stretta

### In `game_screen.gd`

Metodo:

```gdscript
func _is_touch_tooltip_mode() -> bool:
    return OS.has_feature("mobile")
```

Stessa idea, ma lato gestione tooltip di combattimento. Il breakpoint di larghezza non decide piu il trigger del tooltip.

## 3. Tooltip nel combattimento

### Desktop

Trigger:
- tasto destro sulla carta player

Flusso:
1. `CardUI` emette `card_secondary_clicked`
2. `HandUI` rilancia `card_secondary_clicked_in_hand`
3. `GameScreen` riceve `_on_card_secondary_clicked()`
4. `GameScreen` chiama `_show_tooltip()`
5. `_reposition_tooltip()` lo posiziona vicino alla carta senza entrare nel layout del board

### Mobile

Trigger:
- pressione della carta

Flusso:
1. `CardUI` riceve la pressione e apre subito la preview
2. emette `card_long_pressed` come nome legacy del segnale
3. `HandUI` rilancia `card_long_pressed_in_hand`
4. `GameScreen` apre il tooltip ancorato alla carta

Rilascio:
- `CardUI` emette `card_long_press_released`
- `GameScreen` chiude il tooltip
- se la carta e giocabile, il rilascio conferma anche il click della carta

## 4. Tooltip nella selezione carte

### Desktop

Trigger attuale:
- tasto destro sulla carta

### Mobile

Trigger attuale:
- pressione della carta

Implementazione:
- tutta in `scripts/screens/card_selection_screen.gd`
- non passa per `CardUI`, perche in selezione stai usando `Button` generati a runtime, non `CardUI`
- il tooltip desktop in selezione e volutamente separato dal click sinistro, altrimenti ostacola la selezione rapida delle 10 carte

## 5. Perche un tooltip mobile spesso si rompe

Motivi tipici:
- usi solo `mouse_entered` / `mouse_exited`
- il touch viene emulato come mouse e non come `InputEventScreenTouch`
- il tooltip e ancorato male e finisce fuori viewport
- il rilascio del dito scatena anche il click carta

Nel progetto ci siamo difesi cosi:
- supporto sia `ScreenTouch` sia `MouseButton` in modalita touch
- tolleranza movimento per annullare la preview se il dito si sposta
- tooltip touch visibile solo mentre il dito resta premuto

## 6. Non c'e piu una soglia long press

Il tooltip mobile adesso si apre subito sulla pressione.

Se vuoi reintrodurre un ritardo intenzionale devi aggiungere un timer in:
- `scripts/ui/card_ui.gd`
- `scripts/screens/card_selection_screen.gd`

Al momento il solo filtro contro aperture accidentali e il movimento oltre `LONG_PRESS_MOVE_TOLERANCE`.

## 7. Dove cambiare la tolleranza di movimento

Se il tooltip si chiude troppo facilmente o si apre mentre trascini:

File:
- `scripts/ui/card_ui.gd`
- `scripts/screens/card_selection_screen.gd`

Costante:

```gdscript
const LONG_PRESS_MOVE_TOLERANCE := 18.0
```

Più basso:
- piu severo

Più alto:
- piu permissivo

## 8. Come modificare il comportamento desktop/mobile senza fare caos

Approccio corretto:

1. tieni una funzione unica che decide la modalita
2. separa desktop e touch in rami chiari
3. non mischiare hover e tap nello stesso ramo
4. usa un solo punto centrale per posizionare il tooltip

## 8.b Esempi concreti: ho provato il mobile e voglio cambiare...

### ...la dimensione delle carte nella selezione

File:
- `scripts/screens/card_selection_screen.gd`

Cosa toccare:
- `layout_width`
- `layout_height`
- `best_columns`
- `_card_button_size`
- `button_font_size`

Mobile:
- riduci colonne
- aumenta dimensione minima della card
- controlla che il tooltip resti leggibile

Desktop:
- puoi aumentare colonne e usare piu larghezza orizzontale

### ...la dimensione delle carte nell'area di gioco

File:
- `scripts/screens/game_screen.gd`
- `scripts/ui/card_ui.gd`

Cosa toccare:
- `hand_card_width`
- `hand_card_height`
- `_apply_layout()` in `card_ui.gd`

Mobile:
- fai attenzione a non rendere ingestibile il tap
- aumenta anche la hit area reale e il tooltip touch

Desktop:
- sfrutta di piu la larghezza e riduci l'effetto "fiammifero"

### ...la distanza tra le aree

Combattimento:
- `game_board.tscn` -> separazione container
- `game_screen.gd` -> altezze relative

Selezione:
- `card_selection_screen.gd` -> `spacing`, `grid_gap`

### ...la visualizzazione generale

Per riorganizzare davvero il layout:
- scena `.tscn` per struttura e ordine
- script `.gd` per responsive e dimensioni runtime

Regola:
- ordine nodi = scena
- dimensione adattiva = script

### ...i pulsanti

File:
- `scripts/autoload/theme_builder.gd`

Qui puoi fare pulsanti:
- meno aggressivi
- piu tondi
- meno saturi
- con hover piu morbido

### ...il background

File tipici:
- `scenes/board/game_board.tscn`
- `scenes/screens/*.tscn`

Nodi tipici:
- `ColorRect`
- `TextureRect`

### ...tooltip, transizioni, animazioni

Tooltip:
- `game_screen.gd`
- `card_selection_screen.gd`
- `card_ui.gd`

Animazioni:
- `card_ui.gd`
- `animation_manager.gd`
- `config.gd`

Transizioni di scena:
- `game_manager.gd`
- eventuali screen script collegati

## 9. Esempi di cambiamenti sensati

### Desktop: vuoi tooltip su hover invece che tasto destro

File:
- `scripts/screens/card_selection_screen.gd`

Punto:
- `_on_card_button_hovered()`
- `_on_card_button_unhovered()`
- `_on_card_button_gui_input()`

### Mobile: vuoi che il tap mostri solo il tooltip e non giochi/selezioni subito

Questo non e banale.
Richiede rivedere la logica in:
- `scripts/ui/card_ui.gd`
- `scripts/screens/game_screen.gd`
- `scripts/screens/card_selection_screen.gd`

### Vuoi disattivare totalmente il tooltip mobile

Punti:
- non collegare `card_long_pressed`
- oppure fai ritornare `false` da `_is_touch_tooltip_mode()` / `_uses_touch_interaction()`

## 10. Segnali principali coinvolti

### In `card_ui.gd`
- `card_clicked`
- `card_secondary_clicked`
- `card_hovered`
- `card_unhovered`
- `card_long_pressed`
- `card_long_press_released`

Nota:
- i segnali `card_long_pressed*` mantengono il nome storico ma ora, su mobile, rappresentano apertura/chiusura della preview alla pressione

### In `hand_ui.gd`
- `card_played_from_hand`
- `card_secondary_clicked_in_hand`
- `card_hovered_in_hand`
- `card_unhovered_in_hand`
- `card_long_pressed_in_hand`
- `card_long_press_released_in_hand`

## 11. Checklist rapida quando qualcosa non funziona

Se il tooltip non appare su mobile:
- controlla `_uses_touch_interaction()` o `_is_touch_tooltip_mode()`
- controlla che la pressione entri nel ramo touch
- controlla i segnali `card_long_pressed*`
- controlla che `_show_tooltip()` venga davvero chiamato

Se il tooltip appare ma e brutto o fuori posto:
- controlla `_reposition_tooltip()`
- controlla `reset_size()` e `get_combined_minimum_size()` nel momento in cui apri il popup
- controlla `custom_minimum_size` del tooltip
- controlla i font override

Se il tooltip blocca il click carta:
- controlla la sequenza `press -> tooltip -> release -> click`
- controlla la tolleranza movimento e il ramo `_cancel_*_preview()`
