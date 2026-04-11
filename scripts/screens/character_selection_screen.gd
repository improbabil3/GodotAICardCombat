## CharacterSelectionScreen — Schermata di selezione personaggio via carosello
##
## L'utente naviga tra i 3 personaggi e ne seleziona uno.
## Dopo la selezione, passa a CardSelectionScreen.

extends Control

# ── Riferimenti UI ─────────────────────────────────────────────────────────────
@onready var _carousel_label: Label = $VBoxContainer/CarouselContainer/CarouselLabel
@onready var _prev_button: Button = $VBoxContainer/CarouselContainer/CarouselArea/PrevButton
@onready var _next_button: Button = $VBoxContainer/CarouselContainer/CarouselArea/NextButton
@onready var _character_image: Label = $VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterImage
@onready var _character_name: Label = $VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterName
@onready var _character_description: Label = $VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/CharacterDescription
@onready var _select_button: Button = $VBoxContainer/CarouselContainer/CarouselArea/CharacterPanel/CharacterInfo/SelectButton

# ── Stato ──────────────────────────────────────────────────────────────────────
var _carousel_index: int = 0

func _ready() -> void:
	DebugLogger.log_system("CharacterSelectionScreen: avvio")
	
	# Connetti pulsanti
	_prev_button.pressed.connect(_on_prev_pressed)
	_next_button.pressed.connect(_on_next_pressed)
	_select_button.pressed.connect(_on_select_pressed)
	
	# Mostra primo personaggio
	_update_carousel_display()


func _update_carousel_display() -> void:
	var char := CharacterManager.get_character(_carousel_index)
	_character_name.text = char.name
	_character_description.text = char.description
	_character_image.text = "[%s]" % char.character_id.to_upper()

func _on_prev_pressed() -> void:
	_carousel_index = (_carousel_index - 1 + CharacterManager.characters.size()) % CharacterManager.characters.size()
	_update_carousel_display()

func _on_next_pressed() -> void:
	_carousel_index = (_carousel_index + 1) % CharacterManager.characters.size()
	_update_carousel_display()

func _on_select_pressed() -> void:
	var selected_char := CharacterManager.get_character(_carousel_index)
	CharacterManager.set_selected_character(_carousel_index)
	DebugLogger.log_system("CharacterSelectionScreen: selezionato %s" % selected_char.name)
	
	# Vai a CardSelectionScreen
	GameManager.start_card_selection()
