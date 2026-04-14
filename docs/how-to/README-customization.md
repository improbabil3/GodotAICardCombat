# Indice documentazione: personalizzazione UI, carte e layout

Questo file e il punto di ingresso rapido alla documentazione tecnica e pratica per modificare UI, carte, layout, tooltip e comportamento responsive.

## Ordine consigliato di lettura

Se vuoi capire il progetto rapidamente:

1. [001-guida-pratica-modifiche-ui-carte.md](e:\Source\GodotPlayTest\docs\how-to\001-guida-pratica-modifiche-ui-carte.md)
2. [002-riferimento-file-ui-layout.md](e:\Source\GodotPlayTest\docs\how-to\002-riferimento-file-ui-layout.md)
3. [003-riferimento-carte-mazzi-e-json.md](e:\Source\GodotPlayTest\docs\how-to\003-riferimento-carte-mazzi-e-json.md)
4. [004-glossario-campi-godot-ui.md](e:\Source\GodotPlayTest\docs\how-to\004-glossario-campi-godot-ui.md)

Se vuoi lavorare in modo operativo:

5. [005-esempi-pratici-modifiche.md](e:\Source\GodotPlayTest\docs\how-to\005-esempi-pratici-modifiche.md)
6. [006-desktop-mobile-tooltip-input.md](e:\Source\GodotPlayTest\docs\how-to\006-desktop-mobile-tooltip-input.md)
7. [007-tabella-rapida-interventi.md](e:\Source\GodotPlayTest\docs\how-to\007-tabella-rapida-interventi.md)
8. [008-guida-combattimento-status-effect.md](e:\Source\GodotPlayTest\docs\how-to\008-guida-combattimento-status-effect.md)
9. [009-diagrammi-flussi-ui.md](e:\Source\GodotPlayTest\docs\how-to\009-diagrammi-flussi-ui.md)

## Mappa per argomento

### Voglio modificare una carta
- dati: [003-riferimento-carte-mazzi-e-json.md](e:\Source\GodotPlayTest\docs\how-to\003-riferimento-carte-mazzi-e-json.md)
- UI carta: [002-riferimento-file-ui-layout.md](e:\Source\GodotPlayTest\docs\how-to\002-riferimento-file-ui-layout.md)
- esempi pratici: [005-esempi-pratici-modifiche.md](e:\Source\GodotPlayTest\docs\how-to\005-esempi-pratici-modifiche.md)

### Voglio cambiare dimensioni, font o colori
- panoramica pratica: [001-guida-pratica-modifiche-ui-carte.md](e:\Source\GodotPlayTest\docs\how-to\001-guida-pratica-modifiche-ui-carte.md)
- significato campi Godot: [004-glossario-campi-godot-ui.md](e:\Source\GodotPlayTest\docs\how-to\004-glossario-campi-godot-ui.md)
- esempi concreti: [005-esempi-pratici-modifiche.md](e:\Source\GodotPlayTest\docs\how-to\005-esempi-pratici-modifiche.md)

### Voglio cambiare il layout del combattimento
- riferimento file: [002-riferimento-file-ui-layout.md](e:\Source\GodotPlayTest\docs\how-to\002-riferimento-file-ui-layout.md)
- esempi concreti: [005-esempi-pratici-modifiche.md](e:\Source\GodotPlayTest\docs\how-to\005-esempi-pratici-modifiche.md)
- tabella rapida: [007-tabella-rapida-interventi.md](e:\Source\GodotPlayTest\docs\how-to\007-tabella-rapida-interventi.md)
- guida combat/status: [008-guida-combattimento-status-effect.md](e:\Source\GodotPlayTest\docs\how-to\008-guida-combattimento-status-effect.md)

### Voglio capire tooltip, click, right click, hover e long press
- guida dedicata: [006-desktop-mobile-tooltip-input.md](e:\Source\GodotPlayTest\docs\how-to\006-desktop-mobile-tooltip-input.md)
- glossario input/UI: [004-glossario-campi-godot-ui.md](e:\Source\GodotPlayTest\docs\how-to\004-glossario-campi-godot-ui.md)
- diagrammi: [009-diagrammi-flussi-ui.md](e:\Source\GodotPlayTest\docs\how-to\009-diagrammi-flussi-ui.md)

### Voglio aggiungere un nuovo status effect
- dati e validazione: [003-riferimento-carte-mazzi-e-json.md](e:\Source\GodotPlayTest\docs\how-to\003-riferimento-carte-mazzi-e-json.md)
- esempi operativi: [005-esempi-pratici-modifiche.md](e:\Source\GodotPlayTest\docs\how-to\005-esempi-pratici-modifiche.md)
- guida dedicata: [008-guida-combattimento-status-effect.md](e:\Source\GodotPlayTest\docs\how-to\008-guida-combattimento-status-effect.md)

