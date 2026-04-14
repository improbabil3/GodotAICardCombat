# Glossario pratico dei campi Godot che tocchi piu spesso

Questo file spiega il significato pratico dei campi Godot che compaiono nelle scene `.tscn` e negli script UI.

## 1. `layout_mode`

Valori tipici che vedi:
- `1`: il nodo e gestito come `Control` ancorato/libero nello spazio UI
- `2`: il nodo e gestito da un contenitore (`VBoxContainer`, `HBoxContainer`, `GridContainer`, ecc.)

Regola pratica:
- se il nodo e figlio di un container, quasi sempre `layout_mode = 2`

## 2. `anchors_left/top/right/bottom`

Definiscono quanto il nodo e agganciato ai bordi del parent.

Caso classico full-screen:
- `anchors_left = 0`
- `anchors_top = 0`
- `anchors_right = 1`
- `anchors_bottom = 1`

Vuol dire: il nodo segue tutta l'area del parent.

## 3. `anchors_preset = 15`

Shortcut Godot per `full rect`.
Praticamente equivale a dire: riempi tutto il parent.

## 4. `custom_minimum_size`

E una delle proprieta piu importanti.

Significa:
- il nodo non vuole essere piu piccolo di questa dimensione

Uso tipico:
- dare una dimensione minima a una carta
- dare una dimensione minima a una barra
- controllare l'altezza di una sezione UI

Se esageri con questo valore:
- rompi il responsive
- attivi scrollbar
- schiacci altri contenuti

## 5. `size_flags_horizontal` e `size_flags_vertical`

Dicono al container come trattare il nodo.

Valori che incontri spesso:
- `3`: expand/fill, il nodo prende piu spazio disponibile
- `SIZE_SHRINK_CENTER`: il nodo resta compatto e si centra

Uso pratico:
- `3` va bene per barre o aree che devono allargarsi
- `SHRINK_CENTER` va bene per box centrali, popup, gruppi compatti

## 6. `alignment`

Per `HBoxContainer` / `VBoxContainer` / `BoxContainer`.

Serve ad allineare i figli:
- inizio
- centro
- fine

Nel progetto e usato spesso per:
- centrare la mano
- centrare pulsanti in una barra
- centrare contenuti dentro una schermata

## 7. `theme_override_font_sizes/font_size`

Override diretto della dimensione font per quel nodo.

Se vuoi rendere leggibile una label specifica, questo e il posto piu semplice.

## 8. `theme_override_colors/font_color`

Colore del testo per quel nodo.

Spesso usato per:
- rosso danno
- blu scudo
- verde cura
- giallo energia

## 9. `theme_override_colors/font_outline_color`

Colore del bordo del testo.

Molto utile quando hai testo sopra barre colorate o sfondi luminosi.

## 10. `theme_override_constants/outline_size`

Spessore del bordo del testo.

Se una label si legge male su HP bar o background, aumenta questo.

## 11. `theme_override_constants/separation`

Spaziatura interna tra figli di un container.

Usalo per:
- aumentare aria tra carte
- aumentare aria tra label
- rendere meno compresso un layout

## 12. `offset_left/top/right/bottom`

Margini manuali rispetto al rettangolo ancorato.

Usati spesso per:
- padding interno
- far respirare un contenitore

Attenzione:
- offset e ancore insieme possono diventare scomodi se il layout e dinamico

## 13. `horizontal_alignment` / `vertical_alignment`

Allineamento del testo o del contenuto nel nodo.

Tipico:
- `horizontal_alignment = 1` -> centro
- `horizontal_alignment = 2` -> destra

## 14. `autowrap_mode`

Fa andare il testo a capo automaticamente.

Utile per:
- descrizioni personaggi
- tooltip
- nomi carta lunghi

## 15. `clip_text`

Se attivo, il testo viene tagliato nel rettangolo disponibile.

Spesso combinato con:
- `text_overrun_behavior`

## 16. `text_overrun_behavior`

Controlla come si comporta il testo troppo lungo.

Caso tipico:
- troncamento con ellissi

## 17. `modulate`

Colora/tinta tutto il nodo.

Nel progetto e usato per:
- desaturare carte non giocabili
- tingere card selezionate
- feedback visivo rapido

## 18. `z_index`

Ordine di sovrapposizione.

Importante per:
- tooltip
- popup
- elementi che devono stare sopra le carte

## 19. `mouse_filter`

Controlla come il nodo gestisce input mouse/touch.

Molto utile per:
- tooltip che non devono bloccare il click
- label decorative sopra altri nodi

## 20. `gui_input(event)`

Metodo GDScript per intercettare input direttamente sul nodo `Control`.

Nel progetto e fondamentale per:
- click carta
- tasto destro tooltip
- long press mobile

## 21. `mouse_entered` / `mouse_exited`

Segnali hover classici desktop.

Se una UI deve funzionare bene su mobile, non puoi affidarti solo a questi.

## 22. `InputEventScreenTouch` e `InputEventScreenDrag`

Eventi touch veri.

Usali per:
- long press mobile
- gesture touch

## 23. `InputEventMouseButton` e `InputEventMouseMotion`

Eventi mouse.

Nel progetto servono per:
- click sinistro
- tasto destro
- hover tooltip desktop

## 24. `add_theme_font_size_override()`

Versione script del cambio font size.

Serve quando il font cambia a runtime in base a:
- dimensione carta
- viewport
- modalità mobile/desktop

## 25. `add_theme_color_override()`

Versione script del cambio colore font o stile locale.

## 26. `apply_layout()` o funzioni responsive custom

Nel progetto, diverse dimensioni non sono statiche nella scena.

Significa che:
- puoi vedere una dimensione nel `.tscn`
- ma poi il `.gd` la sostituisce a runtime

Quindi quando una modifica "non sembra fare effetto", la prima cosa da cercare e:
- `apply_layout`
- `_apply_responsive_layout`
- `custom_minimum_size = ...` dentro lo script
