# Truck Manager — Initial Architecture

## Goal

Keep presentation, simulation logic, and persistence separated so the same core game can support Android, iOS, and desktop builds.

## Frontend Responsibilities

The frontend should handle:

- Main dashboard
- Fleet screens
- Driver screens
- Dispatch board
- Load board
- Staff management
- Facility / HQ screens
- Finance screens
- Notifications
- Settings

The UI should be designed for both touch and mouse/keyboard use.

## Backend / Simulation Responsibilities

The backend or simulation layer should handle:

- Game clock and simulation ticks
- Driver hours, fatigue, and rest
- Two-driver automatic switching
- Load generation
- Auto-dispatch decisions
- Route progression
- Fuel use
- Maintenance wear
- Revenue and expenses
- Staff effects
- Facility bonuses and capacity
- Save-game state

## Shared Domain Models

Likely shared objects include:

- Company
- Truck
- Trailer
- Driver
- DriverTeam
- Load
- Route
- Dispatcher
- LoadPlanner
- Employee
- Facility
- Terminal
- MaintenanceRecord
- Transaction
- Loan

## Suggested Repository Layout

```text
TruckManager/
├── frontend/
│   └── README.md
├── backend/
│   └── README.md
├── shared/
│   └── README.md
├── docs/
│   ├── GAME_DESIGN.md
│   └── ARCHITECTURE.md
└── README.md
```

## Development Principle

Core business/game rules should not live directly inside UI screens. The frontend asks the simulation layer for state and sends player actions back to it. This makes testing easier and keeps behavior consistent across mobile and desktop.
