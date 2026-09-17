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
packages. Later launches use an existing release build when one is available.
