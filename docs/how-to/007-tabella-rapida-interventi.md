# Tabella rapida: se vuoi fare X, tocca questi file

Questa guida e una matrice unica e operativa.

Leggila cosi:
- `Modifica desiderata`: cosa vuoi ottenere
- `File principali`: dove intervenire davvero
- `Campi / funzioni`: cosa toccare dentro il file
- `Desktop`: se la modifica impatta il desktop o richiede un ramo specifico
- `Mobile`: se la modifica impatta il mobile o richiede un ramo specifico
- `Test veloce`: cosa controllare dopo la modifica

| Modifica desiderata | File principali | Campi / funzioni | Desktop | Mobile | Test veloce |
|---|---|---|---|---|---|
| Aumentare larghezza carte in combattimento | `scripts/screens/game_screen.gd`, `scripts/ui/hand_ui.gd`, `scripts/ui/card_ui.gd` | `hand_card_width`, `hand_card_height`, `set_card_size()`, `_apply_layout()` | Di solito si aumenta di piu per usare la larghezza | Va tenuta sotto controllo la hit area e il tap | Avvia un fight e controlla 5 carte in mano |
| Aumentare altezza immagine nella carta | `scripts/ui/card_ui.gd` | `image_height` in `_apply_layout()` | Si | Si | Controlla che nome ed effetti non vengano schiacciati |
| Aumentare font carta | `scripts/ui/card_ui.gd`, `scenes/card/card.tscn` | `name_font`, `effect_font`, `energy_font`, font override statici | Si | Si | Controlla truncation e wrap |
| Rendere le carte della selezione piu grandi | `scripts/screens/card_selection_screen.gd` | `layout_width`, `columns`, `_card_button_size`, `button_font_size`, `scroll_height` | Puoi usare piu colonne e piu larghezza | Meglio colonne fisse leggibili e scroll verticale | Controlla che le 20 carte restino leggibili |
| Rendere le schermate menu piu leggibili su smartphone | `scripts/screens/title_screen.gd`, `scripts/screens/character_selection_screen.gd`, `scripts/screens/card_selection_screen.gd` | font, pulsanti, pannelli, spaziature | Di solito basta rifinire i clamp | Serve un ramo mobile esplicito, non desktop ristretto | Prova titolo, selezione personaggio e selezione carte |
| Cambiare rapporto carte combattimento | `scripts/autoload/config.gd`, `scripts/screens/game_screen.gd` | `combat_card_aspect_ratio`, `Config.get_combat_card_height()`, `hand_card_width` | Si | Si | Aggiorna `combat_card_aspect_ratio` in `Config` e ricarica il gioco |
| Ridurre o aumentare spazi tra aree del combat | `scenes/board/game_board.tscn`, `scripts/screens/game_screen.gd` | `separation`, `panel_height`, `enemy_hand_height`, `player_hand_height`, `intent_height` | Tende ad avere troppo vuoto | Va bilanciato per non perdere il bottone Fine Turno | Controlla tutto il board a schermo intero |
| Ridurre o aumentare spazi nella selezione | `scripts/screens/card_selection_screen.gd` | `spacing`, `grid_gap` | Si | Si | Controlla titolo, griglia e bottoni |
| Rendere i bottoni piu tondi | `scripts/autoload/theme_builder.gd` | `set_corner_radius_all(...)` | Si | Si | Guarda hover, pressed e disabled |
| Rendere i bottoni meno aggressivi | `scripts/autoload/theme_builder.gd` | `bg_color`, `border_color`, `font_hover_color`, `font_pressed_color` | Si | Si | Controlla contrasto e leggibilita |
| Aggiungere background a una schermata | `scenes/screens/*.tscn`, `scenes/board/game_board.tscn` | `ColorRect`, `TextureRect`, asset immagini | Si | Si | Controlla scaling e aspect ratio |
| Cambiare tooltip nel combattimento | `scripts/screens/game_screen.gd`, `scripts/ui/card_ui.gd`, `scripts/ui/hand_ui.gd` | `_show_tooltip()`, `_reposition_tooltip()`, `_on_card_secondary_clicked()`, `card_secondary_clicked`, `_on_gui_input()` | Tasto destro sulla carta, overlay fuori layout | Press preview su mobile, close on release | Prova mouse e touch |
| Cambiare tooltip nella selezione | `scripts/screens/card_selection_screen.gd` | `_setup_tooltip_ui()`, `_show_tooltip()`, `_reposition_tooltip()`, `_on_card_button_gui_input()` | Tasto destro separato dal click sinistro | Press sulla card | Controlla che non blocchi la selezione |
| Aggiungere cue visivo a uno status | `scripts/screens/card_selection_screen.gd`, `scripts/ui/card_ui.gd`, `scripts/ui/actor_panel_ui.gd` | `_status_symbol()`, `_status_tint()`, `update_status_effects()` | Si | Si | Controlla selezione, hand e pannello HP |
| Aggiungere un nuovo status effect | `scripts/data/card_data.gd`, `scripts/data/deck_loader.gd`, `scripts/data/actor_data.gd`, `scripts/systems/turn_manager.gd`, `scripts/ui/card_ui.gd`, `scripts/ui/actor_panel_ui.gd`, tooltip script | campi dati, validazione, applicazione, scadenza, simboli, tooltip | Si | Si | Prova applicazione, durata, scadenza |
| Cambiare HP / energia / draw / ritmo globale | `scripts/autoload/config.gd` | export vars globali | Si | Si | Prova una run completa, non solo una schermata |
| Cambiare transizioni o scene di run | `scripts/autoload/game_manager.gd` | `SCENE_*`, `start_*`, `_change_scene()` | Si | Si | Controlla passaggi menu -> selection -> game |
| Cambiare animazioni carte | `scripts/ui/card_ui.gd`, `scripts/systems/animation_manager.gd`, `scripts/autoload/config.gd` | tween, durate, `animation_speed` | Si | Si | Controlla draw, play, discard |
| Cambiare intent panel | `scenes/board/intent_panel.tscn`, `scripts/ui/intent_panel_ui.gd` | font, colori, separazione, alignment, testo intenti, `apply_layout()` | Si | Si | Controlla aggiornamento durante turni |
| Cambiare pannello HP/energia | `scenes/board/actor_panel.tscn`, `scripts/ui/actor_panel_ui.gd` | font, barra HP, colori, contrasto, status label, `apply_layout()` | Si | Si | Controlla player e nemico |
| Rendere mazzo/cimitero piu leggibili su mobile | `scenes/board/hand_area.tscn`, `scripts/screens/game_screen.gd` | `DeckRect`, `GraveyardRect`, font pile, `_apply_hand_area_layout()` | Si | Si | Controlla icone e contatori laterali |

## Regola pratica

Se una modifica riguarda:
- struttura o ordine dei blocchi: prima la scena `.tscn`
- responsive, resize o logica condizionale: prima lo script `.gd`
- dati carta/mazzo: prima JSON e data layer
- look globale coerente: prima `theme_builder.gd`
