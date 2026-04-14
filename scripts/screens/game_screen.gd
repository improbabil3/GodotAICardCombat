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
@onready var _top_margin: Control          = $TopMargin
@onready var _action_bar: HBoxContainer    = $ActionBar
@onready var _turn_label: Label            = $ActionBar/TurnLabel
@onready var _end_turn_button: Button      = $ActionBar/EndTurnButton
@onready var _background: Control          = $Background
@onready var _tooltip: PanelContainer      = $CardTooltip
@onready var _tooltip_box: VBoxContainer   = $CardTooltip/TooltipVBox
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

# Stato tooltip
var _tooltip_anchor_card: CardData = null
var _tooltip_anchor_to_card: bool = false

func _ready() -> void:
	_setup_actors()
	_setup_ui_references()
	_setup_tooltip_overlay.call_deferred()
	_connect_ui_signals()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_responsive_layout()
	_anim_mgr = AnimationManager.new()
	_turn_manager = TurnManager.new()
	_turn_manager.setup(_player, _enemy)
	_turn_manager.state_changed.connect(_on_state_changed)
	_turn_manager.turn_started.connect(_on_turn_started)
	_turn_manager.enemy_played_cards.connect(_on_enemy_played_cards)
	_turn_manager.game_over.connect(_on_game_over)
	_turn_manager.status_damage.connect(_on_status_damage)
	_turn_manager.status_energy_changed.connect(_on_status_energy_changed)
	_turn_manager.status_applied.connect(_on_status_applied_or_expired)
	_turn_manager.status_expired.connect(_on_status_applied_or_expired)
	# Aggiornamento UI iniziale
	_refresh_all_ui()
	# Avvia il gioco dopo un frame (per sicurezza che la UI sia pronta)
	call_deferred("_start_game")

func _start_game() -> void:
	_turn_manager.start()


func _on_viewport_size_changed() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if _uses_mobile_layout(viewport_size):
		_apply_mobile_layout(viewport_size)
	else:
		_apply_desktop_layout(viewport_size)


func _uses_mobile_layout(viewport_size: Vector2) -> bool:
	return OS.has_feature("mobile") or viewport_size.x <= 900.0 or viewport_size.y <= 720.0


func _apply_mobile_layout(viewport_size: Vector2) -> void:
	var portrait_layout: bool = viewport_size.y > viewport_size.x
	var panel_height: float = clampf(viewport_size.y * (0.14 if portrait_layout else 0.10), 84.0 if portrait_layout else 68.0, 112.0)
	var hand_card_width: float = 0.0
	var hand_card_height: float = 0.0
	var enemy_hand_height: float = 0.0
	var player_hand_height: float = 0.0
	if portrait_layout:
		hand_card_width = clampf(viewport_size.x * 0.27, 164.0, 196.0)
		hand_card_height = Config.get_combat_card_height(hand_card_width)
		enemy_hand_height = clampf(hand_card_height * 0.30, 74.0, 88.0)
		player_hand_height = clampf(hand_card_height + 4.0, 250.0, 300.0)
	else:
		hand_card_width = clampf(viewport_size.x * 0.27, 180.0, 240.0)
		hand_card_height = Config.get_combat_card_height(hand_card_width)
		enemy_hand_height = clampf(hand_card_height * 0.28, 62.0, 78.0)
		player_hand_height = clampf(hand_card_height + 2.0, 239.0, 281.0)
	var intent_height: float = clampf(viewport_size.y * 0.13, 72.0, 92.0)
	_apply_layout_values({
		"mode_label": "mobile_portrait" if portrait_layout else "mobile_landscape",
		"viewport_size": viewport_size,
		"compact_touch_ui": true,
		"panel_height": panel_height,
		"hand_card_size": Vector2(hand_card_width, hand_card_height),
		"enemy_hand_height": enemy_hand_height,
		"player_hand_height": player_hand_height,
		"intent_height": intent_height,
	})


