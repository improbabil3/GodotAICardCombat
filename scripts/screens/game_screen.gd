## GameScreen — Orchestratore principale del combattimento
##
## Responsabilità:
## - Inizializza ActorData per player e enemy
## - Carica i mazzi da JSON
## - Crea e collega TurnManager, EnemyAI, CombatResolver
## - Aggiorna la UI in risposta ai segnali del TurnManager
## - Gestisce il click del giocatore sulle carte
##
## Struttura attesa nel GameBoard.tscn:
##   EnemyPanel_instance   → ActorPanelUI
##   EnemyHandArea         → HBoxContainer con HandUI figlio HandContainer
##   IntentPanel           → IntentPanelUI
##   PlayerHandArea        → HBoxContainer con HandUI figlio HandContainer
##   PlayerPanel_instance  → ActorPanelUI
##   TurnLabel             → Label
##   CardTooltip           → PanelContainer (popup)

extends VBoxContainer

# ── Riferimenti UI ──────────────────────────────────────────────────────────
@onready var _enemy_panel: ActorPanelUI    = $EnemyPanel_instance
@onready var _player_panel: ActorPanelUI   = $PlayerPanel_instance
@onready var _enemy_hand_area: HBoxContainer  = $EnemyHandArea
@onready var _player_hand_area: HBoxContainer = $PlayerHandArea
@onready var _intent_panel: IntentPanelUI  = $IntentPanel
@onready var _turn_label: Label            = $TurnLabel
@onready var _tooltip: PanelContainer      = $CardTooltip
@onready var _tooltip_name: Label          = $CardTooltip/TooltipVBox/TooltipName
@onready var _tooltip_effects: Label       = $CardTooltip/TooltipVBox/TooltipEffects
@onready var _tooltip_energy: Label        = $CardTooltip/TooltipVBox/TooltipEnergy

# Accedere ai HandUI (figli HandContainer dentro HandArea)
var _enemy_hand_ui: HandUI
var _player_hand_ui: HandUI

# Accedere ai contatori mazzo/cimitero
var _enemy_deck_count: Label
var _enemy_graveyard_count: Label
var _player_deck_count: Label
var _player_graveyard_count: Label

# ── Sistemi ─────────────────────────────────────────────────────────────────
var _player: ActorData
var _enemy: ActorData
var _turn_manager: TurnManager
var _anim_mgr: AnimationManager

# Flag per bloccare input durante animazioni
var _animating: bool = false

# Flag per animare i pannelli HP alla prossima refresh (dopo risoluzione)
var _animate_hp_next: bool = false

func _ready() -> void:
	_setup_actors()
	_setup_ui_references()
	_connect_ui_signals()
	_anim_mgr = AnimationManager.new()
	_turn_manager = TurnManager.new()
	_turn_manager.setup(_player, _enemy)
	_turn_manager.state_changed.connect(_on_state_changed)
	_turn_manager.turn_started.connect(_on_turn_started)
	_turn_manager.enemy_played_cards.connect(_on_enemy_played_cards)
	_turn_manager.game_over.connect(_on_game_over)
	# Aggiornamento UI iniziale
	_refresh_all_ui()
	# Avvia il gioco dopo un frame (per sicurezza che la UI sia pronta)
	call_deferred("_start_game")

func _start_game() -> void:
	_turn_manager.start()

# ── Setup ────────────────────────────────────────────────────────────────────

func _setup_actors() -> void:
	# Usa il personaggio selezionato dal GameManager
	var player_name := "Omega Pilot"
	if GameManager.selected_character != null:
		player_name = GameManager.selected_character.name

	_player = ActorData.new(player_name, Config.player_max_hp, Config.player_max_energy)

	# Carica i dati del nemico corrente dalla run
	var enemy_data := GameManager.get_current_enemy()
	if enemy_data != null:
		_enemy = ActorData.new(enemy_data.enemy_name, enemy_data.max_hp, enemy_data.max_energy)
	else:
		# Fallback di sicurezza
		_enemy = ActorData.new("Nexus Warlord", Config.enemy_max_hp, Config.enemy_max_energy)
		DebugLogger.log_error("GameScreen: nessun enemico nel roster, uso fallback")

	# Usa il mazzo scelto dal player se disponibile, altrimenti carica dal default
	var player_cards: Array[CardData]
	if GameManager.player_deck.size() > 0:
		player_cards = GameManager.player_deck.duplicate()
		DeckManager.shuffle_deck(player_cards)
	else:
		player_cards = DeckLoader.load_deck("res://data/deck_player.json")
		DeckManager.shuffle_deck(player_cards)

	# Carica il mazzo del nemico corrente
	var enemy_deck_path := "res://data/deck_enemy.json"
	if enemy_data != null:
		enemy_deck_path = enemy_data.deck_path
	var enemy_cards := DeckLoader.load_deck(enemy_deck_path)
	DeckManager.shuffle_deck(enemy_cards)

	_player.deck = player_cards
	_enemy.deck  = enemy_cards

	# Espone al GameManager per le schermate di esito
	GameManager.player = _player
	GameManager.enemy  = _enemy

	DebugLogger.log_system("GameScreen: attori inizializzati — %s vs %s (incontro %d)" % [
		_player.actor_name, _enemy.actor_name, GameManager.encounter_index + 1
	])

