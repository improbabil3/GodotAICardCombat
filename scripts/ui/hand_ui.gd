## HandUI — Gestisce la visualizzazione della mano di un attore
##
## Gestisce la creazione/rimozione dei CardUI nodes nella mano.
## Emette segnali click carta per permettere a GameScreen di gestire la logica.

class_name HandUI
extends HBoxContainer

signal card_played_from_hand(card: CardData)
signal card_secondary_clicked_in_hand(card: CardData)
signal card_hovered_in_hand(card: CardData)
signal card_unhovered_in_hand(card: CardData)
signal card_long_pressed_in_hand(card: CardData)
signal card_long_press_released_in_hand(card: CardData)

## Se false, le carte non sono cliccabili (mano nemico, o fuori turno)
var interactive: bool = false

# Se false, i dettagli delle carte non sono visibili
var show_card_details: bool = true

## Riferimento all'attore proprietario (per sapere energia disponibile)
var actor: ActorData = null

## Dimensione visuale delle carte nella mano
var card_size: Vector2 = Vector2(176, 236)

## Mappa CardData → CardUI node
var _card_ui_map: Dictionary = {}

## Prefab carta (caricato una volta)
const CARD_SCENE := preload("res://scenes/card/card.tscn")

func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 8)

## Aggiorna la visualizzazione della mano con le carte fornite
func refresh_hand(cards: Array[CardData], current_energy: int) -> void:
	clear_hand()

	# Ricrea l'intera mano per evitare transform/layout sporchi dopo le animazioni.
	for card_data in cards:
		var card_ui: CardUI = CARD_SCENE.instantiate()
		add_child(card_ui)
		card_ui.show_card_details = show_card_details
		card_ui.setup(card_data as CardData)
		card_ui.apply_layout(card_size)
		_card_ui_map[card_data] = card_ui
		card_ui.card_clicked.connect(_on_card_clicked)
		card_ui.card_secondary_clicked.connect(func(c): card_secondary_clicked_in_hand.emit(c))
		card_ui.card_hovered.connect(func(c): card_hovered_in_hand.emit(c))
		card_ui.card_unhovered.connect(func(c): card_unhovered_in_hand.emit(c))
		card_ui.card_long_pressed.connect(func(c): card_long_pressed_in_hand.emit(c))
		card_ui.card_long_press_released.connect(func(c): card_long_press_released_in_hand.emit(c))

	# Aggiorna lo stato giocabile di tutte le carte
	update_playable_states(current_energy)
	for card_ui in _card_ui_map.values():
		(card_ui as CardUI).apply_layout(card_size)
	queue_sort()


func set_card_size(new_size: Vector2) -> void:
	card_size = new_size
	for card_ui in _card_ui_map.values():
		(card_ui as CardUI).apply_layout(card_size)

## Aggiorna quale carta è giocabile in base all'energia disponibile
func update_playable_states(current_energy: int) -> void:
	for card_data in _card_ui_map.keys():
		var card_ui: CardUI = _card_ui_map[card_data]
		var playable := interactive and (current_energy >= (card_data as CardData).energy_cost)
		card_ui.set_playable(playable)

## Pulisce tutta la mano (usato per cambio stato o fine partita)
func clear_hand() -> void:
	for card_ui in _card_ui_map.values():
		(card_ui as CardUI).queue_free()
	_card_ui_map.clear()

## Ritorna il nodo CardUI corrispondente a un CardData
func get_card_ui(card_data: CardData) -> CardUI:
	return _card_ui_map.get(card_data, null)

func _on_card_clicked(card: CardData) -> void:
	if interactive and actor != null and actor.can_play(card):
		card_played_from_hand.emit(card)
