<#
make_icon_variants.ps1

PowerShell helper to generate 3 icon variants (flat / metallic / neon)
using ImageMagick CLI (`magick`).

Place your source PNG (transparent) at `assets/icon_source.png` and run:
  .\tools\make_icon_variants.ps1

Output will be written to `build/icons/` with sizes 1024,512,256.

This script is best-effort: tweak colors, sizes and blur amounts as needed.
#>

param(
    [string]$Source = "assets/icon_souce.png",
    [string]$OutDir = "build/icons",
    [int]$Canvas = 1024
)

if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
    Write-Error "ImageMagick 'magick' not found in PATH. Install ImageMagick and retry."
    exit 1
}

if (-not (Test-Path $Source)) {
    Write-Error "Source icon not found: $Source`nPlace the PNG (transparent background) at this path."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Resize-And-Save($in, $out, $size) {
    magick "${in}" -resize ${size}x${size} "${out}"
}

## Variant 1: Flat / Deep-Space Gradient + subtle starfield
$bg_flat = "$OutDir\bg_flat.png"
magick -size ${Canvas}x${Canvas} gradient:'#070A14-#1A0833' -quality 100 "$bg_flat"
# subtle starfield overlay (low opacity)
magick -size ${Canvas}x${Canvas} plasma:fractal -evaluate Multiply 0.15 -auto-level -quality 100 "$OutDir\stars.png"
magick "$bg_flat" "$OutDir\stars.png" -compose overlay -composite "$OutDir\bg_flat_stars.png"

$src_resized = "$OutDir\src_resized.png"
magick "$Source" -resize 70% "$src_resized"

# create drop shadow and composite
magick "$OutDir\bg_flat_stars.png" \
  \( "$src_resized" -alpha set -background none -shadow 80x10+0+18 \) \
  \( "$src_resized" -alpha set \) -gravity center -compose over -composite "$OutDir\icon_flat_1024.png"

# Variant 2: Metallic / embossed + golden backing
$bg_metal = "$OutDir\bg_metal.png"
magick -size ${Canvas}x${Canvas} radial-gradient:'#0f0236-#2a0070' -quality 100 "$bg_metal"
# golden backing circle
magick -size ${Canvas}x${Canvas} xc:none -fill "#FFC857" -draw "fill #FFC857 circle ${Canvas/2},${Canvas/2} ${Canvas/2},${Canvas/4}" "$OutDir\gold_back.png"
magick "$bg_metal" "$OutDir\gold_back.png" -gravity center -composite "$OutDir\bg_metal_backed.png"

# metallic emboss on the icon: desaturate, multiply small specular
magick "$src_resized" -alpha set -channel RGB -modulate 100,0 -auto-level "$OutDir\src_mono.png"
magick "$OutDir\bg_metal_backed.png" \( "$OutDir\src_mono.png" -evaluate multiply 0.45 -blur 0x1 \) \( "$src_resized" \) -gravity center -compose over -composite "$OutDir\icon_metal_1024.png"

# Variant 3: Neon / glow on dark gradient
$bg_neon = "$OutDir\bg_neon.png"
magick -size ${Canvas}x${Canvas} gradient:'#05050a-#0b0f1a' "$bg_neon"

# create colored glow from the icon (duplicate -> colorize -> blur)
magick "$src_resized" -alpha set -background none -fill "#00F6FF" -colorize 100% -blur 0x30 "$OutDir\glow_cyan.png"
magick "$src_resized" -alpha set -background none -fill "#6A00FF" -colorize 100% -blur 0x16 "$OutDir\glow_purple.png"

magick "$bg_neon" "$OutDir\glow_cyan.png" -compose screen -composite "$OutDir\tmp_neon.png"
magick "$OutDir\tmp_neon.png" "$OutDir\glow_purple.png" -compose screen -composite "$OutDir\bg_neon_glow.png"
magick "$OutDir\bg_neon_glow.png" "$src_resized" -gravity center -composite "$OutDir\icon_neon_1024.png"

# Produce smaller sizes (512, 256) for all variants
$sizes = @(512,256)
$variants = @("icon_flat_1024.png","icon_metal_1024.png","icon_neon_1024.png")
foreach ($v in $variants) {
    foreach ($s in $sizes) {
        $in = "$OutDir\$v"
        $out = $in.Replace("1024", "$s")
        if (Test-Path $in) {
            magick "$in" -resize ${s}x${s} "$out"
        }
    }
}

Write-Host "Variants generated in: $OutDir"
