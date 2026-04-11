## IntentPanelUI — Visualizza gli intenti accumulati da nemico e giocatore

class_name IntentPanelUI
extends PanelContainer

@onready var _enemy_damage_label: Label  = $HBox/EnemyIntents/DamageLabel
@onready var _enemy_shield_label: Label  = $HBox/EnemyIntents/ShieldLabel
@onready var _enemy_heal_label: Label    = $HBox/EnemyIntents/HealLabel
@onready var _player_damage_label: Label = $HBox/PlayerIntents/DamageLabel
@onready var _player_shield_label: Label = $HBox/PlayerIntents/ShieldLabel
@onready var _player_heal_label: Label   = $HBox/PlayerIntents/HealLabel

## Aggiorna i contatori di entrambi gli attori
func update_intents(player_intents: Dictionary, enemy_intents: Dictionary) -> void:
	_enemy_damage_label.text  = "⚔ DAN: %d" % enemy_intents.get("damage", 0)
	_enemy_shield_label.text  = "🛡 SCU: %d" % enemy_intents.get("shield", 0)
	_enemy_heal_label.text    = "💚 GUA: %d" % enemy_intents.get("heal", 0)

	_player_damage_label.text = "⚔ DAN: %d" % player_intents.get("damage", 0)
	_player_shield_label.text = "🛡 SCU: %d" % player_intents.get("shield", 0)
	_player_heal_label.text   = "💚 GUA: %d" % player_intents.get("heal", 0)

## Flash su un contatore specifico quando viene aggiornato
func flash_intent(actor_is_player: bool, type: String) -> void:
	var label := _get_label(actor_is_player, type)
	if label == null:
		return
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color(2.0, 2.0, 0.5), 0.1)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2)

## Resetta tutti i contatori a 0 visivamente
func reset_intents() -> void:
	update_intents({"damage": 0, "shield": 0, "heal": 0}, {"damage": 0, "shield": 0, "heal": 0})

func _get_label(is_player: bool, type: String) -> Label:
	match type:
		"damage": return _player_damage_label if is_player else _enemy_damage_label
		"shield": return _player_shield_label if is_player else _enemy_shield_label
		"heal":   return _player_heal_label   if is_player else _enemy_heal_label
	return null
