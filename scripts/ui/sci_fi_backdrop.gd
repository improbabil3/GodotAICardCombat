@tool
## SciFiBackdrop — Sfondo procedurale riusabile per schermate e board
##
## Disegna gradienti, griglie e accenti sci-fi senza dipendere da asset esterni.

class_name SciFiBackdrop
extends Control

# ── Tipi ────────────────────────────────────────────────────────────────────
enum Variant {
	TITLE,
	BATTLE,
	RESULT,
	VICTORY,
	DEFEAT,
	SELECTION,
}

# ── Costanti ────────────────────────────────────────────────────────────────
const ASSET_ROOT := "res://assets/images/ui"
const FRAME_MARGIN := 26.0
const FRAME_LENGTH := 54.0

# ── Export / variabili pubbliche ────────────────────────────────────────────
@export var variant: Variant = Variant.TITLE:
	set(value):
		variant = value
		_clear_texture_cache()
		queue_redraw()

@export var grid_size: float = 84.0:
	set(value):
		grid_size = max(value, 32.0)
		queue_redraw()

@export var accent_strength: float = 1.0:
	set(value):
		accent_strength = clampf(value, 0.2, 2.0)
		queue_redraw()

# ── Variabili private ───────────────────────────────────────────────────────
var _texture_cache: Texture2D = null
var _texture_cache_key: String = ""

# ── Metodi pubblici ─────────────────────────────────────────────────────────
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	var palette := _get_palette()
	var backdrop_texture := _resolve_backdrop_texture()
	if backdrop_texture != null:
		draw_texture_rect(backdrop_texture, rect, false)
		draw_rect(rect, Color(0.01, 0.03, 0.08, 0.34), true)
	else:
		_draw_gradient(rect, palette.bg_top, palette.bg_bottom)
	_draw_energy_band(rect, palette.glow_a, palette.glow_b)
	_draw_grid(rect, palette.grid)
	_draw_glows(rect, palette.accent, palette.accent_soft)
	_draw_frame(rect, palette.accent)


# ── Metodi privati ──────────────────────────────────────────────────────────
func _draw_gradient(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(points, colors)


func _draw_energy_band(rect: Rect2, glow_a: Color, glow_b: Color) -> void:
	var band_top := rect.size.y * 0.26
	var band_bottom := rect.size.y * 0.72
	var points := PackedVector2Array([
		Vector2(rect.size.x * -0.10, band_bottom),
		Vector2(rect.size.x * 0.48, band_top),
		Vector2(rect.size.x * 1.08, band_top + rect.size.y * 0.10),
		Vector2(rect.size.x * 0.42, band_bottom + rect.size.y * 0.12),
	])
	var colors := PackedColorArray([
		glow_b,
		glow_a,
		glow_b,
		Color(glow_a.r, glow_a.g, glow_a.b, glow_a.a * 0.45),
	])
	draw_polygon(points, colors)


func _draw_grid(rect: Rect2, line_color: Color) -> void:
	var x := 0.0
	while x <= rect.size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, rect.size.y), line_color, 1.0)
		x += grid_size

	var y := 0.0
	while y <= rect.size.y:
		draw_line(Vector2(0.0, y), Vector2(rect.size.x, y), line_color, 1.0)
		y += grid_size


func _draw_glows(rect: Rect2, accent: Color, accent_soft: Color) -> void:
	var left_center := Vector2(rect.size.x * 0.14, rect.size.y * 0.24)
	var right_center := Vector2(rect.size.x * 0.86, rect.size.y * 0.76)
	var large_radius: float = minf(rect.size.x, rect.size.y) * 0.22
	var small_radius: float = large_radius * 0.58
	draw_circle(left_center, large_radius, accent_soft)
	draw_circle(right_center, large_radius, Color(accent_soft.r, accent_soft.g, accent_soft.b, accent_soft.a * 0.75))
	draw_circle(left_center, small_radius, Color(accent.r, accent.g, accent.b, accent.a * 0.18 * accent_strength))
	draw_circle(right_center, small_radius, Color(accent.r, accent.g, accent.b, accent.a * 0.14 * accent_strength))


func _draw_frame(rect: Rect2, accent: Color) -> void:
	var margin := FRAME_MARGIN
	var length := FRAME_LENGTH
	var top_left := Vector2(margin, margin)
	var top_right := Vector2(rect.size.x - margin, margin)
	var bottom_left := Vector2(margin, rect.size.y - margin)
	var bottom_right := Vector2(rect.size.x - margin, rect.size.y - margin)
	var frame_color := Color(accent.r, accent.g, accent.b, 0.72 * accent_strength)

	_draw_corner(top_left, Vector2.RIGHT, Vector2.DOWN, length, frame_color)
	_draw_corner(top_right, Vector2.LEFT, Vector2.DOWN, length, frame_color)
	_draw_corner(bottom_left, Vector2.RIGHT, Vector2.UP, length, frame_color)
	_draw_corner(bottom_right, Vector2.LEFT, Vector2.UP, length, frame_color)