func _apply_desktop_layout(viewport_size: Vector2) -> void:
	var panel_height: float = clampf(viewport_size.y * 0.11, 86.0, 112.0)
	var hand_card_width: float = clampf(viewport_size.x * 0.135, 160.0, 228.0)
	var hand_card_height: float = Config.get_combat_card_height(hand_card_width)
	var enemy_hand_height: float = clampf(hand_card_height + 42.0, 170.0, 300.0)
	var intent_height: float = clampf(viewport_size.y * 0.11, 76.0, 108.0)
	_apply_layout_values({
		"mode_label": "desktop",
		"viewport_size": viewport_size,
		"compact_touch_ui": false,
		"panel_height": panel_height,
		"hand_card_size": Vector2(hand_card_width, hand_card_height),
		"enemy_hand_height": enemy_hand_height,
		"player_hand_height": enemy_hand_height,
		"intent_height": intent_height,
	})


func _apply_layout_values(config: Dictionary) -> void:
	var viewport_size: Vector2 = config["viewport_size"]
	var compact_touch_ui: bool = config["compact_touch_ui"]
	var panel_height: float = config["panel_height"]
	var hand_card_size: Vector2 = config["hand_card_size"]
	var enemy_hand_height: float = config["enemy_hand_height"]
	var player_hand_height: float = config["player_hand_height"]
	var intent_height: float = config["intent_height"]

	custom_minimum_size = Vector2.ZERO
	position = Vector2.ZERO
	_background.position = Vector2.ZERO
	_background.size = viewport_size
	add_theme_constant_override("separation", 4 if compact_touch_ui else 10)
	_top_margin.custom_minimum_size.y = 2.0 if compact_touch_ui else 10.0
	_action_bar.custom_minimum_size.y = 44.0 if compact_touch_ui else 52.0
	_action_bar.add_theme_constant_override("separation", 8 if compact_touch_ui else 16)
	_turn_label.custom_minimum_size = Vector2(0.0, 56.0 if compact_touch_ui else 46.0)
	_turn_label.add_theme_font_size_override("font_size", 18 if compact_touch_ui else (20 if viewport_size.x >= 1200.0 else 16))
	_end_turn_button.custom_minimum_size = Vector2(clampf(viewport_size.x * (0.26 if compact_touch_ui else 0.18), 172.0 if compact_touch_ui else 180.0, 240.0 if compact_touch_ui else 220.0), 44.0 if compact_touch_ui else 46.0)
	_end_turn_button.add_theme_font_size_override("font_size", 16)
	_enemy_panel.custom_minimum_size.y = panel_height
	_player_panel.custom_minimum_size.y = panel_height
	_enemy_panel.apply_layout(compact_touch_ui, panel_height)
	_player_panel.apply_layout(compact_touch_ui, panel_height)
	_enemy_hand_area.size_flags_vertical = 3
	_player_hand_area.size_flags_vertical = 3
	_enemy_hand_area.custom_minimum_size.y = enemy_hand_height
	_player_hand_area.custom_minimum_size.y = player_hand_height
	_apply_hand_area_layout(_enemy_hand_area, compact_touch_ui, hand_card_size)
	_apply_hand_area_layout(_player_hand_area, compact_touch_ui, hand_card_size)
	if _enemy_hand_ui != null:
		_enemy_hand_ui.set_card_size(hand_card_size)
	if _player_hand_ui != null:
		_player_hand_ui.set_card_size(hand_card_size)
	_intent_panel.custom_minimum_size.y = intent_height
	_intent_panel.apply_layout(compact_touch_ui, intent_height)
	_tooltip.custom_minimum_size = Vector2(280.0 if compact_touch_ui else 210.0, 0.0)
	_tooltip_name.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 12)
	_tooltip_effects.add_theme_font_size_override("font_size", 17 if compact_touch_ui else 12)
	_tooltip_energy.add_theme_font_size_override("font_size", 17 if compact_touch_ui else 12)
	DebugLogger.log_system("GameScreen[%s]: viewport=%s hand=%s panels=%f intent=%f" % [config["mode_label"], viewport_size, hand_card_size, panel_height, intent_height])


