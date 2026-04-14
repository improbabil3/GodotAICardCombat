# Riferimento dati: carte, status, mazzi e JSON

Questo documento descrive i file dati e il loro significato.

## 1. `scripts/data/card_data.gd`

Definisce il modello dati della carta.

Campi principali:
- `card_name`: nome carta
- `damage`: danno
- `shield`: scudo
- `heal`: guarigione
- `energy_cost`: costo energia
- `image_key`: chiave immagine
- `status_effect`: stato applicato
- `status_target`: bersaglio dello stato

Metodi utili:
- `create(...)`: costruttore usato dal loader
- `describe()`: stringa debug/tooltip
- `has_status_effect()`: true se la carta applica uno stato

## 2. Status effect supportati

Valori attualmente usati:
- `burn`
- `poison`
- `freeze`
- `haste`
- `blessed`

Bersagli validi:
- `self`
- `opponent`

## 3. `scripts/data/deck_loader.gd`

Carica i file JSON in `CardData`.

Fa validazione su:
- presenza file
- JSON valido
- campo `cards`
- range di danno/scudo/guarigione/energia
- numero effetti attivi
- status effect e target validi
- dimensione mazzo attesa di 20 carte

Se una carta e invalida, il loader puo scartarla.

Quindi se fai una modifica e la carta non appare, controlla prima qui.

## 4. Formato JSON atteso

Esempio:

```json
{
  "deck_name": "Apex Striker Specific",
  "cards": [
    {
      "name": "Ignition Strike",
      "damage": 2,
      "shield": 0,
      "heal": 0,
      "energy": 0,
      "image": "blink_strike",
      "status_effect": "burn",
      "status_target": "opponent"
    }
  ]
}
```

## 5. Dove si trovano i mazzi

Cartella:
- `data/`

Tipi principali:
- `deck_player.json`: mazzo base del player
- `deck_<character>_specific.json`: carte specifiche del personaggio
- `deck_enemy_*.json`: mazzi nemici

## 6. Quando modificare il JSON e quando modificare il codice

Modifica JSON se vuoi cambiare:
- nome carta
- numeri della carta
- immagine usata
- stato applicato dalla carta

Modifica codice se vuoi cambiare:
- come la carta viene mostrata
- come il tooltip descrive lo stato
- come il colore della carta rappresenta uno status
- comportamento speciale non rappresentabile con i campi esistenti

## 7. Immagini delle carte

La chiave `image` punta a:

`assets/images/cards/<image>.png`

Se il file non esiste:
- `CardUI` usa un placeholder colorato

## 8. Come aggiungere un nuovo status effect

Se vuoi aggiungere uno stato nuovo, non basta il JSON.

Devi aggiornare almeno:
- `scripts/data/card_data.gd`
- `scripts/data/deck_loader.gd`
- `scripts/ui/card_ui.gd` -> simbolo visuale
- `scripts/ui/actor_panel_ui.gd` -> icona effetti attivi
- logica gameplay nei systems se serve
- tooltip in `game_screen.gd` e `card_selection_screen.gd`

## 9. Errori tipici sui dati

- `status_effect` valido ma `status_target` vuoto
- immagine dichiarata ma file PNG mancante
- carta con zero effetti
- carta con troppi effetti attivi
- mazzo con numero carte diverso da 20
