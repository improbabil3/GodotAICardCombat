# Manifest asset: elenco completo di cosa produrre e dove salvarlo

Questo documento e il manifest operativo degli asset.

Serve per evitare due errori:
- dimenticare asset obbligatori
- produrre asset inutili o duplicati

## 1. Riepilogo numerico

Scope confermato:
- 96 chiavi immagine carta uniche
- 5 personaggi giocabili
- 8 nemici
- 7 schermate o stati principali da rifinire

## 2. Cartelle target runtime

Cartelle runtime da usare:
- `assets/images/cards/`
- `assets/images/characters/`
- `assets/images/ui/`
- `assets/themes/`

Cartelle sorgente consigliate:
- `source_art/cards/`
- `source_art/characters/`
- `source_art/ui/`
- `source_art/fonts/`
- `source_art/licenses/`

PROPOSTA DA AI:
- tenere `source_art/` fuori dal runtime Godot per non far importare materiale sorgente non finale

## 3. Asset set P0

### Sistema UI

| Asset | Quantita minima | Cartella target | Nota |
|---|---|---|---|
| Background title | 1 | `assets/images/ui/` | puo avere variante desktop e mobile |
| Background combat | 1 | `assets/images/ui/` | deve reggere HUD e carte |
| Background result shared | 1 | `assets/images/ui/` | base comune per victory e defeat |
| Set pannelli 9-slice | 1 famiglia | `assets/images/ui/` | panel principale, secondario, alert |
| Set bottoni 9-slice | 1 famiglia | `assets/images/ui/` | normal, hover, pressed, disabled |
| Set badge e status | 1 famiglia | `assets/images/ui/` | status, energia, alert |
| Deck back | 1 | `assets/images/ui/` | sostituisce il look placeholder |
| Graveyard visual | 1 | `assets/images/ui/` | sostituisce il look placeholder |

### Portrait e roster

| Soggetto | Tipo | Master obbligatorio | Export minimi consigliati |
|---|---|---|---|
| Omega Pilot | player | 1 | selection, combat, result |
| Phoenix Guardian | player | 1 | selection, combat, result |
| Apex Striker | player | 1 | selection, combat, result |
| Void Walker | player | 1 | selection, combat, result |
| Cyber Mystic | player | 1 | selection, combat, result |
| Nexus Warlord | enemy | 1 | combat, result |
| Scrap Raider | enemy | 1 | combat, result |
| Void Drone | enemy | 1 | combat, result |
| Plasma Grunt | enemy | 1 | combat, result |
| Phase Stalker | enemy | 1 | combat, result |
| Iron Enforcer | enemy | 1 | combat, result |
| Void Overlord | enemy | 1 | combat, result |
| Galactic Tyrant | enemy | 1 | combat, result |

### Card art

| Blocco | Quantita | Nota |
|---|---|---|
| Master illustration consigliate | 24 | PROPOSTA DA AI |
| Export carta finali | 96 | richiesti dalle chiavi `image` nei JSON |

## 4. Schermate da rifinire

| Schermata o stato | File reali | Stato attuale | Asset richiesti |
|---|---|---|---|
| Title | `scenes/screens/title_screen.tscn` | background a `ColorRect` | background, logo treatment, button style |
| Character selection | `scenes/screens/character_selection_screen.tscn` | label placeholder immagine | portrait, panel, background |
| Card selection | `scenes/screens/card_selection_screen.tscn` | testo e bottoni | background, panel, eventuale visual card frame |
| Combat | `scenes/board/game_board.tscn` | background a `ColorRect` | background, panel kit, card art, portrait |
| Battle result | `scenes/screens/battle_result_screen.tscn` | semplice layout testuale | background e badge esito |
| Victory | `scenes/screens/victory_screen.tscn` | `ColorRect` + testo | background o variante esito |
| Defeat | `scenes/screens/defeat_screen.tscn` | `ColorRect` + testo | background o variante esito |

## 5. Personaggi giocabili: file naming consigliato

| Nome | File suggerito |
|---|---|
| Omega Pilot portrait large | `assets/images/characters/omega_pilot_select.png` |
| Omega Pilot portrait combat | `assets/images/characters/omega_pilot_combat.png` |
| Omega Pilot portrait result | `assets/images/characters/omega_pilot_result.png` |
| Phoenix Guardian portrait large | `assets/images/characters/phoenix_guardian_select.png` |
| Phoenix Guardian portrait combat | `assets/images/characters/phoenix_guardian_combat.png` |
| Phoenix Guardian portrait result | `assets/images/characters/phoenix_guardian_result.png` |
| Apex Striker portrait large | `assets/images/characters/apex_striker_select.png` |
| Apex Striker portrait combat | `assets/images/characters/apex_striker_combat.png` |
| Apex Striker portrait result | `assets/images/characters/apex_striker_result.png` |
| Void Walker portrait large | `assets/images/characters/void_walker_select.png` |
| Void Walker portrait combat | `assets/images/characters/void_walker_combat.png` |
| Void Walker portrait result | `assets/images/characters/void_walker_result.png` |
| Cyber Mystic portrait large | `assets/images/characters/cyber_mystic_select.png` |
| Cyber Mystic portrait combat | `assets/images/characters/cyber_mystic_combat.png` |
| Cyber Mystic portrait result | `assets/images/characters/cyber_mystic_result.png` |

## 6. Nemici: file naming consigliato

