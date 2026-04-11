## Multiple characters
Ora bisogna dare la possibilità al giocatore di scegliere tra diversi personaggi (di base, 3). Ogni personaggio avrà:
1. Un nome unico
2. Un aspetto unico
3. Un mazzo di 20 carte unico specifico per personaggio

Pensa a 3 personaggi che possiamo implementare.
Il mazzo del giocatore attuale, diventa il mazzo base.
Per ciascun personaggio, cambia la modalità di generazione del mazzo.
Si prenderanno 10 carte specifiche del personaggio e 10 carte del mazzo base. Il giocatore, una volta scelto il personaggio, sceglie le 10 carte del personaggio scelto. Le altre 10 carte vengono invece scelte a caso da quelle base.
LE carte del nemico, rimangono quelle, non si modificano.
Il combattimento avviene quindi col nuovo mazzo del singolo personaggio.


## Schermata selezione

Deve essere presente una sorta di carosello, in cui scegliere i personaggi.

```text
 ____________________________________________________________________
|						                    						 |
|						  __________________						 |
|					/    |		IMMAGINE    |     \					 |
|   (CAROSELLO     /	 |      PERSONAGGIO |      \    (CAROSELLO	 |
|   PERSONAGGIO   /		 |__________________|       \    PERSONAGGIO |
|   PRECEDENTE)   \       __________________        /    SUCCESSIVO) |
|				   \     | NOME PERSONAGGIO |      /				 |
|					\    |__________________|     /					 |
|____________________________________________________________________|
 ```
 Sul click del personaggio, si passa alla pagina di scelta delle carte

## Schermata scelta carte personaggio

Devono essere mostrate tutte le carte del personaggio. Una volta selezionate 10, non deve essere possibile selezionarne altre e si deve premere continua. DEve però essere possibile deselezionare la carte se sono state selezionate erroneamente. Solo con 10 carte selezionate si può andare avanti. Le carte selezionate faranno parte del deck iniziale del giocaotre, insieme a 10 carte casuali "base"
```text
 ___________________________________________________________________
|																   	|
|      NOME PERSONAGGIO						IMMAGINE PERSONAGGIO	|
|  ___   ___   ___   ___   ___   ___   ___   ___   ___   ___		|
| |#1 | |#2 | |#3 | |#4 | |#5 | |#6 | |#7 | |#8 | |#9 | |#10| 		|
| |___| |___| |___| |___| |___| |___| |___| |___| |___| |___|  		|
|  ___   ___   ___   ___   ___   ___   ___   ___   ___   ___  		|
| |#11| |#12| |#13| |#14| |#15| |#16| |#17| |#18| |#19| |#20| 		|
| |___| |___| |___| |___| |___| |___| |___| |___| |___| |___|  		|
|											________		 		|
| SELEZIONATE X di 10					   |CONTINUA|		 		|
|										   |________|		 		|
|___________________________________________________________________|
```

Esempi carte:

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