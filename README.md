# UniTrace Flutter Application

Campus Lost & Found Platform built with pure Flutter & Dart, connecting to a Spring Boot REST API.

## Architecture

The project adheres to a clean, **feature-first** modular architecture:

```text
lib/
├── app.dart                   # Centralized MaterialApp, routing table, theme configuration
├── main.dart                  # Application entry point, session restoration, auth interceptors
├── core/                      # Cross-cutting concerns & shared infrastructure
│   ├── api/                   # ApiClient (Dio singleton with JWT & refresh interceptors), endpoints
│   ├── constants/             # Centralized route strings, defaults, and app constants
│   ├── storage/               # TokenStorage (JWT tokens & claims) and SettingsStorage (base URL)
│   ├── theme/                 # Centralized M3 Navy & Amber palette, typography, elevation
│   ├── widgets/               # Core shared UI (AppButton, StatusPill, TypeBadge, EmptyStateView)
│   └── core.dart              # Core barrel export
└── features/                  # Independent functional modules
    ├── auth/                  # Authentication & registration flow
    │   ├── data/              # AuthApi (register, verify, login, refresh, logout)
    │   ├── models/            # User model with role predicates
    │   ├── screens/           # LoginScreen, RegisterScreen, OtpScreen
    │   └── auth.dart          # Auth barrel export
    ├── items/                 # Item discovery & reporting
    │   ├── data/              # ItemApi (feed queries, multipart creation, status updates)
    │   ├── models/            # Item model with status & reporter metadata
    │   ├── screens/           # HomeScreen, CreateItemScreen, ItemDetailScreen
    │   ├── widgets/           # ItemCard
    │   └── items.dart         # Items barrel export
    ├── moderator/             # Campus staff moderator portal
    │   ├── screens/           # ModeratorHomeScreen, ModeratorDeskScreen, ModeratorItemReviewScreen, ModeratorProfileScreen
    │   └── moderator.dart     # Moderator barrel export
    └── settings/              # Backend server configuration & connectivity test
        ├── screens/           # SettingsScreen
        └── settings.dart      # Settings barrel export
```

## Key Capabilities

- **Two-Step Campus Auth**: Registration initiation with token-based OTP verification.
- **Role-Based Navigation**:
  - `STUDENT`: Feeds, report lost/found items, view case details.
  - `MODERATOR` / `ADMIN`: Staff portal, review queues, intake locker management, claimant verification & hand-over.
- **Strict Authorization Rule**: Only the case creator or a campus staff moderator can transition case status (`OPEN`, `MATCHED`, `CLAIMED`, `CLOSED`).
- **Dynamic Server Settings (`/settings`)**: Configure backend host URL at runtime with presets (Localhost, Android Host `10.0.2.2`, LAN IP) and live connection latency checks.

## Manual Testing & Development

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit tests
flutter test

# 3. Launch the app on your connected device or simulator
flutter run
```
