# Backend Gameplay v0.2

This slice expands Truck Manager from core state/sync infrastructure into trucking simulation domains.

Implemented foundations:
- pickups, vans, box trucks and semis
- driver CDL/endorsements, medical-card expiration, duty status, mileage, levels and team-driver links
- freight/load lifecycle
- dispatch compatibility checks
- terminals and upgrade-related capacity fields
- maintenance jobs
- safety events and severity
- finance ledger, revenue, expenses, profit and operating ratio
- marketplace offers and anti-abuse price review hooks

Next slices deepen HOS clocks, load progression, fuel/tolls/payroll, maintenance wear/breakdowns, DOT inspections, contracts, staff, terminal upgrades, restoration/component swaps, marketplace ownership transfer/auctions and frontend state adapters.
