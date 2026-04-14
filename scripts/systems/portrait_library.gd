## PortraitLibrary — Caricamento portrait da asset con fallback procedurale
##
## Centralizza il naming e il caricamento dei portrait per schermate e pannelli.

class_name PortraitLibrary
extends RefCounted

# ── Costanti ─────────────────────────────────────────────────────────────────

const PORTRAIT_DIR := "res://assets/images/characters"
const _PLACEHOLDER_SIZE := 256
const _BORDER_COLOR := Color(0.04, 0.06, 0.10, 1)

# ── Metodi pubblici ──────────────────────────────────────────────────────────

## Carica un portrait usando una chiave asset gia normalizzata.
static func load_portrait(asset_key: String, variant: String = "") -> Texture2D:
	var normalized_key := _normalize_asset_key(asset_key)
	var normalized_variant := variant.strip_edges().to_lower()
	if normalized_key == "":
		return _build_placeholder_texture(_fallback_tint_for_asset(""))

	var candidate_paths: Array[String] = []
	if normalized_variant != "":
		candidate_paths.append("%s/%s_%s.png" % [PORTRAIT_DIR, normalized_key, normalized_variant])
	candidate_paths.append("%s/%s.png" % [PORTRAIT_DIR, normalized_key])

	for path in candidate_paths:
		if ResourceLoader.exists(path):
			return load(path) as Texture2D

	return _build_placeholder_texture(_fallback_tint_for_asset(normalized_key))


## Carica un portrait partendo da un nome visualizzato del roster o dell'attore.
static func load_named_portrait(display_name: String, variant: String = "") -> Texture2D:
	return load_portrait(_normalize_asset_key(display_name), variant)


# ── Metodi privati ───────────────────────────────────────────────────────────

static func _normalize_asset_key(value: String) -> String:
	var normalized := value.strip_edges().to_snake_case().to_lower()
	normalized = normalized.replace("'", "")
	normalized = normalized.replace("-", "_")
	return normalized


static func _fallback_tint_for_asset(asset_key: String) -> Color:
	match asset_key:
		"omega_pilot", "player_default":
			return Color(0.20, 0.64, 0.97, 1)
		"phoenix_guardian":
			return Color(0.96, 0.63, 0.22, 1)
		"apex_striker":
			return Color(0.93, 0.33, 0.56, 1)
		"void_walker":
			return Color(0.45, 0.29, 0.78, 1)
		"cyber_mystic":
			return Color(0.18, 0.82, 0.82, 1)
		"nexus_warlord", "enemy_default":
			return Color(0.80, 0.24, 0.30, 1)
		"scrap_raider":
			return Color(0.74, 0.42, 0.18, 1)
		"void_drone":
			return Color(0.39, 0.58, 0.88, 1)
		"plasma_grunt":
			return Color(0.97, 0.38, 0.25, 1)
		"phase_stalker":
			return Color(0.52, 0.35, 0.83, 1)
		"iron_enforcer":
			return Color(0.56, 0.62, 0.72, 1)
		"void_overlord":
			return Color(0.60, 0.26, 0.72, 1)
		"galactic_tyrant":
			return Color(0.92, 0.54, 0.20, 1)
	return Color(0.22, 0.48, 0.75, 1)


static func _build_placeholder_texture(tint: Color) -> Texture2D:
	var image := Image.create(_PLACEHOLDER_SIZE, _PLACEHOLDER_SIZE, false, Image.FORMAT_RGBA8)
	var dark_tint := tint.darkened(0.45)
	var light_tint := tint.lightened(0.18)
	for x in _PLACEHOLDER_SIZE:
		for y in _PLACEHOLDER_SIZE:
			var pixel := dark_tint.lerp(light_tint, clampf(float(x + y) / float(_PLACEHOLDER_SIZE * 2), 0.0, 1.0))
			if abs(x - y) < 18 or abs((_PLACEHOLDER_SIZE - x) - y) < 18:
				pixel = pixel.lightened(0.10)
			if x < 6 or x > _PLACEHOLDER_SIZE - 7 or y < 6 or y > _PLACEHOLDER_SIZE - 7:
				pixel = _BORDER_COLOR
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)