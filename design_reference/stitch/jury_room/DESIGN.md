---
name: Jury Room
colors:
  surface: '#111413'
  surface-dim: '#111413'
  surface-bright: '#373a38'
  surface-container-lowest: '#0c0f0e'
  surface-container-low: '#191c1b'
  surface-container: '#1d201f'
  surface-container-high: '#272b29'
  surface-container-highest: '#323534'
  on-surface: '#e1e3e1'
  on-surface-variant: '#bfc9c3'
  inverse-surface: '#e1e3e1'
  inverse-on-surface: '#2e3130'
  outline: '#89938d'
  outline-variant: '#404944'
  surface-tint: '#95d3ba'
  primary: '#95d3ba'
  on-primary: '#003829'
  primary-container: '#064e3b'
  on-primary-container: '#80bea6'
  inverse-primary: '#2b6954'
  secondary: '#ffb1c2'
  on-secondary: '#541d2d'
  secondary-container: '#703343'
  on-secondary-container: '#f09eb0'
  tertiary: '#ffb4a3'
  on-tertiary: '#630f00'
  tertiary-container: '#871800'
  on-tertiary-container: '#ff957c'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#b0f0d6'
  primary-fixed-dim: '#95d3ba'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#0b513d'
  secondary-fixed: '#ffd9df'
  secondary-fixed-dim: '#ffb1c2'
  on-secondary-fixed: '#3a0819'
  on-secondary-fixed-variant: '#703343'
  tertiary-fixed: '#ffdad2'
  tertiary-fixed-dim: '#ffb4a3'
  on-tertiary-fixed: '#3d0600'
  on-tertiary-fixed-variant: '#8b1a00'
  background: '#111413'
  on-background: '#e1e3e1'
  surface-variant: '#323534'
typography:
  display-lg:
    fontFamily: Bodoni Moda
    fontSize: 52px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.025em
  display-md:
    fontFamily: Bodoni Moda
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Bodoni Moda
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Bodoni Moda
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Jost
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Jost
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: '0'
  body-base:
    fontFamily: Jost
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: '0'
  label-caps:
    fontFamily: Jost
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.08em
  stat-lg:
    fontFamily: Jost
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter-sm: 12px
  gutter-md: 16px
  gutter-lg: 24px
  margin-mobile: 20px
  margin-desktop: 48px
  container-max: 1480px
---

## Brand & Style

The design system for the product establishes a high-stakes digital sanctuary for legal intelligence and collective decision-making. The brand personality is **authoritative, mysterious, and hyper-refined**, moving away from clinical corporate aesthetics toward a "Pro Max" luxury tech feel. It evokes the gravity of a high-court chamber filtered through a futuristic, night-mode lens.

The visual style is a sophisticated blend of **Glassmorphism** and **High-Contrast Modernism**. It utilizes deep, multi-tiered layering to create a sense of structural depth. High-fidelity elements like sub-millimeter hairline borders, specular highlights, and localized ambient glows transform the UI from a flat tool into a premium tactile environment. The emotional response should be one of focused intensity, sovereign judicial gravity, and technological superiority.

## Colors

The palette is anchored in a "Deep Obsidian Emerald" foundation, intentionally avoiding standard blues to establish a unique luxury identity.

- **Primary (Deep Forest Emerald):** Used for structural surfaces, card backgrounds, and the core brand identity. It provides a botanical, grounded depth.
- **Secondary (Imperial Burgundy):** Reserved for high-priority chambers, executive dissent, and secondary categorization to provide warmth and richness.
- **Tertiary (Sunset Orange):** The "High-Voltage" interactive accent. Used exclusively for primary calls-to-action (CTAs), critical alerts, and verdict submission points.
- **Neutral (Obsidian Void):** The canvas background. A deep, matte black-green that allows glass layers to pop.
- **Functional Accents:** **Cyber Lime** is used for telemetry—consensus gauges, live status indicators, and positive confirmations. **Pearl White** is the primary ink for maximum legibility, while **Slate Gray** handles secondary metadata.

**Gradients & Glows:**
- Primary CTAs use a linear gradient from Sunset Orange to a deeper Vermillion.
- Surfaces utilize subtle radial emerald-to-black gradients to mimic ambient room lighting.

## Typography

This design system employs a "High-Contrast Pairing" strategy:
- **Bodoni Moda (Serif):** Used for all high-level display and headline typography. Its razor-sharp serifs and vertical stress evoke editorial prestige and judicial finality.
- **Jost (Geometric Sans):** Used for utility, body copy, and navigation. Its clean, open proportions ensure effortless readability on dark, blurred glass surfaces.
- **JetBrains Mono (Monospace - Optional Utility):** Use for technical metadata, timestamps, and exhibit ID numbers (e.g., EXHIBIT-904-B).

