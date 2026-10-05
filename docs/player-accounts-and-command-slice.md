# Player accounts and first command slice

Builds on the existing `backend/gameplay-v0.2` branch and preserves the current navigation. The desktop launcher from main is included.

Players choose a username, confirm a password, and enter a business name. No personal player/company defaults remain. Registration validates username/password lengths, reserves usernames during hashing, and stores only a random salt and PBKDF2-HMAC-SHA256 verifier (600,000 iterations). Sign-in verifies the password; usernames are case-insensitive. Sign-out and account selection isolate company state. Accounts and game progress are in memory for the app process only; restarting clears them. This is a local alpha, not production server authentication.

The Flutter `TruckGameState` is a UI adapter to the core command processor. `createCompany`, `setSimulationSpeed`, `purchaseVehicle`, `hireEmployee`, `acceptLoad`, `completeLoad`, `borrowMoney`, and `repayLoan` produce immutable company revisions and events. Difficulty sets authoritative initial cash: Relaxed $250,000; Standard $100,000; Realistic $50,000. A catalogue starter cargo van costs $48,000; hiring a driver costs $1,000; completing one active starter load earns $2,500 and 100 XP. Client-supplied price/revenue overrides are ignored.

Smallest playable loop: create account → name business → Settings: buy cargo van → hire driver → Loads: accept load → complete load. No player driving is required. Load completion remains a manual alpha action. Fleet/driver availability is represented by counts; detailed equipment assignment, routes, simulated delivery timing and expenses remain subsequent work. Existing placeholder action cards are unchanged.

Each command checks ownership, expected revision, supported type, resource constraints and payloads. One shared processor serializes in-memory access. Ledger keys are scoped to account/company/command; retries do not mutate or repeat events. Retries return the latest company snapshot with no repeated events. Rejected commands are not recorded. Ownership checks precede duplicate detection. `completeLoad` is an internal alpha command in addition to the frozen frontend command names; no existing envelope fields were renamed.

Repositories must be shared with one processor in this local process. The repository/ledger/event writes assume non-failing in-memory implementations; a future durable store requires atomic transactions and session authorization at the transport boundary. There is no persistence, remote authentication, cloud sync transport, or subscription implementation in this slice.

Validation: `flutter pub get`, `flutter analyze`, `flutter test`. Tests cover custom names, setup validation, password verification, duplicate registration, account isolation, playable loop, duplicate deliveries, revisions/concurrency, ownership, bank limits, malformed payloads and event replay. Test hashers use 10 iterations only for service-unit test speed; the app default remains 600,000.
