# Icon prompts and textual variants

This file contains ready-to-use prompts you can paste into an image LLM (or share with a designer),
and short textual variant descriptions to use as alt text or release notes.

---

## Quick instruction (composite the provided PNG onto backgrounds)

English (for image-LLM with image input support):

"You have a provided PNG icon (transparent background). Produce three centered 1024×1024 PNG outputs
that keep the icon artwork unchanged and composite it onto distinct backgrounds:

- Variant A — Flat / Deep‑Space Gradient: place the icon centered on a smooth deep‑space linear gradient
  background (#070A14 → #1A0833). Add a very subtle starfield overlay (low opacity) and a soft drop shadow
  behind the icon so it reads at small sizes. Output: PNG 1024×1024 (transparent outside badge), provide
  additional 512×512 and 256×256 resized derivatives.

- Variant B — Metallic / Embossed: place the icon on a dark metallic radial gradient (deep purple base) with a
  warm golden backing element behind the card silhouette to create contrast. Add a subtle emboss/specular
  highlight and slight rim light. Keep icon edges crisp. Output: PNG 1024×1024, plus 512×512 and 256×256.

- Variant C — Neon / Glow: place the icon on a near‑black background with a soft cyan/purple glow behind the
  icon. The glow should be colorized (#00F6FF / #6A00FF), blurred and screen‑composited so the silhouette
  remains the focal point. Output: PNG 1024×1024, plus 512×512 and 256×256.

Notes: do not add any text, brand names, or small details that break legibility at 16–32 px. Provide a flat
variant SVG for the Flat style if possible. Keep all outputs original and non‑derivative."

Italiano (per LLM italiano):

"Hai a disposizione un file PNG con sfondo trasparente. Genera tre output 1024×1024 centrati
che mantengano inalterata la grafica della carta e la compongano su sfondi distinti:

- Variante A — Flat / Gradiente Deep‑Space: icona centrata su gradiente lineare #070A14 → #1A0833,
  overlay stellare molto sottile e ombra morbida dietro l'icona. Output: PNG 1024/512/256.

- Variante B — Metallica / Embossed: sfondo radiale metallico viola scuro con elemento di contrasto
  dorato dietro la carta, leggero effetto emboss e riflessi. Output: PNG 1024/512/256.

- Variante C — Neon / Glow: sfondo quasi nero con alone ciano/viola (#00F6FF / #6A00FF) sfumato,
  compositing a schermo per l'effetto glow. Output: PNG 1024/512/256.

Nota: non aggiungere testo, mantenere leggibilità a 16–32 px, fornire SVG per la variante flat se possibile."

---

## Short textual variants (for alt text, app store, release notes)

- `Flat (Deep‑Space)`: "Flat card emblem on a deep‑space gradient (#070A14→#1A0833) with subtle starfield."
- `Metallic (Embossed)`: "Metallic purple radial background with warm gold backing and embossed look."
- `Neon (Glow)`: "Dark background with cyan/purple neon glow behind the card emblem, high contrast."

## Short prompts for the three styles (1‑sentence each)

- Flat: "Compose the provided card PNG centered on a deep‑space linear gradient (#070A14→#1A0833) with
  a low‑opacity starfield and soft shadow; keep edges crisp, no text."

- Metallic: "Compose the provided card PNG centered on a dark metallic radial background, add a warm golden
  backing element and subtle embossed/specular highlights; no text."

- Neon: "Compose the provided card PNG on a near‑black background with a cyan/purple glow behind the card
  (soft, blurred, screen blend) to create a neon effect; keep silhouette crisp."

---

## Suggested ImageMagick workflow (local, reproducible)

If you prefer to composite locally, use ImageMagick (magick). A helper script `tools/make_icon_variants.ps1`
is included in the repo — it expects `assets/icon_source.png` as input and writes `build/icons/`.

Run (PowerShell):

```powershell
# (optionally) set GODOT_EXE environment variable for other tasks
.\tools\make_icon_variants.ps1
```

If you want, I can run a quick check on your machine (or provide adjusted commands) — tell me where you
put the PNG file inside the repo (suggested: `assets/icon_source.png`) and whether you have ImageMagick installed.
