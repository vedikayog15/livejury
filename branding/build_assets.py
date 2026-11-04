"""Regenerate every icon, splash and store asset from logo.py.

    python3 branding/build_assets.py

Masters render once with headless Chrome; every size is resized from them.
"""
import json, pathlib
from PIL import Image
from logo import icon_svg, banner_svg
from render import render

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / 'branding' / 'out'
OUT.mkdir(exist_ok=True)

# --- masters (1024 unless noted) ---
masters = {
    'full': icon_svg(),                                  # full-bleed square: Play, iOS
    'rounded': icon_svg(rounded=True),                   # rounded tile: web, website, legacy Android
    'mark': icon_svg(bg=False),                          # transparent mark: in-app, website
    'fg': icon_svg(bg=False, scale=.64),                 # adaptive icon foreground (66dp safe zone)
    'mono': icon_svg(bg=False, scale=.64, mono=True),    # Android 13 themed icon
    'bgonly': icon_svg().replace('<g transform="translate(512 512)', '<g display="none" transform="translate(512 512)'),
    'maskable': icon_svg(scale=.78),                     # web maskable: 80% safe zone
}
for name, svg in masters.items():
    render(svg, OUT / f'{name}.png', 1024)
render(banner_svg(), OUT / 'banner.png', 1024, 500, transparent=False)
M = {name: Image.open(OUT / f'{name}.png').convert('RGBA') for name in masters}


def save(img, path, size, rgb=False):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if rgb:
        bg = Image.new('RGB', out.size, (16, 20, 38))
        bg.paste(out, mask=out.split()[3])
        out = bg
    out.save(path, optimize=True)


def padded(img, inset):
    """Shrink onto a transparent canvas, e.g. macOS icons sit inside a margin."""
    canvas = Image.new('RGBA', img.size, (0, 0, 0, 0))
    inner = img.resize((img.width - 2 * inset, img.height - 2 * inset), Image.LANCZOS)
    canvas.paste(inner, (inset, inset), inner)
    return canvas


# --- Play Store listing ---
save(M['full'], 'branding/play-store/icon-512.png', 512, rgb=True)
Image.open(OUT / 'banner.png').convert('RGB').save(ROOT / 'branding/play-store/feature-graphic-1024x500.png', optimize=True)

# --- Flutter assets ---
save(M['full'], 'assets/app-icon.png', 1024, rgb=True)
save(M['mark'], 'assets/brand/logo-mark.png', 512)

# --- Android ---
res = 'android/app/src/main/res'
for dpi, legacy, adaptive in [('mdpi', 48, 108), ('hdpi', 72, 162), ('xhdpi', 96, 216), ('xxhdpi', 144, 324), ('xxxhdpi', 192, 432)]:
    save(M['rounded'], f'{res}/mipmap-{dpi}/ic_launcher.png', legacy)
    save(M['fg'], f'{res}/mipmap-{dpi}/ic_launcher_foreground.png', adaptive)
    save(M['mono'], f'{res}/mipmap-{dpi}/ic_launcher_monochrome.png', adaptive)
    save(M['bgonly'], f'{res}/mipmap-{dpi}/ic_launcher_background.png', adaptive)
    save(M['mark'], f'{res}/drawable-{dpi}/splash_logo.png', legacy * 3 // 2)

# --- iOS (no alpha allowed) ---
ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for item in json.loads((ios / 'Contents.json').read_text())['images']:
    px = round(float(item['size'].split('x')[0]) * int(item['scale'][0]))
    save(M['full'], ios.relative_to(ROOT) / item['filename'], px, rgb=True)

# --- macOS (rounded tile inside Apple's ~10% margin) ---
mac_src = padded(M['rounded'], 100)
mac = ROOT / 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
for item in json.loads((mac / 'Contents.json').read_text())['images']:
    px = round(float(item['size'].split('x')[0]) * int(item['scale'][0]))
    save(mac_src, mac.relative_to(ROOT) / item['filename'], px)

# --- Windows ---
ico = M['rounded'].resize((256, 256), Image.LANCZOS)
ico.save(ROOT / 'windows/runner/resources/app_icon.ico', sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])

# --- Flutter web ---
save(M['rounded'], 'web/favicon.png', 32)
save(M['rounded'], 'web/icons/Icon-192.png', 192)
save(M['rounded'], 'web/icons/Icon-512.png', 512)
save(M['maskable'], 'web/icons/Icon-maskable-192.png', 192, rgb=True)
save(M['maskable'], 'web/icons/Icon-maskable-512.png', 512, rgb=True)

# --- Website ---
save(M['rounded'], 'website/assets/img/favicon.png', 32)
save(M['rounded'], 'website/assets/img/icon-192.png', 192)
save(M['rounded'], 'website/assets/img/icon-512.png', 512)
save(M['mark'], 'website/assets/img/logo-mark.png', 512)
Image.open(OUT / 'banner.png').convert('RGB').save(ROOT / 'website/assets/img/og-image.png', optimize=True)

print('done')