func _setup_ui_references() -> void:
	# HandUI è il nodo HandContainer dentro HandArea
	_enemy_hand_ui  = _enemy_hand_area.get_node("HandContainer") as HandUI
	_player_hand_ui = _player_hand_area.get_node("HandContainer") as HandUI

	_enemy_hand_ui.actor  = _enemy
	_enemy_hand_ui.show_card_details = Config.show_enemy_card_details
	_player_hand_ui.actor = _player

	# Contatori mazzo/cimitero
	_enemy_deck_count       = _enemy_hand_area.get_node("DeckContainer/DeckCount") as Label
	_enemy_graveyard_count  = _enemy_hand_area.get_node("GraveyardContainer/GraveyardCount") as Label
	_player_deck_count      = _player_hand_area.get_node("DeckContainer/DeckCount") as Label
	_player_graveyard_count = _player_hand_area.get_node("GraveyardContainer/GraveyardCount") as Label

	# Configura pannelli attori
	_enemy_panel.setup(false)
	_player_panel.setup(true)

func _connect_ui_signals() -> void:
	_player_hand_ui.card_played_from_hand.connect(_on_player_card_played)
	_player_hand_ui.card_hovered_in_hand.connect(_on_card_hovered)
	_player_hand_ui.card_unhovered_in_hand.connect(_on_card_unhovered)
	_player_panel.end_turn_pressed.connect(_on_end_turn_pressed)

# ── Risposta agli stati FSM ──────────────────────────────────────────────────

func _on_state_changed(new_state: TurnManager.State) -> void:
	DebugLogger.log_turn("GameScreen: stato → %s" % TurnManager.State.keys()[new_state])
	match new_state:
		TurnManager.State.ENEMY_DRAW:
			_player_hand_ui.interactive = false
			_player_panel.show_end_turn_button(false)
			_enemy_hand_area.visible = Config.show_enemy_hand
			if Config.animate_enemy_turn:
				_turn_label.text = "↙ Il nemico pesca..."
				_animating = true
				await get_tree().create_timer(
					Config.enemy_draw_pause * Config.animation_speed
				).timeout
				# Ora le carte sono pescate — aggiorna UI
				_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
				_refresh_deck_counts()
				_animating = false
				_turn_manager.advance_state()
			else:
				_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
				_refresh_deck_counts()

		TurnManager.State.ENEMY_PLAY:
			if Config.animate_enemy_turn:
				_turn_label.text = "↙ Il nemico ragiona..."
			else:
				_refresh_intent_panel()

		TurnManager.State.PLAYER_DRAW:
			_turn_label.text = "↗ Pesco le mie carte..."
			_refresh_hand_ui(_player_hand_ui, _player, false)
			# Nota: deck counts vengono aggiornati in PLAYER_PLAY (dopo il draw)
			if Config.animation_speed > 0.0:
				_animating = true
				var deck_node := _player_hand_area.get_node("DeckContainer/DeckRect") as Control
				var deck_pos := deck_node.global_position if is_instance_valid(deck_node) else Vector2.ZERO
				var card_uis: Array = []
				for card_data in _player.hand:
					var cui := _player_hand_ui.get_card_ui(card_data)
					if is_instance_valid(cui):
						card_uis.append(cui)
				var total_dur := _anim_mgr.animate_draw_sequence(
					card_uis, deck_pos, Config.card_draw_delay
				)
				if total_dur > 0.0:
					await get_tree().create_timer(total_dur).timeout
				_animating = false

		TurnManager.State.PLAYER_PLAY:
			var enemy_data := GameManager.get_current_enemy()
			var encounter_label := ""
			if enemy_data != null:
				encounter_label = " [%s %d/4]" % [enemy_data.type_label(), GameManager.encounter_index + 1]
			_turn_label.text = "Turno %d — Il tuo turno!%s" % [_turn_manager.turn_number, encounter_label]
			_player_hand_ui.interactive = true
			_player_panel.show_end_turn_button(true)
			_refresh_hand_ui(_player_hand_ui, _player, true)
			_refresh_actor_panels()
			_refresh_deck_counts()  # ← aggiornato DOPO il draw

		TurnManager.State.RESOLUTION:
			_turn_label.text = "Risoluzione..."
			_player_hand_ui.interactive = false
			_player_panel.show_end_turn_button(false)
			_animate_hp_next = true

		TurnManager.State.TURN_END:
			_intent_panel.reset_intents()
			_refresh_actor_panels()
			_refresh_deck_counts()

		TurnManager.State.GAME_OVER:
			_player_hand_ui.interactive = false
			_player_panel.show_end_turn_button(false)

