"""Live Jury logo source. Writes SVG variants; render.py turns them into PNGs.

The mark: a round table drawn as a speech-bubble ring (deliberation), with a
notch at the top holding a glowing apricot seat (you). No player count implied.
"""
import math

C = (512, 492)       # ring centre in the 1024 master
R, W = 250, 100      # ring centreline radius and thickness
SEAT_R, NOTCH_R = 58, 96


def _pt(deg, r):
    a = math.radians(deg)
    return C[0] + r * math.cos(a), C[1] + r * math.sin(a)


def _arc(a0, a1, r):
    (x0, y0), (x1, y1) = _pt(a0, r), _pt(a1, r)
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f'M{x0:.1f} {y0:.1f} A{r} {r} 0 {large} 1 {x1:.1f} {y1:.1f}'


def _tail():
    ro = R + W / 2
    (x1, y1), (x2, y2) = _pt(112, ro), _pt(162, ro)
    tip = (168, 860)
    return (f'M{x1:.1f} {y1:.1f} C{x1 - 40:.1f} {y1 + 40:.1f} {tip[0] + 70:.1f} {tip[1] - 10:.1f} {tip[0]} {tip[1]} '
            f'C{tip[0] + 30:.1f} {tip[1] - 70:.1f} {x2 + 10:.1f} {y2 + 70:.1f} {x2:.1f} {y2:.1f} Z')


def mark(prefix='', mono=False):
    """The mark alone, drawn in the 1024 master space."""
    seat = (C[0], C[1] - R)
    ring_fill = '#fff' if mono else f'url(#{prefix}ring)'
    body = f'''
  <mask id="{prefix}notch" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">
    <rect width="1024" height="1024" fill="#fff"/>
    <circle cx="{seat[0]}" cy="{seat[1]}" r="{NOTCH_R}" fill="#000"/>
  </mask>
  <g mask="url(#{prefix}notch)">'''
    if not mono:
        body += f'''
    <g transform="translate(0 26)" opacity=".55" filter="url(#{prefix}soft)">
      <circle cx="{C[0]}" cy="{C[1]}" r="{R}" fill="none" stroke="#05060d" stroke-width="{W}"/>
      <path d="{_tail()}" fill="#05060d"/>
    </g>'''
    body += f'''
    <circle cx="{C[0]}" cy="{C[1]}" r="{R}" fill="none" stroke="{ring_fill}" stroke-width="{W}"/>
    <path d="{_tail()}" fill="{ring_fill}"/>'''
    if not mono:
        body += f'''
    <mask id="{prefix}shape" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">
      <circle cx="{C[0]}" cy="{C[1]}" r="{R}" fill="none" stroke="#fff" stroke-width="{W}"/>
      <path d="{_tail()}" fill="#fff"/>
    </mask>
    <rect width="1024" height="1024" fill="url(#{prefix}sheen)" mask="url(#{prefix}shape)"/>
    <path d="{_arc(170, 452, R + W / 2 - 3)}" fill="none" stroke="url(#{prefix}rim)" stroke-width="4" stroke-linecap="round"/>
    <circle cx="{C[0]}" cy="{C[1]}" r="{R - W / 2 + 3}" fill="none" stroke="rgba(30,20,90,.35)" stroke-width="5"/>'''
    body += '\n  </g>'
    if mono:
        body += f'\n  <circle cx="{seat[0]}" cy="{seat[1]}" r="{SEAT_R}" fill="#fff"/>'
    else:
        body += f'''
  <circle cx="{seat[0]}" cy="{seat[1]}" r="{SEAT_R * 2.1:.0f}" fill="url(#{prefix}seatGlow)"/>
  <ellipse cx="{seat[0]}" cy="{seat[1] + SEAT_R * .95:.0f}" rx="{SEAT_R * .8:.0f}" ry="{SEAT_R * .22:.0f}" fill="#05060d" opacity=".45" filter="url(#{prefix}soft)"/>
  <circle cx="{seat[0]}" cy="{seat[1]}" r="{SEAT_R}" fill="url(#{prefix}seat)"/>
  <ellipse cx="{seat[0] - SEAT_R * .28:.0f}" cy="{seat[1] - SEAT_R * .42:.0f}" rx="{SEAT_R * .42:.0f}" ry="{SEAT_R * .24:.0f}" fill="#fff" opacity=".7"/>'''
    return body


