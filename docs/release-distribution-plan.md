# Truck Manager Release & Distribution Plan

## Product model

Truck Manager uses entitlement-based licensing so storefront rules do not leak into gameplay code.

### Free
- Free-to-start edition.
- Maximum 5 power units by default; value is configurable.
- Trailers do not consume the power-unit allowance.
- Core company-management gameplay remains playable.
- Purchase validation prevents a Free company from accidentally acquiring a sixth power unit.

### Full Game
- Permanent full-game entitlement.
- No licensing-based fleet cap.
- Full core simulation and progression.
- Alliances and the player-driven used equipment/parts marketplace remain gameplay systems, not pay-to-win advantages.

### Pro
- Optional monthly/yearly entitlement layered on the Full Game.
- Intended for advanced cloud/services, additional company/save capacity, deeper history/reports and premium customization.
- Do not sell XP, game money, freight-rate advantages or faster progression.

## Storefront strategy

### Android
Target Google Play with the Free edition as the entry product and an in-app permanent Full Game unlock. Optional Pro subscription can be added after core release readiness.

### iOS
Target Apple App Store with the same Free -> Full entitlement model and optional Pro subscription, subject to current App Store purchasing and subscription requirements at release time.

### Steam
Target Steam as a paid Full Game product with a separate free demo. The Steam demo should use the same core codebase but a demo entitlement/profile. It should demonstrate company creation, dispatch, drivers, fleet, maintenance and early progression without requiring the mobile five-truck monetization flow.

## Release order
1. Finish authoritative backend core and tests.
2. Connect Flutter frontend to real backend state.
3. Complete save/sync and entitlement validation.
4. Produce Android release build and store assets.
5. Produce iOS release build and store assets.
6. Produce Windows/Linux Steam builds.
7. Build Steam demo configuration.
8. Store compliance, privacy, age/content declarations, screenshots and descriptions.
9. Closed testing/beta.
10. Production release.

Store requirements, fees and policies must be rechecked against Google, Apple and Steam documentation immediately before submission because they can change.