func _on_turn_started(turn_number: int) -> void:
	_turn_label.text = "Turno %d" % turn_number
	# NON chiamare _refresh_actor_panels() qui: il tween di TURN_END deve animare
	# liberamente durante la pausa di ENEMY_DRAW (0.4s vs 1.0s di pausa).
	# NON chiamare _refresh_intent_panel(): i dati dell'attore non sono ancora
	# resettati (reset avviene in _execute_enemy_draw / _execute_player_draw).
	_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
	_refresh_hand_ui(_player_hand_ui, _player, false)
	_refresh_deck_counts()
	_intent_panel.reset_intents()

func _on_enemy_played_cards(cards: Array) -> void:
	if Config.animate_enemy_turn:
		if cards.size() > 0:
			_turn_label.text = "↙ Il nemico gioca!"
			_animating = true
			# Durante il turno nemico il giocatore non ha ancora giocato nulla:
			# i suoi intenti sono sempre 0 in questo momento.
			var zeroed_player_intents := {"damage": 0, "shield": 0, "heal": 0}
			var running_intents := {"damage": 0, "shield": 0, "heal": 0}
			for card in cards:
				running_intents["damage"] += (card as CardData).damage
				running_intents["shield"] += (card as CardData).shield
				running_intents["heal"]   += (card as CardData).heal
				_intent_panel.update_intents(zeroed_player_intents, running_intents)
				if card.damage > 0: _intent_panel.flash_intent(false, "damage")
				if card.shield > 0: _intent_panel.flash_intent(false, "shield")
				if card.heal   > 0: _intent_panel.flash_intent(false, "heal")
				DebugLogger.log_ai("Nemico gioca: %s" % card.describe())
				await get_tree().create_timer(
					Config.enemy_card_play_delay * Config.animation_speed
				).timeout
			_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
			_refresh_deck_counts()
			_animating = false
		else:
			# Nessuna carta giocata (energia 0 o mano vuota)
			_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
			_refresh_deck_counts()
			_refresh_intent_panel()
		_turn_label.text = "↙ Il nemico passa la mano..."
		await get_tree().create_timer(0.6 * Config.animation_speed).timeout
		_turn_manager.advance_state()
	else:
		_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
		_refresh_intent_panel()
		_refresh_deck_counts()

# ── Input giocatore ──────────────────────────────────────────────────────────

func _on_player_card_played(card: CardData) -> void:
	if _animating:
		return

	DebugLogger.log_card("GameScreen: giocatore gioca [%s]" % card.describe())

	# Anima il volo della carta verso i pannelli intenti
	var card_ui := _player_hand_ui.get_card_ui(card)
	if is_instance_valid(card_ui) and Config.animation_speed > 0.0:
		var intent_pos := _intent_panel.global_position + _intent_panel.size * 0.5
		# Cattura la UI prima del discard: ritardiamo il refresh
		_anim_mgr.animate_card_played(card_ui, intent_pos, func():
			_refresh_hand_ui(_player_hand_ui, _player, true)
		)

	_player.spend_energy(card.energy_cost)
	_player.add_card_intents(card)
	DeckManager.discard_card(_player, card)

	# Se no animazione, refresh immediato
	if not is_instance_valid(card_ui) or Config.animation_speed <= 0.0:
		_refresh_hand_ui(_player_hand_ui, _player, true)

	_refresh_intent_panel()
	_refresh_actor_panels()
	_refresh_deck_counts()

	if card.damage > 0: _intent_panel.flash_intent(true, "damage")
	if card.shield > 0: _intent_panel.flash_intent(true, "shield")
	if card.heal   > 0: _intent_panel.flash_intent(true, "heal")

