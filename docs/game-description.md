## DESCRIZIONE
Ciao, voglio creare un gioco utilizzando Godot 4.7. Il gioco è un gioco di carte a turni.
Ci sono due entità: Giocatore (Player) e Nemico (Enemy)
Sulla plancia di gioco ci sono entrambi: il giocatore in basso e il nemico in alto

## PLANCIA DI GIOCO
La plancia di gioco è divisa in in cinque sezioni. Partendo dall'alto:

- Sezione Nemico -> Nome, HP Rimanenti, Energia rimanente, Immagine
- Sezione Mano del Nemico -> Carte pescate dal nemico (max 5), con mazzo a fianco e cimitero. Le carte non utilizzate vengono scartate. Qui metterei un flag per mostrare o nascondere queste carte, in modo da fare un play test
- Sezione Risultato -> In questa sezione vengono mostrate le carte giocate dal Nemico e dal Giocatore. Si mostrano quindi gli intenti e alò termine del turno si risolvono. Gli intenti vengono mostrat come contatori di danno, scudo e guarigione per ciascuna fazione.
- Sezione Mano del giocatore -> Carte pescate dal giocatore (max 5), con mazzo a fianco e cimitero. Ciascuna carta ha un nome, un'immagine e un effetto specifico. Passando sopra col mouse, compare una casella che mostra la descrizione della carta e l'effetto.
- Sezione Giocatore -> Nome, HP Rimanenti, Energia rimanente, Tasto fine turno

```text
 ________________________________________
| Immagine        Nome Nemico Energia: 5 |
|  ________________ _ _ _ _ _            |
| |______________/_ _ _ _ _ _| HP: X/20  |
|                    ___                 |
|    Mazzo ->       |   |                |
|                   |___|                |
|  ___   ___   ___   ___   ___      ___  |
| |   | |   | |   | |   | |   |    |   | | <- Cimitero
| |___| |___| |___| |___| |___|    |___| |
|                                        |
| Intento Nemico        Intento Giocatore|
|  DAN + Y              DAN + N          |
|  SCU + Z              SCU + M          |
|  GUA + W              GUA + L          |
|                                        |
|  ___   ___   ___   ___   ___      ___  |
| | X | | X | | X | | X | | X |    | X | | <- Cimitero
| |___| |___| |___| |___| |___|    |___| | <- Le carte con "X" sono visibili
|                    ___                 |
|    Mazzo ->       |   |                |
|                   |___|                |
|  ___   ___   ___   ___   ___      ___  |
|  __________________ _ _ _ _            |
| |_________________/_ _ _ _ | HP: Y/20  |
|                                        |
|                          ____________  |
| Energia: 5              | fine turno | |
|                         |____________| |
|________________________________________|
```


## CARTE
Ci possono essere tre effetti delle carte:
- Effetto danno -> Carte che causano danni e fanno calare gli HP. Possono avere un valore da 1 a 3.
- Effetto scudo -> Carte che contrastano le carte attacco, fornendo uno scudo. Possono avere un valore da 1 a 3.
- Effetto guarigione -> Carte che permettono di far recuperare HP. Possono avere un valore da 1 a 2.

Tutte le carte **possono** avere 1 o 2 effetti. Le possibili combinazioni sono:
- Carta con effetto danno
- Carta con effetto scudo
- Carta con effetto guarigione
- Carta con effetto danno e scudo
- Carta con effetto danno e guarigione
- Carta con effetto scudo e guarigione

**TUTTE le carte DEVONO** avere anche un valore di energia. Questo valore varia da 0 a 2. Questo è il valore che il giocatore deve pagare per poter giocare la carta, e viene scalato dalla quota energia rimanente del turno
Le carte DEVONO avere una sezione superiore con l'immagine della carta e una inferiore con l'elenco degli effetti.

Alcuni esempi
```text
 _________________
|  _____________  |
| |             | |
| |  Immagine   | |
| |             | |
| |_____________| |
|  DAN + 2        |
|  SCU + 1        |
|            ENE:0|
|_________________|

 _________________
|  _____________  |
| |             | |
| |  Immagine   | |
| |             | |
| |_____________| |
|                 |
|  SCU + 2        |
|            ENE:1|
|_________________|

 _________________
|  _____________  |
| |             | |
| |  Immagine   | |
| |             | |
| |_____________| |
|  GUA + 2        |
|  SCU + 3        |
|            ENE:2|
|_________________|

```
_______________

