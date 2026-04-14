# Piano di lavoro completo: cosa fare, come, dove e quando

Questo documento e il piano master.

Non spiega solo modifiche tecniche.
Spiega l'intervento completo da eseguire per completare la grafica del gioco senza procedere a tentativi.

## 1. Obiettivo corretto

L'obiettivo non e "aggiungere qualche immagine".

L'obiettivo corretto e questo:
- definire un sistema grafico coerente
- creare gli asset minimi davvero necessari
- integrare gli asset nei punti giusti del progetto
- verificare la leggibilita su desktop e mobile
- non sprecare budget su asset che il gioco attuale non valorizza

## 2. Situazione iniziale reale

Stato del repository verificato:
- `assets/images/cards/` e vuota
- `assets/images/characters/` e vuota
- `assets/images/ui/` e vuota
- `assets/themes/` e vuota

Punti gia esistenti ma incompleti:
- `scripts/ui/card_ui.gd` puo caricare immagini carta nel combattimento
- `scripts/ui/actor_panel_ui.gd` non carica portrait veri, li genera proceduralmente
- `scripts/screens/character_selection_screen.gd` non usa ancora immagini reali del personaggio
- `scripts/screens/card_selection_screen.gd` non mostra la vera card art, crea `Button` testuali
- `scenes/screens/*.tscn` e `scenes/board/game_board.tscn` usano ancora sfondi placeholder a `ColorRect`

Conclusione operativa:
- la grafica non va "aggiunta sopra"
- va introdotta con un piano in piu fasi

## 3. Scope reale

Inventario verificato:
- 96 chiavi immagine carta uniche
- 5 personaggi giocabili
- 8 tipi di nemico
- 7 schermate o stati principali da rifinire

Fonti reali dello scope:
- `data/*.json`
- `scripts/systems/character_manager.gd`
- `scripts/autoload/game_manager.gd`
- `scenes/screens/*.tscn`
- `scenes/board/game_board.tscn`

Problema importante:
- parte della documentazione interna parla ancora di 3 personaggi

Questo significa che la documentazione non basta.
Per pianificare devi fidarti di codice e dati, non dei riassunti vecchi.

## 4. Ordine corretto delle fasi

### Fase 0 - Congelare il perimetro

Obiettivo:
- sapere con precisione cosa esiste e cosa manca

Output:
- questo piano
- manifest asset
- lista dei file da integrare

Condizione di uscita:
- sai quanti asset servono davvero
- sai quali schermate oggi sono placeholder

### Fase 1 - Bloccare lo stile

Obiettivo:
- decidere una volta sola il linguaggio visivo

Output:
- palette
- font
- regole pannelli
- regole portrait
- regole card art

File di riferimento:
- [002-bibbia-visiva.md](e:\Source\GodotPlayTest\docs\graphics-plan\002-bibbia-visiva.md)

Condizione di uscita:
- puoi creare un mockup statico e dire: "questo e il look del gioco"

### Fase 2 - Costruire il sistema UI

Obiettivo:
- far smettere il gioco di sembrare solo un prototipo anche prima delle illustrazioni finali

Output:
- sfondi base
- pannelli
- bottoni
- badge
- deck e graveyard visuali

File principali che entreranno in gioco:
- `scripts/autoload/theme_builder.gd`
- `scenes/board/game_board.tscn`
- `scenes/screens/title_screen.tscn`
- `scenes/screens/character_selection_screen.tscn`
- `scenes/screens/card_selection_screen.tscn`
- `scenes/screens/battle_result_screen.tscn`
- `scenes/screens/victory_screen.tscn`
- `scenes/screens/defeat_screen.tscn`

Condizione di uscita:
- schermate leggibili e coerenti anche con artwork temporanei

### Fase 3 - Creare i portrait

Obiettivo:
- definire i soggetti principali del gioco

Output:
- 5 master image personaggio
- 8 master image nemico
- crop per selection, combat e result

Condizione di uscita:
- ogni soggetto e riconoscibile a colpo d'occhio
- il crop combat regge anche molto piccolo

### Fase 4 - Creare la card art

Obiettivo:
- completare la libreria immagini carta con un approccio realistico e sostenibile

Output:
- famiglie art per archetipi
- export per tutte le chiavi `image`

Condizione di uscita:
- ogni chiave `image` dei JSON ha il proprio file finale

### Fase 5 - Integrare in Godot

Obiettivo:
- collegare tutto ai nodi, alle scene e agli script giusti

Output:
- portrait veri
- sfondi veri
- pannelli veri
- card art visibile dove deve esserlo davvero

Condizione di uscita:
- non restano placeholder critici nei flussi principali

### Fase 6 - QA visivo

Obiettivo:
- evitare il classico errore "e bello in grande ma in gioco non si legge"

Output:
- check desktop
- check mobile
- check contrasto
- check crop
- check performance e peso asset

Condizione di uscita:
- il gioco regge davvero alle dimensioni reali d'uso

## 5. Cosa fare subito e cosa no