func _draw_corner(origin: Vector2, horizontal: Vector2, vertical: Vector2, length: float, color: Color) -> void:
	draw_line(origin, origin + horizontal * length, color, 3.0)
	draw_line(origin, origin + vertical * length, color, 3.0)


func _clear_texture_cache() -> void:
	_texture_cache = null
	_texture_cache_key = ""


func _resolve_backdrop_texture() -> Texture2D:
	var variant_key := _variant_key()
	if _texture_cache_key == variant_key:
		return _texture_cache

	_texture_cache_key = variant_key
	_texture_cache = null
	var candidates := [
		"%s/%s.png" % [ASSET_ROOT, variant_key],
		"%s/backdrop_%s.png" % [ASSET_ROOT, variant_key],
	]
	for path in candidates:
		if ResourceLoader.exists(path, "Texture2D"):
			_texture_cache = load(path) as Texture2D
			break
	return _texture_cache


func _variant_key() -> String:
	match variant:
		Variant.BATTLE:
			return "battle"
		Variant.RESULT:
			return "result"
		Variant.VICTORY:
			return "victory"
		Variant.DEFEAT:
			return "defeat"
		Variant.SELECTION:
			return "selection"
		_:
			return "title"


func _get_palette() -> Dictionary:
	match variant:
		Variant.BATTLE:
			return {
				"bg_top": Color(0.03, 0.05, 0.11, 1.0),
				"bg_bottom": Color(0.02, 0.03, 0.07, 1.0),
				"grid": Color(0.16, 0.30, 0.52, 0.18),
				"accent": Color(0.18, 0.72, 1.0, 0.32),
				"accent_soft": Color(0.08, 0.22, 0.40, 0.28),
				"glow_a": Color(0.10, 0.36, 0.78, 0.16 * accent_strength),
				"glow_b": Color(0.01, 0.08, 0.18, 0.0),
			}
		Variant.RESULT:
			return {
				"bg_top": Color(0.05, 0.05, 0.11, 1.0),
				"bg_bottom": Color(0.02, 0.03, 0.07, 1.0),
				"grid": Color(0.30, 0.40, 0.66, 0.14),
				"accent": Color(0.80, 0.86, 1.0, 0.28),
				"accent_soft": Color(0.18, 0.22, 0.40, 0.24),
				"glow_a": Color(0.32, 0.46, 0.86, 0.14 * accent_strength),
				"glow_b": Color(0.01, 0.08, 0.18, 0.0),
			}
		Variant.VICTORY:
			return {
				"bg_top": Color(0.02, 0.10, 0.07, 1.0),
				"bg_bottom": Color(0.01, 0.04, 0.03, 1.0),
				"grid": Color(0.22, 0.58, 0.42, 0.16),
				"accent": Color(0.42, 1.0, 0.72, 0.34),
				"accent_soft": Color(0.10, 0.28, 0.18, 0.28),
				"glow_a": Color(0.18, 0.72, 0.46, 0.18 * accent_strength),
				"glow_b": Color(0.02, 0.18, 0.10, 0.0),
			}
		Variant.DEFEAT:
			return {
				"bg_top": Color(0.10, 0.03, 0.04, 1.0),
				"bg_bottom": Color(0.04, 0.01, 0.02, 1.0),
				"grid": Color(0.62, 0.22, 0.24, 0.16),
				"accent": Color(1.0, 0.40, 0.32, 0.32),
				"accent_soft": Color(0.28, 0.08, 0.10, 0.30),
				"glow_a": Color(0.86, 0.22, 0.18, 0.18 * accent_strength),
				"glow_b": Color(0.22, 0.02, 0.04, 0.0),
			}
		Variant.SELECTION:
			return {
				"bg_top": Color(0.04, 0.06, 0.14, 1.0),
				"bg_bottom": Color(0.01, 0.03, 0.08, 1.0),
				"grid": Color(0.24, 0.46, 0.78, 0.18),
				"accent": Color(0.52, 0.88, 1.0, 0.30),
				"accent_soft": Color(0.08, 0.18, 0.36, 0.26),
				"glow_a": Color(0.18, 0.52, 0.92, 0.18 * accent_strength),
				"glow_b": Color(0.01, 0.08, 0.18, 0.0),
			}
		_:
			return {
				"bg_top": Color(0.03, 0.07, 0.13, 1.0),
				"bg_bottom": Color(0.01, 0.02, 0.06, 1.0),
				"grid": Color(0.22, 0.40, 0.64, 0.16),
				"accent": Color(0.32, 0.84, 1.0, 0.34),
				"accent_soft": Color(0.06, 0.18, 0.32, 0.28),
				"glow_a": Color(0.10, 0.44, 0.82, 0.20 * accent_strength),
				"glow_b": Color(0.02, 0.10, 0.20, 0.0),
			}