func _apply_hand_area_layout(hand_area: HBoxContainer, compact_touch_ui: bool, card_size: Vector2) -> void:
	var side_width := 72.0 if compact_touch_ui else 80.0
	var pile_width := clampf(card_size.x * (0.46 if compact_touch_ui else 0.50), 58.0 if compact_touch_ui else 84.0, 96.0 if compact_touch_ui else 118.0)
	var pile_height := clampf(card_size.y * (0.52 if compact_touch_ui else 0.58), 88.0 if compact_touch_ui else 110.0, 126.0 if compact_touch_ui else 170.0)
	hand_area.add_theme_constant_override("separation", 10 if compact_touch_ui else 12)
	var hand_container := hand_area.get_node("HandContainer") as HBoxContainer
	if hand_container != null:
		hand_container.add_theme_constant_override("separation", 8 if compact_touch_ui else 8)
	var deck_container := hand_area.get_node("DeckContainer") as VBoxContainer
	var deck_rect := hand_area.get_node("DeckContainer/DeckRect") as Control
	var deck_label := hand_area.get_node("DeckContainer/DeckRect/DeckLabel") as Label
	var deck_count := hand_area.get_node("DeckContainer/DeckCount") as Label
	var graveyard_container := hand_area.get_node("GraveyardContainer") as VBoxContainer
	var graveyard_rect := hand_area.get_node("GraveyardContainer/GraveyardRect") as Control
	var graveyard_label := hand_area.get_node("GraveyardContainer/GraveyardRect/GraveyardLabel") as Label
	var graveyard_count := hand_area.get_node("GraveyardContainer/GraveyardCount") as Label
	deck_container.custom_minimum_size.x = side_width
	graveyard_container.custom_minimum_size.x = side_width
	deck_rect.custom_minimum_size = Vector2(pile_width, pile_height)
	graveyard_rect.custom_minimum_size = Vector2(pile_width, pile_height)
	deck_label.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 14)
	graveyard_label.add_theme_font_size_override("font_size", 18 if compact_touch_ui else 14)
	deck_count.add_theme_font_size_override("font_size", 13 if compact_touch_ui else 14)
	graveyard_count.add_theme_font_size_override("font_size", 13 if compact_touch_ui else 14)

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


func _setup_tooltip_overlay() -> void:
	var overlay_parent := get_parent() as Control
	if overlay_parent == null or _tooltip.get_parent() != self:
		return
	remove_child(_tooltip)
	overlay_parent.add_child(_tooltip)
	overlay_parent.move_child(_tooltip, overlay_parent.get_child_count() - 1)
	_tooltip.anchor_left = 0.0
	_tooltip.anchor_top = 0.0
	_tooltip.anchor_right = 0.0
	_tooltip.anchor_bottom = 0.0
	_tooltip.offset_left = 0.0
	_tooltip.offset_top = 0.0
	_tooltip.offset_right = 0.0
	_tooltip.offset_bottom = 0.0
	_tooltip.visible = false
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip.position = Vector2.ZERO

func _connect_ui_signals() -> void:
	_player_hand_ui.card_played_from_hand.connect(_on_player_card_played)
	_player_hand_ui.card_secondary_clicked_in_hand.connect(_on_card_secondary_clicked)
	_player_hand_ui.card_hovered_in_hand.connect(_on_card_hovered)
	_player_hand_ui.card_unhovered_in_hand.connect(_on_card_unhovered)
	_player_hand_ui.card_long_pressed_in_hand.connect(_on_card_long_pressed)
	_player_hand_ui.card_long_press_released_in_hand.connect(_on_card_long_press_released)
	_end_turn_button.pressed.connect(_on_end_turn_pressed)

# ── Risposta agli stati FSM ──────────────────────────────────────────────────

