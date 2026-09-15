# Backend Core

Initial domain code for Truck Manager Backend Core v0.1.

The core deliberately has no Flutter dependency. It defines player/company state, UTC simulation time, progression unlocks, command/event envelopes, persistence contracts, equipment component condition and marketplace listings.

Current progression hooks:
- Level 5: alliances
- Level 6: used equipment/parts marketplace
- Level 10: fictional investment market

Marketplace assets are generic so trucks, trailers, engines, transmissions, axles and future parts use the same ownership/listing infrastructure. Sellers set their own asking price. Restoration is supported by component-level condition rather than a single truck-only health value.

Next implementation slice: command processor + in-memory repositories/tests, followed by persistent storage and sync transport.
