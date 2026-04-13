## CombatResolver — Risolve gli effetti a fine turno
##
## Ordine di risoluzione:
##   1. Guarigione: entrambi gli attori curano gli HP
##   2. Attacco giocatore: dg = danno_player - scudo_nemico → se positivo, nemico subisce dg
##      Se il nemico muore → segnale game_over (player win), NON si esegue punto 3
##   3. Attacco nemico: dn = danno_enemy - scudo_player → se positivo, giocatore subisce dn
##      Se il giocatore muore → segnale game_over (enemy win)

class_name CombatResolver
extends RefCounted

## Segnale emesso quando la partita finisce (player_won = true se ha vinto il giocatore)
signal game_over(player_won: bool)

## Esegue la risoluzione completa. Ritorna true se la partita continua, false se è finita.
func resolve(player: ActorData, enemy: ActorData) -> bool:
	DebugLogger.separator()
	DebugLogger.log_resolution("=== RISOLUZIONE EFFETTI ===")

	# ── 1. GUARIGIONE ──────────────────────────────────────────────────────────
	_resolve_healing(player, enemy)

	# ── 2. ATTACCO GIOCATORE ───────────────────────────────────────────────────
	var player_lives := _resolve_player_attack(player, enemy)
	if not player_lives:
		return false  # Nemico morto → vittoria giocatore

	# ── 3. ATTACCO NEMICO ──────────────────────────────────────────────────────
	var enemy_lives := _resolve_enemy_attack(player, enemy)
	if not enemy_lives:
		return false  # Giocatore morto → sconfitta

	# ── 4. ENTRAMBI VIVI → nuovo turno ────────────────────────────────────────
	DebugLogger.log_resolution("Entrambi vivi → nuovo turno")
	DebugLogger.log_resolution("Stato: %s" % player.debug_state())
	DebugLogger.log_resolution("Stato: %s" % enemy.debug_state())
	DebugLogger.separator()
	return true

## Guarigione per entrambi
func _resolve_healing(player: ActorData, enemy: ActorData) -> void:
	var p_heal: int = player.current_intents["heal"]
	var e_heal: int = enemy.current_intents["heal"]

	DebugLogger.log_resolution("── Fase 1: Guarigione ──")

	if p_heal > 0:
		var before := player.hp
		player.heal_hp(p_heal)
		DebugLogger.log_heal("%s guarisce +%d HP (%d → %d/%d)" % [
			player.actor_name, p_heal, before, player.hp, player.max_hp
		])
	else:
		DebugLogger.log_resolution("%s: nessuna guarigione" % player.actor_name)

	if e_heal > 0:
		var before := enemy.hp
		enemy.heal_hp(e_heal)
		DebugLogger.log_heal("%s guarisce +%d HP (%d → %d/%d)" % [
			enemy.actor_name, e_heal, before, enemy.hp, enemy.max_hp
		])
	else:
		DebugLogger.log_resolution("%s: nessuna guarigione" % enemy.actor_name)

## Attacco del giocatore verso il nemico. Ritorna false se il nemico muore.
func _resolve_player_attack(player: ActorData, enemy: ActorData) -> bool:
	DebugLogger.log_resolution("── Fase 2: Attacco Giocatore ──")

	var raw_damage: int = player.current_intents["damage"]
	var enemy_shield: int = enemy.current_intents["shield"]
	var dg: int = raw_damage - enemy_shield

	DebugLogger.log_damage("%s attacca — DAN:%d − SCU_nemico:%d = %d danno netto" % [
		player.actor_name, raw_damage, enemy_shield, dg
	])

	if dg > 0:
		var before := enemy.hp
		enemy.take_damage(dg)
		DebugLogger.log_damage("%s subisce %d danni (%d → %d HP)" % [
			enemy.actor_name, dg, before, enemy.hp
		])
		if not enemy.is_alive():
			if enemy.has_status("blessed"):
				enemy.hp = 1
				DebugLogger.log_heal("%s: benedizione impedisce la sconfitta (HP → 1)" % enemy.actor_name)
			else:
				DebugLogger.log_resolution("☠ %s ha 0 HP — VITTORIA del giocatore!" % enemy.actor_name)
				game_over.emit(true)
				return false
	else:
		DebugLogger.log_shield("%s: attacco neutralizzato dallo scudo (SCU:%d ≥ DAN:%d)" % [
			enemy.actor_name, enemy_shield, raw_damage
		])
	return true

## Attacco del nemico verso il giocatore. Ritorna false se il giocatore muore.
func _resolve_enemy_attack(player: ActorData, enemy: ActorData) -> bool:
	DebugLogger.log_resolution("── Fase 3: Attacco Nemico ──")

	var raw_damage: int = enemy.current_intents["damage"]
	var player_shield: int = player.current_intents["shield"]
	var dn: int = raw_damage - player_shield

	DebugLogger.log_damage("%s attacca — DAN:%d − SCU_giocatore:%d = %d danno netto" % [
		enemy.actor_name, raw_damage, player_shield, dn
	])

	if dn > 0:
		var before := player.hp
		player.take_damage(dn)
		DebugLogger.log_damage("%s subisce %d danni (%d → %d HP)" % [
			player.actor_name, dn, before, player.hp
		])
		if not player.is_alive():
			if player.has_status("blessed"):
				player.hp = 1
				DebugLogger.log_heal("%s: benedizione impedisce la sconfitta (HP → 1)" % player.actor_name)
			else:
				DebugLogger.log_resolution("☠ %s ha 0 HP — SCONFITTA!" % player.actor_name)
				game_over.emit(false)
				return false
	else:
		DebugLogger.log_shield("%s: attacco neutralizzato dallo scudo (SCU:%d ≥ DAN:%d)" % [
			player.actor_name, player_shield, raw_damage
		])
	return true
