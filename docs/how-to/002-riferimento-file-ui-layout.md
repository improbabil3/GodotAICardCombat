# Riferimento file-per-file: UI, layout e interazione

Questo documento descrive i file principali della UI e cosa contengono.

## 1. `scenes/card/card.tscn`

Scena base della carta visiva.

Contiene:
- `Card` (`PanelContainer`): root della carta
- `VBox`: contenitore verticale interno
- `ImageArea`: immagine principale
- `NameLabel`: nome carta
- `EffectsBox`: box con danno/scudo/guarigione
- `EnergyLabel`: costo energia

Campi importanti:
- `custom_minimum_size`: dimensione base della carta
- `theme_override_font_sizes/font_size`: font base statici
- `ImageArea.custom_minimum_size`: altezza base immagine

Nota importante:
- il runtime puo sovrascrivere questi valori da `card_ui.gd`

## 2. `scripts/ui/card_ui.gd`

E il file piu importante per la carta come componente UI.

Responsabilita:
- ricevere i dati (`CardData`)
- scrivere testo nome/effetti/energia
- mostrare il simbolo di status
- caricare immagine o placeholder
- applicare layout responsive della carta
- gestire hover, click, long press
- gestire animazioni di draw/play/discard

Metodi chiave:
- `setup(data, playable)`
- `apply_layout(card_size)`
- `_apply_layout(card_size)`
- `_refresh_visuals()`
- `_on_gui_input(event)`
- `_get_placeholder_texture()`

Se vuoi:
- carta piu larga/alta: `_apply_layout()`
- immagine piu grande: `_apply_layout()` -> `image_height`
- font carta: `_apply_layout()`
- simboli status: `_status_symbol()`
- comportamento touch: `_on_gui_input()`

## 3. `scenes/board/hand_area.tscn`

Rappresenta una fascia mano completa.

Contiene:
- `DeckContainer`
- `HandContainer`
- `GraveyardContainer`

Uso:
- una istanza per il nemico
- una istanza per il player

Se vuoi cambiare:
- dimensione deck/graveyard
- spaziatura orizzontale tra deck, mano e cimitero
- allineamento della mano

tocchi questo file.

## 4. `scripts/ui/hand_ui.gd`

Gestisce il contenuto del `HandContainer`.

Responsabilita:
- istanziare `CardUI`
- rimuovere carte non piu presenti
- aggiornare stato giocabile
- propagare la dimensione carta a tutte le card UI

Campi chiave:
- `interactive`
- `show_card_details`
- `card_size`

Metodi chiave:
- `refresh_hand(cards, current_energy)`
- `set_card_size(new_size)`
- `update_playable_states(current_energy)`
- `get_card_ui(card_data)`

Se vuoi cambiare la dimensione della mano in combattimento, spesso devi toccare sia `game_screen.gd` sia `hand_ui.gd`.

## 5. `scenes/board/actor_panel.tscn`

Scena pannello attore.

Contiene:
- portrait
- nome
- barra HP
- label HP
- label energia
- bottone fine turno (storico / opzionale)

Se vuoi cambiare:
- altezza pannello HP
- font HP
- posizione testo HP
- distanza portrait / info

tocchi questo file.

## 6. `scripts/ui/actor_panel_ui.gd`

Responsabilita:
- aggiornare HP, energia e nome
- colorare la barra in base al rapporto HP
- animare barra HP
- mostrare effetti status

Metodi chiave:
- `setup(is_player)`
- `update_actor(actor, animate)`
- `update_status_effects(effects)`
- `show_end_turn_button(visible)`

Se vuoi cambiare la leggibilita della HP bar, questo e il file corretto.

## 7. `scenes/board/intent_panel.tscn`

Scena degli intenti.

Contiene:
- colonna intenti nemico
- label centrale sinistra/destra
- separatore verticale
- colonna intenti player

Se vuoi cambiare:
- ordine degli intenti
- spaziatura
- font e colori base
- etichette `Intento Nemico` / `Intento Giocatore`

tocchi questo file.

## 8. `scripts/ui/intent_panel_ui.gd`

Responsabilita:
- aggiornare i contatori numerici intenti
- flash quando un intento cambia
- reset a zero

Metodi chiave:
- `update_intents()`
- `flash_intent()`
- `reset_intents()`

## 9. `scenes/board/game_board.tscn`

E la struttura completa della schermata di combattimento.

Ordine attuale:
- margine alto
- pannello nemico
- mano nemico
- pannello intenti
- mano player
- pannello player
- action bar in basso
- tooltip popup

Se vuoi cambiare la composizione generale del combat, questo e il file base.

## 10. `scripts/screens/game_screen.gd`

E il controller della battaglia e anche il controller della UI di combattimento.

Responsabilita principali:
- setup player e enemy
- aggiornare mano, HP, intenti e contatori deck/graveyard
- orchestrare il turno
- calcolare il responsive del combat board
- gestire tooltip desktop/mobile
- gestire click carta del player

Metodi chiave per UI/layout:
- `_apply_responsive_layout()`
- `_refresh_all_ui()`
- `_refresh_actor_panels()`
- `_refresh_hand_ui()`
- `_show_tooltip()`
- `_reposition_tooltip()`

Se qualcosa in combattimento cambia da solo al resize o al cambio turno, quasi sicuramente parte da qui.

## 11. `scenes/screens/card_selection_screen.tscn`

Scena della selezione carte del personaggio.

Contiene:
- `TopBar`
- `CharacterInfoLeft`
- `SelectionCounter`
- `TitleLabel`
- `CardGridScroll`
- `CardGrid`
- `BottomBar`

Se vuoi cambiare struttura visiva della schermata di selezione, tocchi questo file.

## 12. `scripts/screens/card_selection_screen.gd`

Responsabilita:
- costruire la schermata scelta carte
- creare i bottoni delle 20 carte
- responsive della griglia
- tooltip selezione carte
- selezione/deselezione carte
- costruzione mazzo finale

Se vuoi cambiare:
- numero colonne
- grandezza card in selezione
- colore delle card selezionate
- tooltip desktop/mobile in selezione
- info card mostrate nei bottoni

tocchi questo file.

## 13. `scenes/screens/character_selection_screen.tscn`

Scena del carosello personaggi.

Contiene:
- label titolo
- pulsante precedente
- pannello personaggio
- pulsante successivo
- bottone selezione

## 14. `scripts/screens/character_selection_screen.gd`

Responsabilita:
- navigazione tra personaggi
- responsive del carosello
- aggiornamento nome/descrizione/placeholder
- passaggio alla schermata selezione carte

## 15. `scripts/autoload/theme_builder.gd`

Theme globale proceduralmente creato.

Controlla:
- stile `Button`
- stile `PanelContainer`
- stile `ProgressBar`
- colori base label e pannelli

Se vuoi cambiare il look generale del gioco, parti da qui.
