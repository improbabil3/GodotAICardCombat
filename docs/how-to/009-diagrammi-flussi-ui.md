# Diagrammi dei flussi UI e gameplay

Questa guida raccoglie diagrammi di flusso per capire velocemente come si muovono dati e interazioni nel progetto.

## 1. Flusso selezione personaggio -> selezione carte -> run

```mermaid
flowchart TD
    A[CharacterSelectionScreen.tscn] --> B[character_selection_screen.gd]
    B --> C[CharacterManager.set_selected_character]
    B --> D[GameManager.start_card_selection]
    D --> E[CardSelectionScreen.tscn]
    E --> F[card_selection_screen.gd]
    F --> G[Scelta 10 carte specifiche]
    G --> H[GameManager.player_deck]
    H --> I[GameManager.start_run]
    I --> J[GameScreen.tscn]
    J --> K[GameBoard.tscn]
```

## 2. Flusso di una carta in combattimento

```mermaid
flowchart TD
    A[CardData] --> B[HandUI.refresh_hand]
    B --> C[CardUI.instantiate]
    C --> D[CardUI.setup]
    D --> E[CardUI._refresh_visuals]
    E --> F[CardUI.apply_layout]
    F --> G[Carta visibile nella mano]
```

## 3. Flusso click carta player

```mermaid
flowchart TD
    A[Player clicca la carta] --> B[CardUI.card_clicked]
    B --> C[HandUI.card_played_from_hand]
    C --> D[GameScreen._on_player_card_played]
    D --> E[ActorData.spend_energy]
    D --> F[ActorData.add_card_intents]
    D --> G[DeckManager.discard_card]
    D --> H[TurnManager.apply_player_card_status]
    D --> I[Refresh UI]
```

## 4. Flusso tooltip combattimento desktop/mobile

```mermaid
flowchart TD
    A[CardUI input] --> B{Desktop o Mobile?}
    B -->|Desktop| C[Tasto destro]
    B -->|Mobile| D[pressione della carta]
    C --> E[HandUI.card_secondary_clicked_in_hand]
    D --> F[HandUI.card_long_pressed_in_hand]
    E --> G[GameScreen._show_tooltip]
    F --> G
    G --> H[GameScreen._reposition_tooltip]
    H --> I[Tooltip visibile]
```

## 5. Flusso tooltip selezione carte

```mermaid
flowchart TD
    A[Button carta selezione] --> B{Desktop o Mobile?}
    B -->|Desktop| C[Tasto destro]
    B -->|Mobile| D[Pressione]
    C --> E[card_selection_screen.gd _show_tooltip]
    D --> E
    E --> F[_reposition_tooltip]
    F --> G[Tooltip compatto vicino alla carta]
```

## 6. Flusso turni del combattimento

```mermaid
stateDiagram-v2
    [*] --> STATUS_START
    STATUS_START --> ENEMY_DRAW
    ENEMY_DRAW --> ENEMY_PLAY
    ENEMY_PLAY --> PLAYER_DRAW
    PLAYER_DRAW --> PLAYER_PLAY
    PLAYER_PLAY --> RESOLUTION
    RESOLUTION --> TURN_END
    TURN_END --> STATUS_START
    RESOLUTION --> GAME_OVER
    STATUS_START --> GAME_OVER
    TURN_END --> GAME_OVER
```

## 7. Flusso status effect

```mermaid
flowchart TD
    A[CardData.status_effect] --> B[TurnManager._apply_card_status_effect]
    B --> C[ActorData.apply_status]
    C --> D[ActorData.status_effects]
    D --> E{Fase turno corretta?}
    E -->|STATUS_START| F[Poison]
    E -->|DRAW| G[Freeze / Haste]
    E -->|TURN_END| H[Burn / Blessed]
    F --> I[Segnali TurnManager]
    G --> I
    H --> I
    I --> J[GameScreen refresh UI]
    J --> K[ActorPanelUI / tooltip / intent panel]
```

## 8. Flusso scene della run

```mermaid
flowchart TD
    A[Title] --> B[Character Selection]
    B --> C[Card Selection]
    C --> D[Game]
    D --> E{Win o Lose?}
    E -->|Win non finale| F[Battle Result]
    F --> D
    E -->|Win finale| G[Victory]
    E -->|Lose| H[Defeat]
    G --> A
    H --> A
```

## 9. Come usare questi diagrammi

Se non sai dove intervenire:

1. individua il flusso che somiglia al problema
2. segui i file da sinistra a destra
3. decidi se il problema e di:
   - dati
   - layout scena
   - resize runtime
   - input/tooltip
   - logica turni/status

Questa guida non sostituisce i riferimenti file-per-file, ma ti aiuta a capire la direzione giusta prima di editare.