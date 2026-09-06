# The Jury Room — After Hours

## The idea

Five perspectives are already in the room. Yours is the sixth. A cinematic invitation to an evening of thought: open the file, examine what is missing, hear the room, make your call.

The original visual system combines sculptural light, architectural depth, and layered surfaces. The invitation, lobby, and case banners carry the atmosphere. Evidence uses calm, legible reading surfaces. All artwork is drawn in Flutter; only the platform scaffolding is retained from the earlier project.

## Typography

Outfit is the display family, with explicit 400/500/600/700/800 font files. Inter provides reading text and controls, bundled at 400/500/600/700/800. No reliance on a browser-installed font, synthetic heavy serif, or runtime font download. Headlines use compact 30–42 dp scales; reading copy is 15–16 dp. Labels and metadata remain subordinate. All text respects device scaling.

## Palette and materials

- Night: #101426. Snow: #F6F5FA. White reading cards.
- Warm apricot #F5CAA5 highlights actions on night surfaces.
- Violet #6554B8 anchors selected navigation, progress, and primary actions on light surfaces.
- Mist #ECE9F5 and lilac glow #A99AE3 create soft background depth.
- All colors remain tokenized. Dark text on apricot, white text on violet, opaque surfaces beneath evidence copy.

A frosted navigation capsule and luminous circular utility controls sit above the content. Glass is reserved for navigation and occasional artwork overlays. Content panels use solid or gently graded surfaces with edge highlights and soft shadows. The Flutter material treatment is an original interpretation; it is not Apple's native Liquid Glass implementation.

## Original Flutter artwork

Each case receives a distinct, code-drawn scene with foreground, subject, background, light source, and controlled text area:

1. The Glass Hour: a translucent sculpture above a stone plinth, museum architecture, angled light and deep shadows.
2. The Last Light: a rooftop light installation, rain, skyline, and a warm horizon.
3. The Silent Platform: a receding station tunnel, rails, amber platform edge, and an abandoned bag.

The jury illustration becomes a dimensional chamber: an elliptical table, upholstered seats, floor shadows, a luminous halo, and one warm highlighted seat. Gradients and deterministic texture provide depth; no AI-generated or stock images are used. Entry animations are short, finite and disabled for reduced motion.

## Guidance applied

- [Apple HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials): distinguish controls from content; apply translucent materials sparingly.
- [Apple: The details of UI typography](https://developer.apple.com/videos/play/wwdc2020/10175/): use size, weight and consistent text roles to communicate hierarchy.
- [Apple reduced-motion evaluation](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria): ensure core tasks remain available with reduced motion.
- Local ui-ux-pro-max, design-system, banner-design and canvas design guidance: deliberate focal point, safe text zones, original visual assets, shared tokens and accessibility checks. The user's no-image-generation and independent-decision instructions govern implementation.

## Geometry and motion

4 dp base; spacing 8/12/16/24/32/40. Page gutters are 20 dp below 360 and 24 otherwise. Reading width is capped at 560 dp. Corners: 12 for controls, 20 for panels, 28 for artwork and navigation. All controls have at least 48 × 48 dp touch targets; primary actions are at least 56 dp. Optional haptics, Material interaction feedback, and short entry reveals provide tactile feedback. Decorative motion is disabled when reduced motion is enabled.

Primitive palette values map to semantic colors in `lib/design/tokens.dart`, then to theme and component properties. `JSpace` and `JType` define shared dimensions and text roles. Status always includes a word or icon. Reading content scrolls, metadata wraps, and fixed actions remain within safe areas.

## Screens and interaction

1. **Invitation** — midnight, oversized typographic invitation, six-seat chamber, three concise promises, demo and account entry.
2. **Authentication** — visible email/password labels, sign-in/create-account toggle, validation, loading, recovery email, explicit connection state.
3. **Lobby** — editorial welcome, featured case illustrated as an architectural dossier, primary find-jury action, private room/join-code entry, browsable case library, resume active case.
4. **Assembly** — visible room code, copy action, six seats, named participants, cancellable matchmaking. Demo jurors arrive progressively and are explicitly labeled simulated. Real rooms contain real members only.
5. **Case file** — case narrative, parties, question to resolve, fictional game standard, timeline. A persistent stage indicator explains review → first vote → discussion → final vote.
6. **Evidence desk** — filterable exhibits: original schematics, documents, witness transcript and accessible simulated audio visualization. Detail views show provenance, contradictory interpretations, mark-reviewed state and discussion reference action.
7. **First impression** — private ballot; no aggregate revealed before final voting. Evidence review is required. Choices can be revised until submitted.
8. **Deliberation** — readable discussion, attached exhibit references, message composer, participant drawer, community guidance, report and mute controls. Draft survives evidence inspection. Explicit progress to final voting.
9. **Final ballot** — anonymous choice plus a reason of at least 20 characters. Clear irreversible submission state; waiting state for remaining jurors.
10. **Verdict** — only closed rounds show aggregate counts; dissent and tied results are valid. Debrief explains ambiguity. Performance rewards reviewing, citing, and explaining rather than conformity or a supposedly correct legal result.
11. **Journal** — saved cases, outcome, points, individual reasoning, empty state for first-time accounts.
12. **Profile, notices, rankings** — editable display name, earned badges, demo/cloud indicator, preference controls, persistent read state, participant ranking with honest sample labeling.

## Architecture

Minimal main → bootstrap → app shell. Feature modules own screens; core owns typed models, repository interfaces, local demo data, and a ChangeNotifier controller. An inherited scope injects state; centralized named navigation handles routes and guards. No business logic in UI components.

Demo repository uses local preferences to persist completed cases, profile, preferences and the active round. Supabase repository implements the same contract using email/password Auth, Postgres RPCs and room-change subscriptions. Explicit demo entry always stays local even when cloud configuration exists. An unavailable cloud connection produces actionable errors, never fabricated cloud success.

## Backend contract

Versioned SQL defines profiles, cases, rooms, membership, evidence review, private ballots, messages, history, notifications, and reports. RLS isolates accounts and room data. Room capacity, joining, stage transitions, ballot submission and results are enforced by transactional functions. A client's vote is readable only by its owner. Aggregate counts are available only after six final ballots. No secret/service key in client config. Public nickname/points ranking uses a narrow function.

## Quality gates

Format; static analysis; unit tests for progression, persistence, errors and consensus; widget tests for onboarding through verdict, private-room validation, chat references, and 320/390/560 dp layouts plus enlarged text; release web build; debug APK build. Visually inspect rendered Flutter screens. Document unverified hosted Supabase behavior if project credentials are unavailable. Mobile store signing and hosted deployment require owner-specific credentials and are separate from successful local builds.

