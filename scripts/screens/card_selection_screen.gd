## CardSelectionScreen — Schermata di selezione carte specifiche del personaggio
##
## L'utente sceglie esattamente 10 carte dal pool di 20 specifiche del personaggio.
## Le altre 10 carte verranno scelte casualmente dal mazzo base.

extends Control

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _character_name_card: Label = $VBoxContainer/TopBar/CharacterInfoLeft/CharacterNameCard
@onready var _character_description_card: Label = $VBoxContainer/TopBar/CharacterInfoLeft/CharacterDescriptionCard
@onready var _selection_counter: Label = $VBoxContainer/TopBar/SelectionCounter
@onready var _card_grid: GridContainer = $VBoxContainer/CardGridScroll/CardGrid
@onready var _confirm_button: Button = $VBoxContainer/BottomBar/ConfirmButton
@onready var _back_button: Button = $VBoxContainer/BottomBar/BackButton

# ── Stato ──────────────────────────────────────────────────────────────────────
var _selected_character: CharacterData = null
var _base_cards: Array[CardData] = []
var _selected_specific_cards: Array[CardData] = []
var _card_buttons: Array[Button] = []

func _ready() -> void:
	DebugLogger.log_system("CardSelectionScreen: avvio")
	
	# Recupera il personaggio selezionato
	_selected_character = CharacterManager.get_selected_character()
	if not _selected_character:
		DebugLogger.log_error("CardSelectionScreen: nessun personaggio selezionato!")
		return
	
	# Carica il mazzo base
	_base_cards = DeckLoader.load_deck("res://data/deck_player.json")
	
	# Calcola le dimensioni responsive della griglia in base al viewport
	var viewport_size := get_viewport_rect().size
	var reserved_height := 80.0 + 30.0 + 50.0  # TopBar + TitleLabel + BottomBar in pixel
	var available_height := viewport_size.y - reserved_height - 40.0  # meno margin top e bottom (20+20)
	var available_width := viewport_size.x - 40.0  # meno margin left e right (20+20)
	
	# Imposta il CardGridScroll con custom_minimum_size calcolato dinamicamente
	var scroll_container = _card_grid.get_parent()
	scroll_container.custom_minimum_size = Vector2(available_width, available_height)
	DebugLogger.log_system("CardSelectionScreen: viewport %s, calcolato ScrollContainer min_size = (%f, %f)" % [viewport_size, available_width, available_height])
	
	# Connetti pulsanti
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	
	# Mostra il personaggio e crea i bottoni
	_update_character_info()
	_create_card_buttons()

func _update_character_info() -> void:
	_character_name_card.text = _selected_character.name
	_character_description_card.text = _selected_character.description
	_update_counter()

func _create_card_buttons() -> void:
	DebugLogger.log_system("CardSelectionScreen: creazione bottoni per %d carte" % _selected_character.specific_cards.size())
	
	# Pulisci griglia
	for child in _card_grid.get_children():
		child.queue_free()
	_card_buttons.clear()
	_selected_specific_cards.clear()
	
	# Attendi un frame per assicurare pulizia
	await get_tree().process_frame
	
	DebugLogger.log_system("CardSelectionScreen: CardGrid children prima: %d" % _card_grid.get_child_count())
	
	# Crea un bottone per ogni carta
	for card in _selected_character.specific_cards:
		var btn := _create_single_card_button(card)
		_card_grid.add_child(btn)
		_card_buttons.append(btn)
		DebugLogger.log_card("CardSelectionScreen: bottone aggiunto per %s, total: %d" % [card.card_name, _card_grid.get_child_count()])
	
	DebugLogger.log_system("CardSelectionScreen: creati %d bottoni, grid children: %d" % [_card_buttons.size(), _card_grid.get_child_count()])
	DebugLogger.log_system("CardSelectionScreen: CardGrid size: %s, visible: %s" % [_card_grid.size, _card_grid.visible])

func _create_single_card_button(card: CardData) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(120, 140)
	btn.text = "%s\nD:%d S:%d H:%d\nE:%d" % [
		card.card_name.substr(0, 12), card.damage, card.shield, card.heal, card.energy_cost
	]
	btn.modulate = Color.WHITE
	btn.clip_text = true
	btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	btn.pressed.connect(_on_card_button_pressed.bindv([card, btn]))
	return btn

func _on_card_button_pressed(card: CardData, btn: Button) -> void:
	if card in _selected_specific_cards:
		# Deseleziona
		_selected_specific_cards.erase(card)
		btn.modulate = Color.WHITE
		DebugLogger.log_card("CardSelectionScreen: deselezionata %s (totale: %d)" % [card.card_name, _selected_specific_cards.size()])
	else:
		# Seleziona solo se non abbiamo già 10
		if _selected_specific_cards.size() < 10:
			_selected_specific_cards.append(card)
			btn.modulate = Color.YELLOW
			DebugLogger.log_card("CardSelectionScreen: selezionata %s (totale: %d)" % [card.card_name, _selected_specific_cards.size()])
	
	_update_counter()

func _update_counter() -> void:
	_selection_counter.text = "%d / 10" % _selected_specific_cards.size()
	_confirm_button.disabled = _selected_specific_cards.size() != 10

func _on_confirm_pressed() -> void:
	if _selected_specific_cards.size() != 10:
		DebugLogger.log_error("CardSelectionScreen: deve selezionare esattamente 10 carte, ne hai scelte %d" % _selected_specific_cards.size())
		return
	
	# Costruisci il mazzo finale: 10 specifiche + 10 base random
	var final_deck: Array[CardData] = []
	final_deck.append_array(_selected_specific_cards)
	
	# Copia il mazzo base e mescola
	var base_copy := _base_cards.duplicate()
	DeckManager.shuffle_deck(base_copy)
	
	# Prendi i primi 10 dal mazzo mescolato
	for i in range(10):
		if i < base_copy.size():
			final_deck.append(base_copy[i])
	
	# Salva nel GameManager e inizia il gioco
	GameManager.selected_character = _selected_character
	GameManager.player_deck = final_deck
	
	DebugLogger.log_system("CardSelectionScreen: mazzo costruito — 10 specifiche + 10 base random = %d carte" % final_deck.size())
	GameManager.start_game()

func _on_back_pressed() -> void:
	DebugLogger.log_system("CardSelectionScreen: ritorno al carosello personaggi")
	GameManager.start_character_selection()