func _on_end_turn_pressed() -> void:
	if _animating:
		return
	DebugLogger.log_turn("GameScreen: giocatore preme Fine Turno")

	# Anima le carte rimaste in mano che volano al cimitero
	if Config.animation_speed > 0.0 and _player.hand.size() > 0:
		var graveyard_node := _player_hand_area.get_node("GraveyardContainer/GraveyardRect") as Control
		var grave_pos := graveyard_node.global_position if is_instance_valid(graveyard_node) else Vector2.ZERO
		var delay := 0.0
		for card_data in _player.hand:
			var cui := _player_hand_ui.get_card_ui(card_data)
			if is_instance_valid(cui):
				_anim_mgr.animate_discard(cui, grave_pos, delay)
				delay += 0.07
		_animating = true
		await get_tree().create_timer(delay + 0.3).timeout
		_animating = false

	DeckManager.discard_hand(_player)
	_refresh_hand_ui(_player_hand_ui, _player, false)
	_refresh_deck_counts()
	_turn_manager.advance_state()

func _on_game_over(player_won: bool) -> void:
	DebugLogger.log_turn("GameScreen: game over — player_won=%s" % player_won)
	# Mostra HP finale animati e resetta intenti visivi
	_animate_hp_next = true
	_refresh_actor_panels()
	_intent_panel.reset_intents()
	_turn_label.text = "✦ VITTORIA ✦" if player_won else "✖ SCONFITTA ✖"
	# Piccola pausa per godersi l'animazione finale, poi cambia scena
	await get_tree().create_timer(1.8).timeout
	if is_inside_tree():
		if player_won:
			GameManager.complete_encounter(_turn_manager.turn_number, _player.hp)
		else:
			GameManager.fail_encounter()

# ── Tooltip ──────────────────────────────────────────────────────────────────

func _on_card_hovered(card: CardData) -> void:
	_tooltip_name.text = card.card_name
	var effects: Array[String] = []
	if card.damage > 0: effects.append("Danno: +%d" % card.damage)
	if card.shield > 0: effects.append("Scudo: +%d" % card.shield)
	if card.heal   > 0: effects.append("Guarigione: +%d" % card.heal)
	_tooltip_effects.text = "\n".join(effects)
	_tooltip_energy.text  = "ENE: %d" % card.energy_cost
	_tooltip.visible = true
	_reposition_tooltip()

func _on_card_unhovered(_card: CardData) -> void:
	_tooltip.visible = false

func _input(event: InputEvent) -> void:
	if _tooltip.visible and event is InputEventMouseMotion:
		_reposition_tooltip()

func _reposition_tooltip() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	var vp_size   := get_viewport().get_visible_rect().size
	var ts        := _tooltip.size
	var pos := mouse_pos + Vector2(14, 14)
	pos.x = clamp(pos.x, 0.0, vp_size.x - ts.x - 4.0)
	pos.y = clamp(pos.y, 0.0, vp_size.y - ts.y - 4.0)
	_tooltip.position = pos

# ── Refresh UI helpers ───────────────────────────────────────────────────────

func _refresh_all_ui() -> void:
	_refresh_actor_panels()
	_refresh_hand_ui(_enemy_hand_ui, _enemy, false)
	_refresh_hand_ui(_player_hand_ui, _player, false)
	_refresh_intent_panel()
	_refresh_deck_counts()

func _refresh_actor_panels() -> void:
	var anim := _animate_hp_next
	_animate_hp_next = false
	_enemy_panel.update_actor(_enemy, anim)
	_player_panel.update_actor(_player, anim)
	# Feedback visivo combattimento
	if anim:
		if _player.current_intents.get("damage", 0) > 0:
			_anim_mgr.animate_damage_received(_enemy_panel)
		if _enemy.current_intents.get("damage", 0) > 0:
			_anim_mgr.animate_damage_received(_player_panel)
		if _player.current_intents.get("heal", 0) > 0:
			_anim_mgr.animate_healed(_player_panel)
		if _enemy.current_intents.get("heal", 0) > 0:
			_anim_mgr.animate_healed(_enemy_panel)
		if _player.current_intents.get("shield", 0) > 0:
			_anim_mgr.animate_shield_activated(_player_panel)
		if _enemy.current_intents.get("shield", 0) > 0:
			_anim_mgr.animate_shield_activated(_enemy_panel)

func _refresh_hand_ui(hand_ui: HandUI, actor: ActorData, interactive: bool) -> void:
	hand_ui.interactive = interactive
	hand_ui.refresh_hand(actor.hand, actor.energy)

func _refresh_intent_panel() -> void:
	_intent_panel.update_intents(_player.current_intents, _enemy.current_intents)

func _refresh_deck_counts() -> void:
	_enemy_deck_count.text       = "Mazzo: %d" % _enemy.deck.size()
	_enemy_graveyard_count.text  = "Cimitero: %d" % _enemy.graveyard.size()
	_player_deck_count.text      = "Mazzo: %d" % _player.deck.size()
	_player_graveyard_count.text = "Cimitero: %d" % _player.graveyard.size()
