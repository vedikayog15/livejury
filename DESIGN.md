# Live Jury design system

## Direction

Live Jury uses a refined dark product language built around thoughtful group decisions. It should feel modern, confident, and human without relying on legal clichés, generated photography, glossy gradients, or game-dashboard clutter.

The visual identity comes from deep ink surfaces, warm coral interaction color, editorial serif headlines, precise sans-serif controls, custom geometric jury diagrams, and restrained spacing.

## Palette

| Role | Value |
| --- | --- |
| Canvas | `#0B1016` |
| Surface | `#121A23` |
| Raised surface | `#1A2531` |
| Deep ink | `#060A0F` |
| Outline | `#2B3947` |
| Primary coral | `#FF7658` |
| Main text | `#F5F1E9` |
| Supporting text | `#9DA9B5` |
| Positive | `#58B79D` |
| Negative | `#E26A73` |
| Warning | `#E0B35A` |

Coral is the only interaction accent. Green, red, and amber are semantic only.

## Typography

- Source Serif 4 for major statements, case names, and narrative moments.
- Manrope for body text, controls, navigation, metadata, and numbers.
- Sentence case throughout the interface.
- Tabular figures for scores, timers, and rankings.

## Composition

- One dominant action per screen.
- Use whitespace and direct grouping before adding containers.
- Feature surfaces use 20 to 24 radius.
- Standard controls use 12 to 16 radius.
- Cards require a real grouping or interaction purpose.
- No generated images are used in the interface.
- Product-specific visuals are drawn directly in Flutter.

## Home signature

The Home screen uses a custom six-seat jury diagram, a focused case-ready hero, two compact private-session actions, a typographic featured-case cover, and a clean bottom navigation bar.

## Accessibility and responsiveness

- Interactive targets are at least 44 logical pixels.
- Text and states never rely on color alone.
- Compact layout uses 16-pixel gutters under 360 logical pixels.
- Standard layout uses 20-pixel gutters.
- Content remains constrained to 560 logical pixels on larger displays.
- Verify 320, 390, and 560 logical-pixel widths.
