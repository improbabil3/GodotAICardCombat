# Bibbia visiva: stile, palette, tipografia e regole grafiche

Questa guida blocca il linguaggio visivo del gioco.

Se non blocchi queste regole prima di produrre asset, il risultato piu probabile e questo:
- schermate con look diverso tra loro
- carte leggibili male
- portrait belli ma fuori tono
- background che mangiano il testo

## 1. Direzione artistica raccomandata

Direzione scelta:
- sci-fi tattico
- energetico ma controllato
- leggibile anche in piccolo
- olografico, non rumoroso
- tecnico, non militare iper-realistico

Parole chiave utili:
- holographic panels
- tactical HUD
- faction color coding
- clean silhouettes
- controlled glow
- layered depth
- readable UI

## 2. Direzioni da evitare

### Direzione da evitare 1

Sci-fi super realistico e pieno di dettagli.

Perche peggiora il progetto:
- il layout carta e piccolo
- il combat e ricco di testo e numeri
- il telefono perdona pochissimo

### Direzione da evitare 2

Sci-fi cartoon troppo morbido o troppo giocattoloso.

Perche peggiora il progetto:
- indebolisce la tensione tattica
- stona con il tono del combattimento

### Direzione da evitare 3

UI totalmente piatta con solo ColorRect.

Perche peggiora il progetto:
- sembra debug UI
- non costruisce gerarchia
- non da identita al gioco

## 3. Forma e materiali

### Regola generale

Usare pannelli a spigoli controllati e angoli leggermente smussati.

Motivo:
- il gioco e tecnico
- gli spigoli troppo secchi lo irrigidiscono
- le bolle tonde da app mobile lo banalizzano

### Materiale pannelli

Pannello principale:
- base molto scura
- bordo freddo sottile
- lieve gradiente interno
- texture leggera quasi invisibile

Pannello secondario:
- stessa famiglia
- meno contrasto
- meno glow

Pannello di allerta:
- non riempire tutto di rosso o arancio
- usa bordo o accento forte

### Glow

Regola:
- il glow deve servire a gerarchia e feedback
- non deve diventare rumore costante

Usalo per:
- selezione
- focus
- hover
- boss
- victory
- defeat

Non usarlo per:
- tutti i bordi sempre accesi
- tutto il testo
- tutti i pannelli insieme

## 4. Palette raccomandata

### Palette base UI

Base scuro profondo:
- `#0D1220`

Surface media:
- `#152136`

Surface tecnica chiara:
- `#1D2F4D`

Testo primario:
- `#E8F2FF`

Testo secondario:
- `#97A9C4`

Accent ciano:
- `#35D6FF`

Accent blu:
- `#4B7BFF`

Accent oro energia:
- `#F7C948`

### Colori di stato

Danno:
- `#FF5A5F`

Scudo:
- `#5DA9FF`

Cura:
- `#61D394`

Burn:
- `#FF8A3D`

Poison:
- `#88D66C`

Freeze:
- `#8EDBFF`

Haste:
- `#FFE082`

Blessed:
- `#FFD9A8`

## 5. Codice colore per fazioni

### Personaggi giocabili

Omega Pilot:
- blu energia + bianco tecnico

Phoenix Guardian:
- oro solare + rosso caldo controllato

Apex Striker:
- magenta caldo + arancio shock

Void Walker:
- viola scuro + verde tossico freddo

Cyber Mystic:
- turchese digitale + lilla elettrico

### Nemici

Base enemies:
- palette leggibile e contenuta

Elite:
- piu contrasto
- piu presenza dei bordi luce

Boss:
- palette dominante forte
- silhouette piu teatrale

## 6. Regole per i background

### Title screen

Obiettivo:
- impatto iniziale
- logo leggibile
- pulsanti leggibili

Regole:
- spazio centrale o inferiore pulito
- nessun dettaglio rumoroso dietro titolo e pulsanti
- profondita con pochi livelli veri

### Combat background

Obiettivo:
- sostenere il board, non rubarlo

Regole:
- contrasto piu basso delle carte
- dettagli piu morbidi del foreground
- zone testo e HUD pulite

### Selection background

Obiettivo:
- far leggere subito pannello e contenuti

Regole:
- fondale meno aggressivo del title
- fascia centrale pulita

### Victory e defeat

Obiettivo:
- trasmettere esito subito

Regole:
- struttura comune
- colore dominante diverso
- non trasformarle in due UI scollegate dal resto del gioco

## 7. Regole per i portrait

### Inquadratura

Usa busto o mezzo busto.

Motivo:
- `actor_panel.tscn` usa portrait piccoli
- la selezione personaggio ha bisogno di un'immagine grande ma ancora croppabile bene

### Cosa deve vedersi sempre

- volto o visore
- forma distintiva chiara
- 1 o 2 elementi firma del personaggio
- luce coerente con la fazione

### Cosa non deve dominare

- armi enormi davanti al volto
- sfondi pieni
- fumo o particelle su tutta la superficie

## 8. Regole per la card art

### Vincolo tecnico principale

La card art oggi vive dentro `ImageArea` in `CardUI`.

Questo significa:
- composizione larga o semi-larga
- soggetto principale chiaro
- sfondo semplice
- un solo gesto dominante

Non significa:
- poster verticale pieno di dettagli
- scena complessa con 3 livelli narrativi

### Struttura corretta di una carta

Ogni artwork deve avere:
- 1 soggetto o gesto principale
- 1 direzione di lettura forte
- 1 area di respiro
- 1 palette dominante chiara

### Regola di leggibilita

Se il gesto dell'azione non si capisce in 1 secondo a piccola scala, l'art non e valida.

## 9. Tipografia

### Regola base

Usa 2 famiglie, non 5.

1. font display per titoli
2. font UI per tutto il resto

### Font display

Deve essere:
- sci-fi ma non illeggibile
- usato per titoli, rating, headline

Non usarlo per:
- tooltip
- testo carta
- descrizioni lunghe

### Font UI

Deve essere:
- leggibile
- stabile su mobile
- pulito a dimensioni piccole

### Outline e shadow

Usali quando il background cambia davvero.

Non usarli come decorazione indiscriminata.

## 10. Icone e badge

Le icone finali devono:
- essere leggibili molto piccole
- funzionare anche senza testo lungo
- appartenere allo stesso set formale

Critica:
- tenere emoji come soluzione definitiva e da prototipo, non da release

## 11. Desktop vs mobile

### Desktop

Puoi permetterti:
- piu aria
- hover raffinato
- dettagli secondari moderati

### Mobile

Devi imporre:
- contrasto piu forte
- dettagli secondari ridotti
- contorni piu chiari
- testo piu pulito

Regola finale:
- se un elemento si legge solo su desktop, non e finito

## 12. Etichette obbligatorie

DA VERIFICARE:
- full-art card
- font con licenza poco chiara
- bundle grafici senza controllo licenza

PROPOSTA DA AI:
- linguaggio sci-fi tattico con glow controllato
- uso di 2 famiglie font soltanto
- uso di famiglie master per la card art