**Key Rules:**
- Serifs should use tight negative letter-spacing for a "sculpted" feel.
- Uppercase labels and chips should use generous positive letter-spacing (8%) to improve quick parsing.
- Body text maintains a 1.6x line-height ratio to ensure transcripts remain readable during long deliberation sessions.

## Layout & Spacing

The system uses a **fluid grid model** with a disciplined 4px/8px modular spacing rhythm.

**Grid Architecture:**
- **Desktop (>= 1280px):** 12-column grid, 1480px max-width, 48px side margins, 24px gutters.
- **Tablet (768px - 1023px):** 8-column grid, 32px side margins, 16px gutters.
- **Mobile (<= 767px):** 4-column grid, 20px side margins, 12px gutters.

**Layout Strategy:**
- **Dual-Pane Logic:** On desktop, deliberations utilize a split-view (Evidence on left, Interaction/Voting on right).
- **Floating Controls:** On mobile, critical actions (like "Cast Vote") are pinned to a floating bottom island to maximize vertical reading space for transcripts.
- **Breathing Room:** Inside cards, padding is generous (32px+) to ensure that dense legal text doesn't feel overwhelming.

## Elevation & Depth

Hierarchy is established through **Layered Glassmorphism** rather than traditional shadows.

1.  **Level 0 (Base):** The Obsidian Emerald void. No transparency.
2.  **Level 1 (Surfaces):** Primary content containers. `backdrop-filter: blur(24px)`, background `rgba(22, 34, 30, 0.7)`. Uses 1px hairline borders with gradient highlights.
3.  **Level 2 (Elevated):** Focused modals, evidence inspectors, and floating docks. `backdrop-filter: blur(32px)`, background `rgba(30, 45, 40, 0.85)`. 
4.  **Level 3 (Glows):** Interaction points and active status indicators. These use outer glows (e.g., Sunset Orange or Cyber Lime) with 20% opacity to "lift" the element off the glass surface.

**The "Specular Border":** Every glass container must have a 1px border. Use a linear gradient for the border color (White at 15% opacity to Emerald at 5% opacity) to simulate a light source hitting the edge.

## Shapes

The shape language is **Refined and Modern**, utilizing medium roundedness to soften the intensity of the dark palette.

- **Standard Containers:** Use `rounded-lg` (1.25rem / 20px) for evidence cards and content panels.
- **Action Elements:** Primary buttons and navigation docks use `rounded-xl` (1.75rem / 28px) or "Pill" shapes for a more ergonomic, premium feel.
- **Inputs:** Use `rounded-md` (0.875rem / 14px) for form fields to maintain a slightly sharper, more professional utility look.

## Components

### Buttons
- **Primary (Verdict CTA):** High-contrast Sunset Orange gradient. 1px inner highlight on the top edge. Scale slightly (1.02x) on hover with an expanded orange glow.
- **Secondary (Glass):** Frosted emerald glass with 1px border. Text in Pearl White.
- **Tertiary (Ghost):** No background. Text in Slate Gray, turning to Pearl White on hover.

### Cards & Panels
- **Deliberation Cards:** Utilize the Level 1 glass treatment. Include a "Foil Highlight" — a very subtle horizontal gradient at the very top of the card (2px high) in primary emerald.
- **Burgundy Special Panels:** Use the secondary burgundy palette with a subtle `blur(16px)` to denote dissenting or high-priority executive content.

### Navigation
- **Floating Island Dock:** A pill-shaped capsule at the bottom-center. High blur (32px) and dark obsidian background. Active states are indicated by a Cyber Lime micro-dot below the icon.

### Inputs & Sliders
- **Fields:** Dark, recessed backgrounds (`rgba(4, 7, 6, 0.6)`) with a focus state that illuminates the entire border in Cyber Lime.
- **Confidence Slider:** A Cyber Lime progress track with a Pearl White frosted glass thumb. The thumb should emit a soft lime glow when active.

### Specialized Components
- **Consensus Gauge:** A segmented circular arc. Segments light up in Cyber Lime (Agreement) or Sunset Orange (Deadlock) to visualize real-time juror polling.
- **Evidence Exhibit Tag:** A small, monospaced Jost label with a 1px border and a background color corresponding to the evidence type (e.g., Amethyst for documents, Emerald for audio).