### Voglio vedere i flussi principali del progetto senza leggere tutto il codice
- guida combat/status: [008-guida-combattimento-status-effect.md](e:\Source\GodotPlayTest\docs\how-to\008-guida-combattimento-status-effect.md)
- diagrammi UI e input: [009-diagrammi-flussi-ui.md](e:\Source\GodotPlayTest\docs\how-to\009-diagrammi-flussi-ui.md)

### Voglio una tabella unica “cosa toccare per fare X”
- tabella finale: [007-tabella-rapida-interventi.md](e:\Source\GodotPlayTest\docs\how-to\007-tabella-rapida-interventi.md)

### Voglio vedere i flussi UI come diagrammi
- diagrammi mermaid: [009-diagrammi-flussi-ui.md](e:\Source\GodotPlayTest\docs\how-to\009-diagrammi-flussi-ui.md)

### Voglio iniziare la grafica completa del gioco
- sezione dedicata al piano master: [docs/graphics-plan/README.md](e:\Source\GodotPlayTest\docs\graphics-plan\README.md)

## Nota importante

La cartella `how-to` deve restare la sezione delle guide operative su file, nodi, scene e script gia esistenti.

Il piano completo della grafica ora vive nella cartella dedicata:
- [docs/graphics-plan/README.md](e:\Source\GodotPlayTest\docs\graphics-plan\README.md)

## Matrice rapida: cosa toccare e dove impatta

| Modifica desiderata | File principali | Impatta desktop | Impatta mobile | Nota pratica |
|---|---|---|---|---|
| Allargare le carte in combattimento | `scripts/screens/game_screen.gd`, `scripts/ui/hand_ui.gd`, `scripts/ui/card_ui.gd` | Si | Si | Desktop e mobile usano breakpoint diversi: cambia sia `hand_card_width` sia `_apply_layout()` |
| Ingrandire le carte nella selezione | `scripts/screens/card_selection_screen.gd` | Si | Si | La griglia usa colonne diverse tra viewport grandi e stretti |
| Cambiare font delle carte | `scripts/ui/card_ui.gd`, `scenes/card/card.tscn` | Si | Si | Se esiste `apply_layout()`, lo script prevale sul `.tscn` |
| Aumentare spazio tra aree del combattimento | `scenes/board/game_board.tscn`, `scripts/screens/game_screen.gd` | Si | Si | Sul mobile controlla anche altezze e hit area, non solo la separazione |
| Rendere i bottoni piu tondi e meno aggressivi | `scripts/autoload/theme_builder.gd` | Si | Si | Qui cambi lo stile globale di tutti i `Button` |
| Aggiungere o cambiare background | `scenes/board/game_board.tscn`, `scenes/screens/*.tscn` | Si | Si | Se e globale, combina scena e tema |
| Cambiare tooltip selezione carte | `scripts/screens/card_selection_screen.gd` | Si | Si | Desktop e mobile non devono per forza avere lo stesso trigger |
| Cambiare tooltip combattimento | `scripts/screens/game_screen.gd`, `scripts/ui/card_ui.gd` | Si | Si | Desktop usa hover o mouse, mobile usa touch/long press |
| Cambiare animazioni carta | `scripts/ui/card_ui.gd`, `scripts/systems/animation_manager.gd`, `scripts/autoload/config.gd` | Si | Si | Prima controlla `Config.animation_speed` |
| Cambiare transizioni o ritmo UI | `scripts/autoload/config.gd`, screen/UI script coinvolti | Si | Si | Prima cambia il valore globale, poi rifinisci i casi speciali |
| Capire o modificare status effect e risoluzione combattimento | `scripts/systems/turn_manager.gd`, `scripts/systems/combat_resolver.gd`, `scripts/data/actor_data.gd` | Si | Si | Logica gameplay, non solo UI |

## File piu importanti del progetto per modifiche frequenti

- `scripts/ui/card_ui.gd`: aspetto runtime della carta
- `scripts/ui/hand_ui.gd`: gestione mano e dimensione carte in combat
- `scripts/screens/game_screen.gd`: layout combat, tooltip, turni, resize runtime
- `scripts/screens/card_selection_screen.gd`: layout selezione carte, tooltip selezione, griglia
- `scenes/board/game_board.tscn`: struttura combat board
- `scenes/card/card.tscn`: scena base carta
- `scripts/data/card_data.gd`: schema dati carta
- `scripts/data/deck_loader.gd`: validazione JSON mazzi
- `scripts/autoload/config.gd`: numeri globali e feature flags
- `scripts/autoload/theme_builder.gd`: tema globale

## Regola pratica finale

Se una modifica non sembra avere effetto, controlla in questo ordine:

1. hai toccato il file giusto?
2. il valore viene sovrascritto a runtime da uno script?
3. il nodo e dentro un container che lo ridimensiona?
4. il tooltip/input ha un comportamento diverso su desktop e mobile?
5. stai cambiando una logica di combattimento che in realta vive nei systems e non nella UI?

