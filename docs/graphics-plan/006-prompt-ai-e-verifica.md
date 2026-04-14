# Prompt AI, regole di verifica e uso prudente dell'intelligenza artificiale

Questa guida serve a usare AI come acceleratore, non come sostituto della direzione artistica.

Se usi l'AI senza queste regole, il rischio reale e questo:
- stile incoerente
- output difficili da croppare
- dettagli inutili o illeggibili
- tempo perso a correggere materiale sbagliato

## 1. Regola principale

Usa AI per:
- moodboard
- thumbnail
- silhouette ideation
- esplorazione palette
- matte base di background

Non usarla come flusso finale cieco per:
- 96 card art definitive
- portrait finali senza revisione
- UI finale senza passaggio manuale

## 2. Etichette obbligatorie

Ogni scelta AI deve essere classificata cosi:

### PROPOSTA DA AI

Quando:
- l'idea nasce da ragionamento o proposta del sistema senza riscontro esterno diretto

### DA VERIFICARE

Quando:
- la scelta dipende da licenza, TOS, coerenza tecnica o resa reale nel gioco

## 3. Regole di prompt

Ogni prompt deve contenere:
- soggetto principale
- tono del mondo
- tipo di inquadratura
- vincolo di leggibilita a piccola scala
- livello di pulizia dello sfondo
- stile 2D coerente con UI game-ready

Ogni prompt dovrebbe evitare:
- photorealistic
- cluttered background
- multiple focal points
- cinematic poster layout
- text, logo, watermark

## 4. Prompt: portrait personaggio

Prompt base:

```text
2D sci-fi tactical portrait, heroic playable character, bold silhouette, clear face or visor, controlled neon rim light, readable at small size, game UI friendly, limited background clutter, faction color palette, polished concept art
```

Negative prompt:

```text
photorealistic, 3D render, busy background, tiny unreadable details, text, watermark, logo, extra limbs, messy composition
```

## 5. Prompt: portrait nemico

Prompt base:

```text
2D hostile sci-fi enemy portrait, strong silhouette, asymmetric armor or drone shape, clear focal face or core, dark controlled background, readable at small size, tactical game HUD portrait, polished stylized concept art
```

Negative prompt:

```text
real photo, cinematic full body poster, smoke everywhere, low contrast, text, watermark, cluttered composition
```

## 6. Prompt: card action art

Prompt base:

```text
sci-fi action vignette for a card banner, one strong focal action, readable at small size, clean silhouette, simple background, stylized 2D game illustration, faction color coding, composition designed for cropped card art
```

Negative prompt:

```text
vertical poster, multiple characters, too many details, text, watermark, unreadable background, photorealism
```

## 7. Prompt: combat background

Prompt base:

```text
sci-fi combat arena background, layered depth, clean central space for UI, subtle holographic panels, controlled lighting, not too noisy, supports readable HUD and cards, 2D game background
```

Negative prompt:

```text
character centered, cluttered perspective, heavy fog, text, watermark, logo, excessive particle effects
```

## 8. Prompt: menu background

Prompt base:

```text
sci-fi command center backdrop for game menu, strong atmosphere, clear negative space for title and buttons, subtle technical details, clean readable composition, stylized 2D background
```

Negative prompt:

```text
centered character, noisy background, tiny screens everywhere, text, watermark, overdesigned interface
```

## 9. Workflow corretto con AI

1. apri il manifest asset
2. scegli un singolo asset o famiglia
3. scrivi 3 prompt diversi
4. genera 3 a 6 opzioni per prompt
5. scegli solo la direzione migliore
6. scarta tutto il resto
7. fai paintover, semplificazione o ridisegno manuale
8. verifica crop e leggibilita in miniatura
9. solo dopo esporta il file finale

## 10. Checklist di verifica per ogni output AI

### Verifica compositiva

Domande:
- esiste un solo punto focale principale?
- il gesto dell'azione e leggibile?
- il volto o il core visivo e chiaro?

### Verifica tecnica

Domande:
- l'immagine regge il crop reale previsto?
- lo sfondo e abbastanza pulito?
- i dettagli secondari non rubano attenzione?

### Verifica stilistica

Domande:
- questa immagine sembra appartenere allo stesso gioco delle altre?
- la palette segue la bibbia visiva?

### Verifica legale

Domande:
- il tool usato permette l'uso commerciale nel tuo caso?
- hai salvato link e data della policy?

Se una delle risposte non e chiara, marca l'asset come `DA VERIFICARE`.

## 11. Segnali che l'output AI va scartato subito

- il volto e ambiguo o deformato
- la mano o l'arma e sbagliata ma centrale
- il soggetto non si legge in miniatura
- il background e piu interessante del soggetto
- l'output ha troppi dettagli fini inutili
- l'immagine sembra di un gioco diverso

## 12. Quando l'AI e utile davvero

AI e utile se ti fa risparmiare tempo nelle decisioni iniziali.

AI NON e utile se ti costringe a ripulire 50 immagini mediocri.

Questo e il criterio corretto.