func _on_state_changed(new_state: TurnManager.State) -> void:
	DebugLogger.log_turn("GameScreen: stato → %s" % TurnManager.State.keys()[new_state])
	match new_state:
		TurnManager.State.STATUS_START:
			_turn_label.text = "⚠ Effetti di stato..."
			_refresh_actor_panels()

		TurnManager.State.ENEMY_DRAW:
			_player_hand_ui.interactive = false
			_end_turn_button.visible = false
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
			_end_turn_button.visible = true
			_refresh_hand_ui(_player_hand_ui, _player, true)
			_refresh_actor_panels()
			_refresh_deck_counts()  # ← aggiornato DOPO il draw

		TurnManager.State.RESOLUTION:
			_turn_label.text = "Risoluzione..."
			_player_hand_ui.interactive = false
			_end_turn_button.visible = false
			_animate_hp_next = true

		TurnManager.State.TURN_END:
			_intent_panel.reset_intents()
			_refresh_actor_panels()
			_refresh_deck_counts()

		TurnManager.State.GAME_OVER:
			_player_hand_ui.interactive = false
			_end_turn_button.visible = false

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

	# Applica effetto di stato della carta (aggiorna actor + emette segnali TurnManager)
	if card.has_status_effect():
		_turn_manager.apply_player_card_status(card)
		_refresh_actor_panels()  # aggiorna statuslabel subito

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
	if _is_touch_tooltip_mode():
		_show_tooltip(card, true)


func _on_card_long_pressed(card: CardData) -> void:
	_show_tooltip(card, true)


func _on_card_secondary_clicked(card: CardData) -> void:
	if _is_touch_tooltip_mode():
		return
	if _tooltip.visible and _tooltip_anchor_card == card:
		_hide_tooltip()
		return
	_show_tooltip(card, true)


func _show_tooltip(card: CardData, anchor_to_card: bool) -> void:
	_tooltip_anchor_card = card
	_tooltip_anchor_to_card = anchor_to_card or _is_touch_tooltip_mode()
	var tooltip_width := 250.0 if _is_touch_tooltip_mode() else 210.0
	var text_width := tooltip_width - 16.0
	_tooltip_name.text = card.card_name
	var effects: Array[String] = []
	if card.damage > 0: effects.append("Danno: +%d" % card.damage)
	if card.shield > 0: effects.append("Scudo: +%d" % card.shield)
	if card.heal   > 0: effects.append("Guarigione: +%d" % card.heal)
	if card.status_effect != "":
		var tgt := "sé stesso" if card.status_target == "self" else "avversario"
		effects.append("Stato: %s → %s" % [card.status_effect.to_upper(), tgt])
	var effects_text := "\n".join(effects)
	_tooltip_effects.text = effects_text
	_tooltip_energy.text  = "ENE: %d" % card.energy_cost
	var title_height := _estimate_tooltip_text_block_height(card.card_name, text_width, 18.0)
	var effects_height := _estimate_tooltip_text_block_height(effects_text, text_width, 17.0)
	var energy_height := 18.0
	var content_height := title_height + effects_height + energy_height + 8.0
	var panel_height := content_height + 16.0
	_tooltip.custom_minimum_size = Vector2(tooltip_width, panel_height)
	_tooltip_box.custom_minimum_size = Vector2(text_width, content_height)
	_tooltip_name.custom_minimum_size = Vector2(text_width, title_height)
	_tooltip_effects.custom_minimum_size = Vector2(text_width, effects_height)
	_tooltip_energy.custom_minimum_size = Vector2(text_width, energy_height)
	_tooltip.visible = true
	_tooltip.size = Vector2(tooltip_width, panel_height)
	_reposition_tooltip()
	call_deferred("_finalize_tooltip_geometry", tooltip_width, panel_height)

func _on_card_unhovered(_card: CardData) -> void:
	if _is_touch_tooltip_mode():
		_hide_tooltip()


func _on_card_long_press_released(_card: CardData) -> void:
	_hide_tooltip()

