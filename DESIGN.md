# The Virtual Jury Room

## Product direction

The interface is a focused digital jury chamber: authoritative, calm, secure, and contemporary. The signed-in product is organized around four primary destinations: Lobby, Evidence, Deliberate, and History.

This direction is based on the supplied Stitch project `15608316780719115325` and its four Refined Emerald screens. The exported Stitch PNG and HTML references are archived under `design_reference/stitch/`.

## Visual language

- Obsidian-green backgrounds create focus without using generic pure-black surfaces.
- Emerald communicates active, verified, secure, selected, and successful states.
- Coral is restricted to urgent phases, prosecution emphasis, flags, and destructive warnings.
- Fine emerald borders and low ambient shadows provide depth. Decorative blur is avoided where it would hurt performance.
- No AI-generated imagery is used inside the Flutter application. Evidence atmosphere and case-closed decoration are drawn with Flutter primitives.

## Token architecture

The implementation follows three layers:

1. Primitive values: surface ladder, 4dp spacing scale, radii, type sizes, durations.
2. Semantic roles: canvas, surface, primary, urgent, error, text, outline.
3. Component roles: glass panel, bottom dock, exhibit tag, status indicator, buttons, inputs.

Source files:

- `lib/core/design/design_tokens.dart`
- `lib/core/theme/live_jury_theme.dart`
- `lib/features/jury_room/widgets/jury_room_components.dart`

## Core palette

| Role | Value |
| --- | --- |
| Canvas | `#111413` |
| Lowest surface | `#0C0F0E` |
| Low surface | `#191C1B` |
| Standard surface | `#1D201F` |
| High surface | `#272B29` |
| Primary emerald | `#95D3BA` |
| Primary container | `#064E3B` |
| Primary text | `#E1E3E1` |
| Secondary text | `#BFC9C3` |
| Outline | `#404944` |
| Urgent coral | `#FFB4A3` |
| Error | `#FFB4AB` |

## Typography

- Bodoni Moda: product titles, rulings, editorial headings.
- Jost: navigation, controls, body text, metadata, and labels.
- Body text is 16sp with a 1.55 line height for long-form deliberation reading.
- Uppercase metadata uses restrained 1.4sp tracking.

Both fonts are bundled locally, so the UI does not rely on a runtime network request.

## Interaction standards

- Minimum touch target: 48dp.
- Bottom navigation always includes icons and labels, with no more than four destinations.
- Every icon-only control has a tooltip or semantic label.
- Selection never relies on color alone; labels, icons, and component states reinforce meaning.
- Motion is limited to short state transitions and platform-native ink feedback.
- Content scrolls above the floating navigation dock and respects system safe areas.

## Responsive behavior

- Mobile-first at 320–560dp.
- 20dp phone margins, reducing only where necessary on compact devices.
- Cards and paragraphs remain within a 560dp reading column on larger displays.
- Message bubbles cap their width and reflow text instead of truncating it.
- Primary content remains accessible in portrait and landscape; fixed controls reserve their own layout space.
