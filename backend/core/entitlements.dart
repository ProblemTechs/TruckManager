enum GameLicenseTier { free, full, pro }

class GameEntitlements {
  const GameEntitlements({
    required this.tier,
    this.freePowerUnitLimit = 5,
  });

  final GameLicenseTier tier;
  final int freePowerUnitLimit;

  bool get ownsFullGame => tier == GameLicenseTier.full || tier == GameLicenseTier.pro;
  bool get hasPro => tier == GameLicenseTier.pro;

  int? get maximumPowerUnits => ownsFullGame ? null : freePowerUnitLimit;

  bool canAddPowerUnit(int currentPowerUnits) {
    final limit = maximumPowerUnits;
    return limit == null || currentPowerUnits < limit;
  }
}

class PurchaseGuardResult {
  const PurchaseGuardResult.allowed()
      : allowed = true,
        reason = null;

  const PurchaseGuardResult.denied(this.reason) : allowed = false;

  final bool allowed;
  final String? reason;
}

PurchaseGuardResult validatePowerUnitPurchase({
  required GameEntitlements entitlements,
  required int currentPowerUnits,
}) {
  if (entitlements.canAddPowerUnit(currentPowerUnits)) {
    return const PurchaseGuardResult.allowed();
  }

  return PurchaseGuardResult.denied(
    'Truck Manager Free supports up to ${entitlements.freePowerUnitLimit} power units. Upgrade to the Full Game to expand the fleet.',
  );
}
