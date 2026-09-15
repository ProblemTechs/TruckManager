# Truck Manager Backend Core v0.1

## Goal

Provide the authoritative game-state foundation behind the frozen v1 Flutter frontend. The frontend/backend contract remains `docs/frontend-backend-contract.md`.

## Core decisions

- Management-only v1. Driver Mode remains deferred.
- Account-based play across Android, iOS, Windows, Linux and macOS.
- A player's primary company supports cloud sync without requiring a paid subscription.
- Local cached state supports interrupted/offline play; authoritative economic mutations are validated by the backend when connected.
- Simulation timestamps are stored in UTC.
- The player chooses an IANA time zone during account/company setup and can change the display preference later.
- Location-aware operations display local time for terminals, drivers, pickups and deliveries.
- Subscription features use entitlements rather than scattered premium checks.
- Players can submit bug reports, gameplay suggestions, feature requests, balance/economy feedback and UI/UX feedback.

## Backend modules

### Identity

`PlayerAccount`
- id
- displayName
- email/identity provider reference
- preferredTimeZone
- createdAtUtc
- lastSeenAtUtc

`DeviceRegistration`
- id
- accountId
- platform
- installationId
- lastSyncAtUtc

### Company state

`CompanyState`
- id
- accountId
- name
- cash
- reputation
- progressionLevel
- economyDifficulty
- simulation
- revision
- createdAtUtc
- updatedAtUtc

The monotonically increasing `revision` is used by synchronization and conflict detection.

### Simulation clock

`SimulationClock`
- gameTimeUtc
- speed: PAUSED, X1, X2, X5, X10
- criticalEventPauseEnabled
- lastProcessedAtUtc

All time-based systems consume simulation time rather than wall-clock time directly.

### Commands

Initial command envelope:

```json
{
  "commandId": "uuid",
  "accountId": "uuid",
  "companyId": "uuid",
  "deviceId": "uuid",
  "expectedRevision": 42,
  "type": "purchaseVehicle",
  "issuedAtUtc": "2026-09-15T14:00:00Z",
  "payload": {}
}
```

Commands must be idempotent by `commandId`. The server validates ownership, revision, game rules and financial constraints before committing mutations.

The implementation must support the frontend commands already defined in `frontend-backend-contract.md`, including company creation, simulation speed, equipment acquisition, employees, driver/team assignment, dispatch, loads/contracts, terminals, maintenance, safety and save/load.

### Events

Initial event envelope:

```json
{
  "eventId": "uuid",
  "companyId": "uuid",
  "revision": 43,
  "type": "financeUpdated",
  "gameTimeUtc": "2026-09-15T14:05:00Z",
  "payload": {}
}
```

The event stream must expose the frontend events defined in `frontend-backend-contract.md`: simulation ticks, truck movement, load status, driver duty/team switching, HOS warnings, maintenance/breakdowns, inspections/safety, medical warnings, contracts, terminals, finance and critical alerts.

### Cloud synchronization

Sync request includes:
- accountId
- companyId
- deviceId
- localRevision
- pending command IDs

Sync response includes:
- authoritativeRevision
- current state or state delta
- accepted/rejected command results
- new events
- server timestamp

Conflict policy:
1. Server is authoritative for committed economic/game transactions.
2. Commands use expected revisions and idempotency IDs.
3. Non-economic preferences may use last-write-wins where safe.
4. Offline commands are replayed in original order after reconnection.
5. Invalid stale commands are rejected with a reason and the client refreshes authoritative state.

### Subscriptions and entitlements

`Subscription`
- accountId
- provider
- providerSubscriptionId
- plan
- status
- periodStartUtc
- periodEndUtc

`Entitlement`
- accountId
- key
- active
- source
- expiresAtUtc

The base entitlement set includes primary-company cloud sync. Future paid entitlements may include additional save/company slots, advanced reports/history and premium customization. Game balance must not depend on punitive pay-to-wait mechanics.

### Feedback

`FeedbackSubmission`
- id
- accountId
- category
- title
- description
- gameVersion
- platform
- screen
- companyRevision
- createdAtUtc
- status

Categories: BUG, GAMEPLAY_SUGGESTION, FEATURE_REQUEST, BALANCE_ECONOMY, UI_UX, OTHER.

## Persistence

Production target: PostgreSQL-backed authoritative state with versioned schema migrations. Clients maintain a local cache for responsiveness/offline continuity. Save records include a schema version so future game updates can migrate older companies.

## Build order

1. Identity/account and device models.
2. Player time-zone preference.
3. Company aggregate and revisioning.
4. Simulation clock.
5. Command dispatcher and validation pipeline.
6. Event stream.
7. Persistence/save repository.
8. Cloud synchronization/replay.
9. Subscription entitlement service.
10. Feedback service.
11. Fleet/equipment domain.
12. Drivers, endorsements, HOS and teams.
13. Freight/load generation.
14. Dispatch and route progression.
15. Finance.
16. Maintenance and safety/DOT.
17. Terminals/staff/contracts.
18. Replace frontend mock state incrementally.

## Core v0.1 completion criteria

Core v0.1 is complete when a player can create an account/company with a selected time zone, create/load authoritative company state, pause/change simulation speed, persist and restore the game, synchronize the same company across devices, resolve stale revisions safely, expose entitlements, and submit feedback. Trucking simulation domains can then be layered onto this foundation without redesigning the frontend.