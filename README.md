# Live Jury

Live Jury is a Flutter mobile application where six jurors examine a fictional
legal case, submit private and final votes, deliberate together, and compare
their reasoning with the expected legal outcome.

## Current stage

The repository currently contains a complete local-first UI prototype. User
accounts, matchmaking, rooms, chat, voting, results, history, notifications,
leaderboards, and profile data are simulated in memory. Backend integrations
will replace those local state transitions in the next phase.

## Project structure

```text
lib/
├── main.dart                         # Application entry point only
├── app/
│   └── live_jury_app.dart            # Root MaterialApp and app-level flow
├── core/
│   ├── theme/                        # Color tokens and Flutter theme
│   └── widgets/                      # Reusable presentation components
└── features/
    ├── auth/
    ├── onboarding/
    ├── navigation/
    ├── home/
    ├── matchmaking/
    ├── jury/
    ├── history/
    ├── leaderboard/
    ├── notifications/
    └── profile/
```

Feature code should remain inside its feature directory. Components shared by
multiple features belong in `core/widgets`, while global visual tokens belong
in `core/theme`. Future API clients, repositories, domain models, and state
controllers should be added within the feature that owns them instead of being
placed in `main.dart`.

## Verification

```bash
flutter analyze
flutter test --reporter compact
flutter build web
```
