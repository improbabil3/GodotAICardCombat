## DESCRIZIONE
Implementare le seguenti funzionalità

1. Implementazione degli effetti di stato. Pensavo a 5 effetti:
    - "Bruciato" (Burn)
    - "Avvelenato" (Poison)
    - "Congelato" (Freeze)
    - "Velocizzato" (Haste)
    - "Benedetto" (Blessed)

2. Gestione degli effetti:
    Vedere le descrizioni di riferimenti sotto

3. Generazione carte di effetto, specifiche per personaggio e per mostro. 
    Ogni mostro e personaggio avrà una caratteristica specifica. Scegli tu quale caratteristica associare. Il boss avrà carte con possibilità di usare due effetti di stato differenti nel proprio mazzo.
    Una volta generate, testare se le carte funzionano simulando 5000 combattimenti **PER CIASCUN PERSONAGGIO**. Il risultato deve essere di avere una percentuale n>=4 di **ALMENO il 10% di vittorie**. In caso contrario, modificare il deck del personaggio e rilanciare il test. Questo va fatto fino ad ottenere ALMENO il 10% di vittorie. **TUTTI I PERSONAGGI DEVONO AVERE QUESTA PERCENTUALE DI VITTORIE**

## EFFETTI

### BURN
Il personaggio è bruciato. Vengono applicate delle fiamme vicino al nome. Al termine del turno e prima dell'inizio del nuovo turno, chi è affetto da burn subisce 1 danno da bruciatura. Questo è un evento specifico, quindi deve esserci un'animazione che mostra il danno subito. Se questo danno porta il numero di HP del giocatore a 0, si riceve la schermata di sconfitta con i punti calcolati di conseguenza. Se questo danno porta il numero di HP del nemico a 0, il giocatore avanza al prossimo combattimento o, se è il combattimento finale, viene mostrata la schermata di vittoria. In caso in cui sia nemico che giocatore siano effetti da burn, prima subisce l'effetto il nemico e solo dopo, se HP nemico > 0, il giocatore. Il burn viene eliminato automaticamente dopo 3 turni. Se riapplicato prima del termine dei 3 turni, questo termine viene reimpostato a 3.

### POISON
Il personaggio è avvelenato. Viene applicato del veleno vicino al nome. All'inizio del nuovo turno e prima della fase di pesca del nemico, chi è affetto da poison subisce 1 danno da veleno. Questo è un evento specifico, quindi deve esserci un'animazione che mostra il danno subito. Se questo danno porta il numero di HP del giocatore a 0, si riceve la schermata di sconfitta con i punti calcolati di conseguenza senza esecuzione del nuovo turno. Se questo danno porta il numero di HP del nemico a 0, il giocatore avanza al prossimo combattimento o, se è il combattimento finale, viene mostrata la schermata di vittoria. In caso in cui sia nemico che giocatore siano effetti da poison, prima subisce l'effetto il nemico e solo dopo, se HP nemico > 0, il giocatore. Il poison viene eliminato automaticamente dopo 2 turni. Se riapplicato prima del termine dei 2 turni, questo termine viene reimpostato a 2.

### FREEZE
Il personaggio è congelato. Viene applicato del ghiaccio vicino al nome. All'inizio del proprio round, chi è affetto da freeze ha 1 di energia in meno da giocare per quel turno. Questo è un evento specifico, quindi deve esserci un'animazione che mostra l'enegia tolta. Il freeze dura 1 round e viene tolto automaticamente al termine del round del personaggio.

### HASTE
Il personaggio è velocizzato. Viene applicato un timer vicino al nome. All'inizio del proprio round, chi è affetto da haste ha 1 di energia in più da giocare per quel turno (il valore di energia giocabile in questo caso può andare oltre il valore massimo di 3). Questo è un evento specifico, quindi deve esserci un'animazione che mostra l'enegia guadagnata. Haste dura 1 round e viene tolto automaticamente al termine del round del personaggio.

### BLESSED
Il personaggio è benedetto. Viene applicata una croce sacra vicino al nome.
Al termine del turno, chi è affetto da blessed, guadagna 1 HP e guarisce dalle alterazioni di stato burn e poison.
L'effetto termina dopo 1 round. Nel round in cui il personaggio è blessed è immune alla sconfitta. Anche se gli HP del nemico/giocatore fossero portati a 0, blessed non lo permette, facendo restare gli HP a 1 e facendo giocare un nuovo turno


Le carte con l'effetto di stato, presenteranno il simbolo specifico all'interno della propria descrizione, sopra l'indicazione dell'energia necessaria per essere giocata.