| Nome | File suggerito |
|---|---|
| Nexus Warlord combat | `assets/images/characters/nexus_warlord_combat.png` |
| Nexus Warlord result | `assets/images/characters/nexus_warlord_result.png` |
| Scrap Raider combat | `assets/images/characters/scrap_raider_combat.png` |
| Scrap Raider result | `assets/images/characters/scrap_raider_result.png` |
| Void Drone combat | `assets/images/characters/void_drone_combat.png` |
| Void Drone result | `assets/images/characters/void_drone_result.png` |
| Plasma Grunt combat | `assets/images/characters/plasma_grunt_combat.png` |
| Plasma Grunt result | `assets/images/characters/plasma_grunt_result.png` |
| Phase Stalker combat | `assets/images/characters/phase_stalker_combat.png` |
| Phase Stalker result | `assets/images/characters/phase_stalker_result.png` |
| Iron Enforcer combat | `assets/images/characters/iron_enforcer_combat.png` |
| Iron Enforcer result | `assets/images/characters/iron_enforcer_result.png` |
| Void Overlord combat | `assets/images/characters/void_overlord_combat.png` |
| Void Overlord result | `assets/images/characters/void_overlord_result.png` |
| Galactic Tyrant combat | `assets/images/characters/galactic_tyrant_combat.png` |
| Galactic Tyrant result | `assets/images/characters/galactic_tyrant_result.png` |

## 7. Chiavi carta: base player deck

File sorgente:
- `data/deck_player.json`

Chiavi uniche:
- `laser_burst`
- `plasma_cannon`
- `ion_strike`
- `nano_shield`
- `barrier_matrix`
- `deflect_field`
- `swift_strike`
- `power_slash`
- `energy_wave`
- `particle_blade`
- `piercing_strike`
- `momentum_slash`
- `fortify`

## 8. Chiavi carta: deck specifici personaggio

### Omega Pilot
- `swift_strike`
- `overdrive_pulse`
- `particle_blade`
- `mega_blast`
- `piercing_beam`

### Phoenix Guardian
- `swift_strike`
- `solar_strike`
- `retribution`
- `phoenix_burst`
- `mending_strike`

### Apex Striker
- `blink_strike`
- `quantum_strike`
- `hyper_shot`
- `void_nova`
- `hyper_pulse`

### Void Walker
- `blink_strike`
- `shadow_leech`
- `void_slash`
- `void_nova`
- `shadow_fang`

### Cyber Mystic
- `data_spike`
- `neural_strike`
- `mystic_surge`
- `overload`
- `cyber_slash`

## 9. Chiavi carta: deck nemici

### Nexus Warlord
- `void_slash`
- `dark_matter`
- `pulse_bolt`
- `null_barrier`
- `iron_aegis`
- `shadow_guard`
- `void_strike`
- `dark_slash`
- `null_pulse`
- `phase_strike`
- `void_crescent`
- `shadow_assault`
- `null_guard`

### Scrap Raider
- `scrap_slash`
- `junk_blade`
- `rust_spike`
- `salvage_strike`
- `rusty_guard`
- `patch_up`
- `scrap_barrage`
- `junk_bash`

### Void Drone
- `barrier_grid`
- `steel_shell`
- `micro_shield`
- `drone_zap`
- `system_repair`
- `fortify_grid`
- `shield_pulse`
- `overcharge`

### Plasma Grunt
- `plasma_blast`
- `heat_punch`
- `meltdown`
- `fusion_claw`
- `char_burst`
- `heat_shield`
- `plasma_burst`
- `thermal_surge`

### Phase Stalker
- `phase_cut`
- `shadow_step`
- `blink_strike`
- `phase_riposte`
- `feint`
- `phase_drain`
- `ghost_slash`

### Iron Enforcer
- `enforcer_strike`
- `iron_wall`
- `plate_bash`
- `bulwark`
- `fortified_hit`
- `iron_pulse`
- `recovery_protocol`

### Void Overlord
- `void_rend`
- `null_cannon`
- `dark_surge`
- `void_aegis`
- `oblivion_strike`
- `null_pulse_v`
- `abyss_claw`

### Galactic Tyrant
- `tyrant_smash`
- `galactic_fury`
- `cosmic_rampart`
- `nova_cannon`
- `reign_of_stars`
- `emperors_will`
- `astral_crush`

## 10. Chiavi condivise: non ridisegnarle due volte

| Chiave | Compare in |
|---|---|
| `swift_strike` | base player, Omega Pilot, Phoenix Guardian |
| `particle_blade` | base player, Omega Pilot |
| `blink_strike` | Apex Striker, Void Walker, Phase Stalker |
| `void_nova` | Apex Striker, Void Walker |
| `void_slash` | Void Walker, Nexus Warlord |

Regola:
- queste chiavi devono diventare asset condivisi veri, non duplicati con differenze casuali

## 11. Mappa master illustration consigliata

PROPOSTA DA AI.

| Famiglia | Copre esempi |
|---|---|
| Laser e beam | `laser_burst`, `piercing_beam`, `nova_cannon` |
| Slash energia | `power_slash`, `momentum_slash`, `enforcer_strike` |
| Shield barrier | `nano_shield`, `barrier_matrix`, `void_aegis` |
| Repair e mend | `mending_strike`, `system_repair`, `recovery_protocol` |
| Burn wave | `char_burst`, `dark_surge`, `emperors_will` |
| Poison strike | `scrap_slash`, `blink_strike`, `astral_crush` |
| Freeze pulse | `data_spike`, `drone_zap`, `iron_pulse` |
| Heavy cannon | `plasma_cannon`, `overdrive_pulse`, `plasma_blast` |
| Void burst | `void_nova`, `dark_matter`, `void_rend` |
| Tactical support | `fortify`, `bulwark`, `fortify_grid` |

## 12. Checklist di chiusura manifest

1. ogni chiave `image` ha un owner e una famiglia visiva
2. ogni soggetto portrait ha almeno un master approvato
3. ogni schermata principale ha almeno un piano background o panel treatment
4. non esistono doppioni inutili sulle chiavi condivise
5. i casi incerti sono marcati con `DA VERIFICARE`