### Da fare subito

1. finire il piano documentale
2. scegliere stile, palette e font
3. fissare il naming asset
4. fare 2 o 3 mockup statici completi

### Da NON fare subito

1. creare 96 immagini carta finali senza mockup
2. comprare bundle grossi "per sicurezza"
3. generare immagini AI in massa e metterle subito in `assets/images/cards/`
4. rifinire dettagli piccoli senza prima aver chiuso il sistema visivo

## 6. Decisioni raccomandate

### Decisione 1

Usare uno stile sci-fi tattico leggibile e sintetico.

Motivo:
- il progetto e UI-heavy
- le carte hanno una finestra immagine parziale
- il mobile richiede leggibilita forte

### Decisione 2

Trattare le immagini carta come sistema di famiglie, non come 96 dipinti slegati.

Motivo:
- budget e tempi non supportano 96 bespoke full quality fatti a mano da zero

PROPOSTA DA AI:
- 24 master illustration + 96 export finali derivati

### Decisione 3

Usare AI per concept e ideazione, non come flusso finale cieco.

Motivo:
- la coerenza cala rapidamente
- il controllo su stile e leggibilita peggiora

DA VERIFICARE:
- termini commerciali di ogni servizio AI usato

### Decisione 4

Non tenere il tema finale solo in codice.

Motivo:
- `scripts/autoload/theme_builder.gd` oggi e utile da prototipo
- per rifinitura visuale un `Theme` resource e piu gestibile

PROPOSTA DA AI:
- modello ibrido: Theme resource + loader o fallback via script

## 7. Decisioni da confutare prima di adottarle

### Ipotesi debole: full-art card classica

Confutazione:
- `scenes/card/card.tscn` e `scripts/ui/card_ui.gd` non sono costruiti cosi
- il crop reale non valorizza un'illustrazione verticale piena

Stato:
- DA VERIFICARE

### Ipotesi debole: pixel art per risparmiare

Confutazione:
- `project.godot` usa `canvas_items` e `expand`
- il progetto non e configurato come strict pixel workflow
- la UI attuale non e pensata per integer scaling come scelta principale

Stato:
- DA VERIFICARE solo se vuoi cambiare davvero direzione del progetto

### Ipotesi debole: comprare tutto da marketplace

Confutazione:
- rischio incoerenza alto
- difficolta di adattamento elevata
- facile sprecare budget prima del mockup corretto

Stato:
- da evitare come strategia primaria

## 8. Priorita pratiche

### P0

- piano completo
- bibbia visiva
- manifest asset
- pipeline strumenti e budget
- mockup title
- mockup combat
- mockup selection

### P1

- system UI definitivo
- 13 portrait
- background principali
- deck e graveyard visuali

### P2

- card art completa
- result polish
- victory e defeat polish

### P3

- extra VFX
- varianti boss
- alternative artwork

## 9. Timeline realistica solista part-time

### Settimana 1

1. leggi tutto `graphics-plan`
2. chiudi palette e font
3. crea 2 o 3 mockup statici

### Settimana 2

1. definisci pannelli, bottoni e sfondi base
2. blocca stile della carta

### Settimana 3

1. crea title e combat background
2. crea varianti per selection e result

### Settimana 4

1. crea i 5 personaggi
2. esporta i crop principali

### Settimana 5

1. crea gli 8 nemici
2. esporta i crop principali

### Settimana 6

1. crea le famiglie carta
2. fai i primi test di leggibilita in miniatura

### Settimana 7

1. esporta il blocco completo delle card image chiave
2. chiudi gli asset UI mancanti

### Settimana 8

1. integra in Godot
2. verifica desktop
3. verifica mobile
4. correggi i casi che falliscono

## 10. Checkpoint obbligatori

### Checkpoint A - leggibilita

Domande:
- si legge bene su desktop?
- si legge bene su smartphone?
- si legge bene in crop piccolo?

### Checkpoint B - coerenza

Domande:
- pannelli, card, portrait e font sembrano dello stesso gioco?

### Checkpoint C - valore reale

Domande:
- sto producendo un asset che il gioco oggi mostra davvero?

### Checkpoint D - licenza

Domande:
- ho archiviato licenza, fonte, data e restrizioni?

Se salti questi checkpoint, il progetto si degrada.

## 11. File reali che controlleranno il lavoro

Tieni sempre sotto mano questi file:
- `project.godot`
- `scripts/ui/card_ui.gd`
- `scenes/card/card.tscn`
- `scripts/ui/actor_panel_ui.gd`
- `scenes/board/actor_panel.tscn`
- `scenes/board/game_board.tscn`
- `scripts/screens/character_selection_screen.gd`
- `scripts/screens/card_selection_screen.gd`
- `scripts/autoload/theme_builder.gd`

## 12. Chiusura netta

No, non sbagliavi.

La tua intuizione era giusta:
- `how-to` deve restare la sezione delle modifiche operative puntigliose
- il piano completo doveva vivere in una sezione separata

E infatti ora lo spostiamo qui.