## DebugLogger — Logging colorato via print_rich() con BBCode
##
## Utilizzo:
##   DebugLogger.log_damage("Il nemico subisce 3 danni")
##   DebugLogger.log_turn("Inizio turno 5")
##
## Colori per categoria:
##   - danno   → rosso
##   - scudo   → blu
##   - guarigione → verde
##   - turno   → giallo
##   - carte   → cyan
##   - AI      → magenta
##   - sistema → arancione
##   - errore  → rosso brillante + bold

extends Node

const _PREFIX: String = "[b][Galactic Clash][/b]"

func log_damage(msg: String) -> void:
	print_rich("%s [color=red]⚔ DANNO[/color] %s" % [_PREFIX, msg])

func log_shield(msg: String) -> void:
	print_rich("%s [color=cornflower_blue]🛡 SCUDO[/color] %s" % [_PREFIX, msg])

func log_heal(msg: String) -> void:
	print_rich("%s [color=green]💚 GUARIGIONE[/color] %s" % [_PREFIX, msg])

func log_turn(msg: String) -> void:
	print_rich("%s [color=yellow]◆ TURNO[/color] %s" % [_PREFIX, msg])

func log_card(msg: String) -> void:
	print_rich("%s [color=cyan]🃏 CARTA[/color] %s" % [_PREFIX, msg])

func log_ai(msg: String) -> void:
	print_rich("%s [color=magenta]🤖 AI[/color] %s" % [_PREFIX, msg])

func log_system(msg: String) -> void:
	print_rich("%s [color=orange]⚙ SISTEMA[/color] %s" % [_PREFIX, msg])

func log_error(msg: String) -> void:
	print_rich("%s [color=red][b]❌ ERRORE: %s[/b][/color]" % [_PREFIX, msg])

func log_resolution(msg: String) -> void:
	print_rich("%s [color=gold][b]✨ RISOLUZIONE[/b][/color] %s" % [_PREFIX, msg])

func separator() -> void:
	print_rich("[color=dark_gray]%s[/color]" % "─".repeat(60))