def defs(prefix=''):
    return f'''
  <linearGradient id="{prefix}ring" gradientUnits="userSpaceOnUse" x1="380" y1="190" x2="560" y2="860">
    <stop offset="0" stop-color="#f1edff"/><stop offset=".45" stop-color="#b9adf0"/><stop offset="1" stop-color="#6554b8"/>
  </linearGradient>
  <radialGradient id="{prefix}sheen" gradientUnits="userSpaceOnUse" cx="380" cy="260" r="430">
    <stop offset="0" stop-color="#fff" stop-opacity=".55"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="{prefix}rim" gradientUnits="userSpaceOnUse" x1="300" y1="240" x2="640" y2="800">
    <stop offset="0" stop-color="#fff" stop-opacity=".75"/><stop offset=".6" stop-color="#fff" stop-opacity=".35"/><stop offset="1" stop-color="#fff" stop-opacity="0"/>
  </linearGradient>
  <radialGradient id="{prefix}seat" cx="38%" cy="32%" r="70%">
    <stop offset="0" stop-color="#fff4e8"/><stop offset=".45" stop-color="#f5caa5"/><stop offset="1" stop-color="#d4834a"/>
  </radialGradient>
  <radialGradient id="{prefix}seatGlow">
    <stop offset="0" stop-color="#f5caa5" stop-opacity=".6"/><stop offset=".45" stop-color="#f5caa5" stop-opacity=".12"/><stop offset="1" stop-color="#f5caa5" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="{prefix}bg" cx="30%" cy="18%" r="95%">
    <stop offset="0" stop-color="#2b2a5e"/><stop offset=".55" stop-color="#141833"/><stop offset="1" stop-color="#0a0c18"/>
  </radialGradient>
  <radialGradient id="{prefix}halo" cx="50%" cy="50%" r="50%">
    <stop offset="0" stop-color="#6554b8" stop-opacity=".55"/><stop offset="1" stop-color="#6554b8" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="{prefix}warm" cx="85%" cy="95%" r="60%">
    <stop offset="0" stop-color="#f5caa5" stop-opacity=".18"/><stop offset="1" stop-color="#f5caa5" stop-opacity="0"/>
  </radialGradient>
  <filter id="{prefix}soft" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="18"/></filter>'''


def background():
    return f'''
  <rect width="1024" height="1024" fill="url(#bg)"/>
  <rect width="1024" height="1024" fill="url(#warm)"/>
  <circle cx="{C[0]}" cy="{C[1]}" r="420" fill="url(#halo)"/>
  <circle cx="{C[0]}" cy="{C[1]}" r="{R + W / 2 + 70}" fill="none" stroke="rgba(193,195,212,.10)" stroke-width="3"/>'''


def icon_svg(size=1024, bg=True, rounded=False, scale=1.0, mono=False):
    """bg: full-bleed background. rounded: clip to a rounded square (for web/macOS).
    scale: shrink the mark around the canvas centre (adaptive icon safe zone)."""
    clip = '<clipPath id="r"><rect width="1024" height="1024" rx="230"/></clipPath>' if rounded else ''
    inner = (background() if bg else '') + f'''
  <g transform="translate(512 512) scale({scale}) translate(-494 -{C[1] + 14})">{mark(mono=mono)}
  </g>'''
    if rounded:
        inner = f'<g clip-path="url(#r)">{inner}</g>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 1024 1024">
<defs>{defs()}{clip}</defs>{inner}
</svg>'''


def banner_svg():
    """Play Store feature graphic, 1024x500. Key content sits inside the centre
    safe area because Play may overlay a play button or crop the edges."""
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="500" viewBox="0 0 1024 500">
<defs>{defs("b")}
  <radialGradient id="bbg" cx="22%" cy="20%" r="110%">
    <stop offset="0" stop-color="#2d2a66"/><stop offset=".5" stop-color="#141833"/><stop offset="1" stop-color="#0a0c18"/>
  </radialGradient>
  <radialGradient id="bwarm2" cx="92%" cy="100%" r="55%">
    <stop offset="0" stop-color="#f5caa5" stop-opacity=".22"/><stop offset="1" stop-color="#f5caa5" stop-opacity="0"/>
  </radialGradient>
  <pattern id="dots" width="26" height="26" patternUnits="userSpaceOnUse"><circle cx="2" cy="2" r="1.2" fill="#fff" opacity=".10"/></pattern>
  <radialGradient id="fade"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></radialGradient>
  <mask id="dotmask"><rect width="1024" height="500" fill="url(#fade)"/></mask>
</defs>
<rect width="1024" height="500" fill="url(#bbg)"/>
<rect width="1024" height="500" fill="url(#bwarm2)"/>
<rect width="1024" height="500" fill="url(#dots)" mask="url(#dotmask)"/>
<g transform="translate(250 250)">
  <circle r="230" fill="url(#bhalo)"/>
  <circle r="205" fill="none" stroke="rgba(193,195,212,.12)" stroke-width="2"/>
  <circle r="240" fill="none" stroke="rgba(193,195,212,.07)" stroke-width="2" stroke-dasharray="4 10"/>
  <g transform="scale(.44) translate(-494 -{C[1] + 14})">{mark(prefix="b")}</g>
</g>
<g font-family="DM Sans, sans-serif">
  <text x="468" y="170" fill="#f5caa5" font-size="17" font-weight="700" letter-spacing="4.5">A SOCIAL DELIBERATION GAME</text>
  <rect x="468" y="186" width="40" height="3" rx="1.5" fill="#f5caa5" opacity=".8"/>
  <text x="464" y="282" fill="#ffffff" font-family="Fraunces, Georgia, serif" font-size="104" font-weight="500" letter-spacing="-2">Live <tspan fill="#f5caa5" font-style="italic">Jury</tspan></text>
  <text x="468" y="336" fill="#c1c3d4" font-size="27" font-weight="500">Weigh the evidence. Talk it through.</text>
  <text x="468" y="372" fill="#c1c3d4" font-size="27" font-weight="500">Make the call together.</text>
</g>
</svg>'''
