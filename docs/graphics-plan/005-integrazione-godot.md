# Integrazione Godot: quali file toccare, in che ordine e perche

Questa guida non serve a definire lo stile.

Serve a dirti dove la grafica entrera davvero nel progetto.

Se ignori questa guida, il rischio e produrre asset bellissimi che il gioco non sa mostrare oppure mostra male.

## 1. Regola di partenza

Prima di creare un asset finale, verifica sempre:
1. quale file Godot lo usera davvero
2. quale nodo lo mostrera davvero
3. quale script lo carichera davvero

## 2. Theme globale

### Situazione attuale

File principali:
- `scripts/autoload/theme_builder.gd`
- `scripts/autoload/game_manager.gd`

Stato:
- il tema globale oggi viene creato via codice
- `GameManager` applica il tema al root

### Intervento consigliato

1. Apri `scripts/autoload/theme_builder.gd`.
2. Cerca la funzione `static func build() -> Theme:`.
3. Verifica quali `StyleBoxFlat`, colori e font vengono creati a runtime.
4. Decidi quali di questi elementi devono restare in codice e quali devono diventare `Theme` resource.
5. Quando inizierai la vera integrazione, crea una risorsa tema in `assets/themes/` e usa il codice solo come loader o fallback.

Perche:
- rifinire tutto in codice e scomodo per il lavoro grafico
- una risorsa tema ti permette preview e controllo piu diretti

PROPOSTA DA AI:
- modello ibrido: resource per stile finale + script per applicazione globale

## 3. Title screen

### File coinvolti

- `scenes/screens/title_screen.tscn`
- `scripts/screens/title_screen.gd`

### Stato attuale

- background a `ColorRect`
- titolo e pulsanti senza asset grafici dedicati

### Cosa andra fatto

1. Apri `scenes/screens/title_screen.tscn`.
2. Cerca il nodo `Background` di tipo `ColorRect`.
3. Decidi se sostituirlo con un `TextureRect` oppure se aggiungere un `TextureRect` sotto i contenuti mantenendo il `ColorRect` come fallback.
4. Verifica il nodo `CenterContainer` e la `VBox` per capire dove il background deve lasciare spazio pulito ai pulsanti.
5. Apri `scripts/screens/title_screen.gd`.
6. Cerca `_apply_responsive_layout()`.
7. Controlla larghezze e altezze dei pulsanti per non creare un background che venga poi coperto male.

## 4. Character selection

### File coinvolti

- `scenes/screens/character_selection_screen.tscn`
- `scripts/screens/character_selection_screen.gd`

### Stato attuale

- il nodo `CharacterImage` e una `Label`
- lo script inserisce testo tipo `[CHARACTER_ID]`

### Cosa andra fatto

1. Apri `scenes/screens/character_selection_screen.tscn`.
2. Cerca il nodo `CharacterImage`.
3. Verifica che oggi sia una `Label` placeholder.
4. Pianifica la sua sostituzione con un `TextureRect` o un contenitore con immagine e overlay.
5. Apri `scripts/screens/character_selection_screen.gd`.
6. Cerca `_update_carousel_display()`.
7. Verifica che oggi scriva testo placeholder.
8. Pianifica il caricamento di un file in `assets/images/characters/<character>_select.png`.

Critica importante:
- produrre portrait senza prima pianificare questo cambio equivale a produrre un asset che il gioco non usa ancora

## 5. Card selection

### File coinvolti

- `scenes/screens/card_selection_screen.tscn`
- `scripts/screens/card_selection_screen.gd`

### Stato attuale

- top bar solo testuale
- le carte della selezione non sono `CardUI`
- `_create_card_buttons()` genera `Button` testuali

### Cosa andra fatto

1. Apri `scripts/screens/card_selection_screen.gd`.
2. Cerca `func _create_card_buttons() -> void:`.
3. Leggi `_create_single_card_button(card: CardData) -> Button`.
4. Verifica che oggi il contenuto venga costruito come testo multilinea.
5. Decidi una delle due strade:
   - sostituire i `Button` con vere `CardUI`
   - creare un componente intermedio visuale per la selezione, piu leggero di `CardUI` ma con immagine reale
6. Solo dopo questa decisione ha senso pianificare la vera card art anche per la deck selection.

