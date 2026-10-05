# Truck Manager

Truck Manager is a cross-platform, nationwide U.S. trucking-company management simulator built with Flutter.

## Frontend v0.1

Implemented:
- Dark operations-center management UI
- Main navigation
- Simulation speed controls
- Dispatch Center
- Fleet/unit selection
- Player-defined truck unit numbers and nicknames
- Driver/co-driver status
- Team-driver automatic rotation indicator
- HOS and ETA display
- AUTO / STAFF / MANUAL dispatch status
- Truck odometer and truck levels
- Responsive desktop/mobile layout
- Mock frontend data ready to be replaced by backend simulation data

Reserved modules:
Dashboard, Loads, Fleet, Drivers, Terminals, Staff, Safety, Maintenance, Customers, Finance, and Reports.

## Game direction

Version 1 is focused on company management: AI drivers operate the equipment while the player builds and manages a carrier across the United States. Planned systems include pickups, vans, box trucks and Class 8 tractors; nationwide terminals; dispatchers and load planners; driver mileage and endorsements; DOT medical cards and inspections; safety/compliance; maintenance; contracts; finance; and progression from a small carrier to a national fleet.

Player driving mode is intentionally deferred to a later update.

## Run

```bash
flutter pub get
flutter run
```

## Linux desktop icon (Ubuntu/Kali)

After cloning or pulling the repository, install the clickable desktop launcher once:

```bash
chmod +x scripts/install-desktop-launcher.sh
./scripts/install-desktop-launcher.sh
```

Double-click **Truck Manager** on the desktop, or open it from the applications menu.
The first launch generates Linux desktop support if needed and downloads the Flutter
packages. Launches run the current checkout, so pulling an update does not open an
older release binary. To explicitly open an existing release build, use
`bash scripts/run-truck-manager.sh --built`.

## Local account and gameplay alpha

Players choose their own username, password, and business name. Sign-in verifies the password; sign-out lets another player create or resume a company during the same app session. Accounts and progress reset when the app closes.

The command processor supports company creation, starter vehicle purchase, hiring, load acceptance/completion, simulation speed and bank actions, with ownership checks, revisions and duplicate protection. See [the current implementation and test scope](docs/player-accounts-and-command-slice.md).

## Fleet, drivers and U.S. map

Money displays use comma separators and exact cents. Vehicle purchases create owned
fleet units with price, condition, mileage and location. The used vehicle catalogue
is available immediately, starting at $8,000; these are fictional game offers.
Hire named drivers and assign them to owned vehicles on the Drivers page. Starter
loads use an available driver and vehicle, and update their miles and vehicle
location when completed. The map shows recorded game locations, not continuous GPS
or live travel animation. Starter route distances are approximate.

The offline map includes all 50 states and Washington, DC, with Alaska/Hawaii insets.
Weigh-station coverage is **incomplete**: the bundled public-agency snapshot covers
AK, CA, FL, IL, NC and OK. It does not claim to contain every U.S. station, or live
open/closed status. See [map data provenance](assets/maps/README.md) for sources and
refresh instructions. Accounts and progress still reset when the app exits.
