## DESCRIZIONE
Bisogna fare delle cose:

1. Implementare nuovi nemici:
    Creare 4 nuovi nemici base (Totale nemici: 5 - 4 nuovi e 1 esistente)
    Creare 2 nemici elite (Totale elite: 2)
    Creare 1 nemico boss (Totale boss: 1)

2. Implementare battaglie sequenziali:
    - Si affrontano 2 nemici normali, 1 neico elite e il boss in sequenza. Ogni incontro è a sé stante. Il personaggio passando da uno scontro all'altro, riottiene tutti gli HP. Se il personaggio viene sconfitto in qualunque scontro, ottiene la schermata di sconfitta. Se sconfigge tutti e 4 i nemici, ottiene la schermata di vittoria

3. Calcolo punteggio per ciascun combattimento. 
    Ogni combattimento vinto, genera un punteggio. La somma dei punteggi viene mostrata nella schermata finale di vittoria o sconfitta. Il boss dà il punteggio più alto, seguito dagli elite e dai nemici normali. Anche il numero di turni e gli hp restanti influenzano il punteggio dello scontro. 
    Il punteggio del singolo scontro viene calcolato come:
    Punteggio scontro = Punteggio base * (HP Rimanenti/20) * (10/#Turni)
    La somma dà la qualità della run.

4. Mostrare il risultato con la classificazione della run: 
    la classifica si ottiene col sistema seguente
    - S: Run perfetta
    - A: Run quasi perfetta
    - B: Run buona
    - C: Run sufficiente (basta finire tutti gli scontri)
    - D: Run mediocre (sconfitta al boss finale)
    - E: Run scadente (sconfitta all'elite)
    - F: Run scellerata (sconfitta da uno dei mostri base).

5. Aumentare le classi disponibili nella scelta del personaggio a 5 totali (ora siamo a 3).