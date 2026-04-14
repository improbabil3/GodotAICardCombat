# Pipeline, strumenti e budget: come organizzare davvero il lavoro

Questa guida serve a impostare il lavoro pratico fuori da Godot.

Se non fai questa parte con ordine, succede sempre lo stesso disastro:
- file sparsi
- export con nomi incoerenti
- licenze perse
- immagini finali non piu riconducibili ai sorgenti

## 1. Strategia software raccomandata

### Stack base raccomandato

- Krita per painting, paintover e concept finalizzati
- Inkscape per icone, badge, cornici semplici e vettoriali puliti
- GIMP per compositing o export rapidi se ti serve un raster editor leggero alternativo
- Google Fonts o font con licenza chiarissima per la tipografia

### Stack opzionale a pagamento ma prudente

- 1 pack UI o icon pack ben scelto
- 1 mese di tool AI solo per concept e reference

### Tool che NON sono prioritari

- Aseprite, a meno che tu non voglia davvero spostare tutto verso pixel art
- bundle enormi di marketplace presi prima della bibbia visiva

## 2. Installazione: Krita

1. Apri il browser.
2. Vai a questo link: `https://krita.org/en/download/`
3. Cerca il pulsante `Windows Installer`.
4. Fai click sul pulsante di download.
5. Quando il file ha finito di scaricarsi, fai doppio click sul file `.exe`.
6. Quando compare la finestra di installazione, premi `Next`.
7. Lascia come cartella di installazione `C:\Program Files\Krita`.
8. Completa l'installazione.
9. Avvia Krita una volta per verificare che parta correttamente.

## 3. Installazione: Inkscape

1. Apri il browser.
2. Vai al sito ufficiale `https://inkscape.org/`.
3. Apri la sezione download per Windows.
4. Scarica l'installer stabile.
5. Fai doppio click sul file scaricato.
6. Installa in `C:\Program Files\Inkscape`.
7. Avvia Inkscape una volta per verificare che funzioni.

## 4. Installazione: GIMP

1. Apri il browser.
2. Vai a `https://www.gimp.org/downloads/`.
3. Cerca `Download GIMP` per Windows.
4. Scarica il setup ufficiale.
5. Fai doppio click sul file `.exe`.
6. Installa in `C:\Program Files\GIMP 3` oppure lascia la cartella predefinita proposta dall'installer.
7. Avvia GIMP una volta per verificare che parta.

## 5. Cartelle di lavoro da creare

1. Apri Esplora file.
2. Vai in una cartella che vuoi usare per i sorgenti grafici, per esempio `E:\Source\GodotPlayTest` oppure una cartella separata come `E:\GameArt\GalacticClash`.
3. Crea una cartella chiamata `source_art`.
4. Dentro `source_art` crea queste sottocartelle:
   - `cards`
   - `characters`
   - `ui`
   - `fonts`
   - `licenses`
   - `exports-temp`
5. Dentro `cards` crea queste sottocartelle:
   - `masters`
   - `variants`
   - `final`
6. Dentro `characters` crea queste sottocartelle:
   - `players`
   - `enemies`
   - `final`
7. Dentro `ui` crea queste sottocartelle:
   - `backgrounds`
   - `panels`
   - `buttons`
   - `icons`

PROPOSTA DA AI:
- tenere i file sorgente fuori da `assets/images/` per non mischiare sorgenti complessi ed export runtime.

## 6. Regola di naming da fissare subito

### File finali runtime

Usa solo:
- lettere minuscole
- underscore
- estensione `.png`

Esempi corretti:
- `omega_pilot_select.png`
- `nexus_warlord_combat.png`
- `laser_burst.png`
- `title_background.png`

### File sorgente

Puoi usare:
- suffissi di versione
- data
- master o variant

Esempi:
- `omega_pilot_master_v01.kra`
- `combat_background_v03.kra`
- `laser_family_master_v02.kra`

## 7. Export: regole minime

### Background

Master consigliato:
- `3840x2160`

Export iniziale consigliato:
- `1920x1080` oppure poco sopra se vuoi margine

### Portrait

Master consigliato:
- lato lungo almeno `1600 px`

Export consigliati:
- selection verticale o quasi verticale
- combat crop quadrato o quasi quadrato
- result crop orizzontale o medio

### Card art

Master consigliato:
- lato lungo almeno `1024 px`

Regola critica:
- comporre pensando al crop reale della carta, non a un poster pieno

## 8. Budget: tre scenari

### Scenario A - zero spesa

Usa:
- Krita
- Inkscape
- GIMP
- font open source con licenza chiara
- eventuali asset gratuiti solo con verifica licenza manuale

Quando sceglierlo:
- se vuoi massimizzare controllo e minimizzare rischio

### Scenario B - 30 a 80 dollari

Usa lo stack gratuito e aggiungi solo una di queste due cose:
- 1 pack icone o UI molto mirato
- 1 mese di strumento AI per concept

Quando sceglierlo:
- se ti serve accelerare la fase di esplorazione, non la produzione finale massiva

### Scenario C - 80 a 200 dollari

Usa lo stack gratuito e aggiungi:
- 1 o 2 pack premium ben selezionati
- eventuale mese AI per concept

Quando sceglierlo:
- solo dopo bibbia visiva e manifest asset

## 9. Dove puoi prendere asset o font e cosa devi controllare

### Font

Scelta prudente:
- Google Fonts

Perche:
- licenze piu leggibili
- sorgente chiara

Controlli obbligatori:
1. scarica il font dal sito ufficiale o repository ufficiale
2. salva la licenza in `source_art/licenses/`
3. annota nome, fonte, data e condizioni

### Asset gratuiti o marketplace

Siti utili da verificare con prudenza:
- OpenGameArt
- itch.io game assets

Controlli obbligatori:
1. apri la pagina asset
2. cerca la licenza precisa
3. verifica se l'uso commerciale e permesso
4. verifica se l'attribuzione e obbligatoria
5. salva screenshot o testo della licenza in `source_art/licenses/`
6. annota autore, link e data

Critica:
- scaricare un asset senza salvare la licenza equivale a creare debito futuro

## 10. Checklist prima di spendere soldi

Prima di qualsiasi acquisto rispondi a queste domande.

1. questo asset copre un bisogno gia presente nel manifest?
2. questo asset e coerente con la bibbia visiva?
3. questo asset verra davvero mostrato nel gioco attuale?
4. posso riusarlo in piu schermate o piu carte?
5. ho gia un equivalente gratuito sufficiente?

Se la risposta e no a 2 o piu domande, non comprare.

## 11. Workflow consigliato per ogni asset

1. apri il manifest asset
2. scegli l'asset esatto da produrre
3. apri la bibbia visiva
4. crea 3 thumbnail rapide
5. scegli 1 thumbnail
6. crea la versione master
7. crea i crop o gli export necessari
8. salva il sorgente in `source_art`
9. esporta il PNG finale nella cartella runtime corretta
10. annota stato, versione e data

## 12. Errori da evitare

- creare file finali direttamente nel progetto senza sorgente modificabile
- usare nomi incoerenti tra manifest e file
- salvare font senza licenza
- usare AI come output finale automatico senza paintover o revisione
- produrre background troppo dettagliati rispetto alla UI

## 13. Chiusura pratica

Lo scopo della pipeline non e burocratico.

Serve a impedirti di:
- perdere asset
- confondere versioni
- comprare cose inutili
- esportare file che poi non sai piu da dove arrivano