## REGOLE TURNO
Si gioca a turni. Ogni turno il nemico fa la sua azione e il giocatore risponde. Gli effetti si risolvono SOLO alla fine del turno.
Al termine del turno, l'energia rimasta per giocare le carte viene riportata al livello massimo predefinito (5). Lasciare comunque aperta la possibilità di accumulare energia nei turni successivi tramite feature flag.
Il giocatore/nemico può giocare un numero di carte pari al costo delle stesse in energia.
Se una carta "costa" (ossia ha energia) più di quanta energia è rimasta, la carta non può essere giocata.
Ogni volta che viene giocata una carta, questa aumenta i contatori degli effetti ad essa associata per l'attore che la gioca (giocatore o nemico). Una volta giocata e aggiunti gli effetti ai contatori, la carta viene scartata, ossia finisce nel cimitero.
Se ad inizio turno non ci sono abbastanza carte nel mazzo da pescare, si prendono prima le carte rimanenti nel mazzo, poi si prendono quelle del cimitero, si mischiano e si pescano le carte rimanenti. Il mazzo non termina mai. Esempio:

______________________
|INIZIO TURNO        |
|Carte Mazzo: 4      |
|Carte Cimitero: 16  |
|Carte in mano: 0    |
|____________________|
Si prendono le 4 carte del mazzo e le si danno al giocatore. Si mischiano poi le 16 carte del cimitero e queste diventano il nuovo mazzo. Da questo mazzo, si pesca la singola carta per completare la mano del giocatore

______________________
|FINE PESCATA        |
|Carte Mazzo: 15     |
|Carte Cimitero: 0   |
|Carte in mano: 5    |
|____________________|
il turno si divide in due round:
1. nel primo round, il nemico pesca le carte, fa le giocate, aumenta i contatori e passa la mano
2. Nel secondo round, il giocatore pesca le carte, fa le giocate, aumenta i contatori e passa la mano. Dopo che il giocatore ha passato la mano, Si risolvono gli effetti. Al termine della risoluzione degli effetti, se gli HP di entrambi sono maggiori di 0, si ricomincia con un nuovo turno.

Il gioco termina quando uno dei due attori ha HP<=0

## RISOLUZIONE EFFETTI
La risoluzione avviene in quest'ordine: 
1. 
    Effetti di guarigione: Giocatore e Nemico guariscono (aumentano gli HP) della somma del valore degli effetti guarigione giocati. Gli HP non possono mai superare il massimo. 
2. 
    Attacco del giocatore: il calcolo dei danni come 
    dg = (danno giocatore - scudo nemico)
    Se positivo, il nemico subice dg danni, che vanno sottratti agli HP attuali del nemico. Se muore (HP <= 0), finisce l'incontro e NON si risolve il punto 3, andando direttamente alla schermata di vittoria.
3. 
    Le azioni del nemico: se il nemico ha HP > 0, avviene calcolo dei danni come 
    dn = (danno nemico - scudo giocatore). 
    Se positivo, il giocatore subice dn danni, che vanno sottratti agli HP attuali. Se muore (HP <=0), finisce l'incontro e non si passa al punto 4, andando direttamente alla schermata di sconfitta.
4. 
    Se entrambi gli attori hanno HP > 0, si riparte con un nuovo turno


## Dati inizio combattimento
HP Nemico: 20
HP Giocatore: 20
Energia rimanente nemico: 5
Energia rimanente giocatore: 5
Carte nel mazzo nemico (totale): 20
Carte nel mazzo giocatore (totale): 20
Carte nel cimitero nemico: 0
Carte nel cimitero giocatore: 0
Carte pescate ad inizio turno nemico: 5
Carte pescate ad inizio turno giocatore: 5

## Cosa fare
Quel che mi aspetto è avere:
1 o più script godot funzionanti che implementano il gioco
1 schermata di inizio
1 schermata di gioco
1 schermata di vittoria (si chiede se si vuole fare una nuova partita)
1 schermata di sconfitta (si chiede se si vuole fare una nuova partita)
Debug attivo di tutto quello che succede nella console di godot, possibilmente con colori per distinguere le varie fasi/eventi.
Generare le carte in maniera casuale, con efftti e costi.
Animazione di pescata della carta, mix del mazzo, giocata della carta e scarto della carta verso il cimitero.
Immagini di base per identificare il personaggio, le carte etc.
Tutto quello che serve per farlo funzionare.