Conclusione dura:
- oggi il progetto non mostra la card art in selection in modo reale
- quindi fare subito tutta la card art senza questo refactor e una scelta incompleta

## 6. Card art in combattimento

### File coinvolti

- `scenes/card/card.tscn`
- `scripts/ui/card_ui.gd`

### Stato attuale

- esiste un vero punto di caricamento immagini
- se il file non esiste, si cade nel placeholder

### Cosa controllare

1. Apri `scripts/ui/card_ui.gd`.
2. Cerca la stringa `res://assets/images/cards/%s.png`.
3. Verifica che il caricamento dipenda da `card_data.image_key`.
4. Apri `scenes/card/card.tscn`.
5. Cerca il nodo `ImageArea`.
6. Verifica dimensione e proporzione attuale della finestra immagine.
7. Prima di produrre artwork finali, testa il crop con mockup provvisori.

Questo e il punto piu importante per la card art.

## 7. Portrait in combattimento

### File coinvolti

- `scenes/board/actor_panel.tscn`
- `scripts/ui/actor_panel_ui.gd`

### Stato attuale

- `Portrait` esiste come `TextureRect`
- lo script genera una texture piena colorata

### Cosa andra fatto

1. Apri `scripts/ui/actor_panel_ui.gd`.
2. Cerca `func setup(is_player: bool) -> void:`.
3. Verifica la parte che crea `Image.create(64, 64, ...)`.
4. Pianifica la sostituzione con il caricamento di file portrait reali.
5. Apri `scenes/board/actor_panel.tscn`.
6. Cerca il nodo `Portrait`.
7. Controlla `custom_minimum_size` e `stretch_mode`.
8. Quando avrai i portrait finali, verifica che il crop combat regga davvero a questa dimensione.

## 8. Combat background

### File coinvolti

- `scenes/board/game_board.tscn`
- `scripts/screens/game_screen.gd`

### Stato attuale

- esiste un nodo `Background` a `ColorRect`

### Cosa andra fatto

1. Apri `scenes/board/game_board.tscn`.
2. Cerca il nodo `Background`.
3. Valuta se sostituire il `ColorRect` con `TextureRect` oppure tenere entrambi.
4. Apri `scripts/screens/game_screen.gd`.
5. Cerca `_apply_responsive_layout()`.
6. Verifica altezze pannelli, hand areas e intent panel.
7. Costruisci il background pensando alle aree che resteranno visibili davvero.

Critica:
- un combat background troppo forte peggiora tutto il resto

## 9. Battle result, victory e defeat

### File coinvolti

- `scenes/screens/battle_result_screen.tscn`
- `scripts/screens/battle_result_screen.gd`
- `scenes/screens/victory_screen.tscn`
- `scenes/screens/defeat_screen.tscn`

### Stato attuale

- sono schermate testuali con background molto semplici

### Cosa andra fatto

1. Apri `scenes/screens/battle_result_screen.tscn`.
2. Cerca il nodo `Background`.
3. Valuta se creare un fondale dedicato o una variante del result background condiviso.
4. Ripeti la stessa verifica su `victory_screen.tscn` e `defeat_screen.tscn`.
5. Mantieni struttura coerente.
6. Differenzia solo palette, accenti e tono visivo.

## 10. Import settings e peso asset

### File coinvolti indirettamente

- tutti i PNG finali in `assets/images/`

### Regola pratica

Prima dell'integrazione finale:
1. importa un primo blocco di asset test
2. apri Godot
3. seleziona ogni immagine nel FileSystem
4. controlla l'Import dock
5. verifica se i fondali grandi stanno consumando troppo o se il downscale crea aliasing

## 11. Ordine corretto di integrazione

Ordine raccomandato:
1. theme system
2. title screen
3. combat background e panel kit
4. portrait selection e combat
5. card art in combattimento
6. card selection visual refactor
7. result, victory e defeat

Se fai il contrario, rischi di correggere le stesse cose due volte.

## 12. Checklist finale prima di iniziare l'implementazione vera

1. hai deciso se la card selection mostrera `CardUI` o un componente dedicato?
2. hai deciso se il tema finale resta solo in codice o passa a resource?
3. hai verificato il crop reale dei portrait combat?
4. hai verificato il crop reale delle card art?
5. hai segnato con `DA VERIFICARE` i punti ancora aperti?