func _input(event: InputEvent) -> void:
	if _tooltip.visible and not _tooltip_anchor_to_card and event is InputEventMouseMotion:
		_reposition_tooltip()
	elif _tooltip.visible and not _is_touch_tooltip_mode() and event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_hide_tooltip()


func _is_touch_tooltip_mode() -> bool:
	return OS.has_feature("mobile")


func _estimate_tooltip_text_block_height(text: String, text_width: float, line_height: float) -> float:
	var chars_per_line := maxi(12, int(text_width / 7.5))
	var line_count := 0
	for paragraph in text.split("\n"):
		line_count += maxi(1, int(ceili(float(maxi(paragraph.length(), 1)) / float(chars_per_line))))
	return float(maxi(1, line_count)) * line_height


func _finalize_tooltip_geometry(tooltip_width: float, panel_height: float) -> void:
	if not _tooltip.visible:
		return
	_tooltip.size = Vector2(tooltip_width, panel_height)
	_reposition_tooltip()


func _hide_tooltip() -> void:
	_tooltip_anchor_card = null
	_tooltip_anchor_to_card = false
	_tooltip.visible = false

func _reposition_tooltip() -> void:
	var vp_size   := get_viewport().get_visible_rect().size
	var ts        := _tooltip.size
	var pos := Vector2.ZERO
	if _tooltip_anchor_to_card and _tooltip_anchor_card != null:
		var card_ui := _player_hand_ui.get_card_ui(_tooltip_anchor_card)
		if is_instance_valid(card_ui):
			pos = Vector2(
				card_ui.global_position.x + (card_ui.size.x - ts.x) * 0.5,
				card_ui.global_position.y - ts.y - 12.0
			)
			if pos.y < 8.0:
				pos.y = card_ui.global_position.y + card_ui.size.y + 12.0
			if _is_touch_tooltip_mode() and pos.y + ts.y > vp_size.y - 12.0:
				pos.y = clamp(card_ui.global_position.y - ts.y - 12.0, 12.0, vp_size.y - ts.y - 12.0)
		else:
			pos = Vector2((vp_size.x - ts.x) * 0.5, (vp_size.y - ts.y) * 0.5)
	else:
		var mouse_pos := get_viewport().get_mouse_position()
		pos = mouse_pos + Vector2(14, 14)
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
	_enemy_panel.update_status_effects(_enemy.status_effects)
	_player_panel.update_status_effects(_player.status_effects)
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
	if OS.has_feature("mobile"):
		_enemy_deck_count.text       = "M %d" % _enemy.deck.size()
		_enemy_graveyard_count.text  = "C %d" % _enemy.graveyard.size()
		_player_deck_count.text      = "M %d" % _player.deck.size()
		_player_graveyard_count.text = "C %d" % _player.graveyard.size()
	else:
		_enemy_deck_count.text       = "Mazzo: %d" % _enemy.deck.size()
		_enemy_graveyard_count.text  = "Cimitero: %d" % _enemy.graveyard.size()
		_player_deck_count.text      = "Mazzo: %d" % _player.deck.size()
		_player_graveyard_count.text = "Cimitero: %d" % _player.graveyard.size()

# ── Gestione segnali status effect ──────────────────────────────────────────

func _on_status_damage(actor_name: String, effect_name: String, _amount: int) -> void:
	var panel := _enemy_panel if actor_name == _enemy.actor_name else _player_panel
	_anim_mgr.animate_status_damage(panel, effect_name)
	_refresh_actor_panels()

func _on_status_energy_changed(actor_name: String, effect_name: String, _delta: int) -> void:
	var panel := _enemy_panel if actor_name == _enemy.actor_name else _player_panel
	_anim_mgr.animate_status_energy_changed(panel, effect_name)
	_refresh_actor_panels()

func _on_status_applied_or_expired(_actor_name: String, _effect_name: String) -> void:
	_refresh_actor_panels()
