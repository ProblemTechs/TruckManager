# Backend Core

Initial domain implementation for Truck Manager Backend Core v0.1.

The core deliberately has no Flutter dependency. It now includes player/company state, UTC simulation time, progression unlocks, command/event envelopes, persistence contracts, in-memory repositories, a revision-safe idempotent command processor, synchronization service, equipment component condition, marketplace listings and Free/Full/Pro entitlements.

Current progression hooks:
- Level 5: alliances
- Level 6: used equipment/parts marketplace
- Level 10: fictional investment market

Marketplace assets are generic so trucks, trailers, engines, transmissions, axles and future parts use the same ownership/listing infrastructure. Sellers set their own asking price. Restoration is supported by component-level condition rather than a single truck-only health value.

Licensing foundation:
- Free: configurable 5-power-unit default limit
- Full: permanent full-game entitlement and no licensing fleet cap
- Pro: optional additional services/features without pay-to-win progression

Implemented command slice:
- ownership validation
- optimistic revision validation
- command idempotency ledger
- `setSimulationSpeed`
- event persistence
- sync response with authoritative revision and events since the client's local revision

Next implementation slice: tests plus company creation/save serialization, then fleet purchase/lease commands and persistent PostgreSQL-ready storage interfaces.
