enum SimulationSpeed { paused, x1, x2, x5, x10 }

enum FeedbackCategory {
  bug,
  gameplaySuggestion,
  featureRequest,
  balanceEconomy,
  uiUx,
  other,
}

enum MarketplaceListingType { fixedPrice, offers, auction }

enum EquipmentType { truck, trailer, engine, transmission, axle, otherPart }

class PlayerAccount {
  const PlayerAccount({
    required this.id,
    required this.displayName,
    required this.preferredTimeZone,
    required this.createdAtUtc,
  });

  final String id;
  final String displayName;
  final String preferredTimeZone;
  final DateTime createdAtUtc;
}

class SimulationClock {
  const SimulationClock({
    required this.gameTimeUtc,
    this.speed = SimulationSpeed.paused,
    this.criticalEventPauseEnabled = true,
  });

  final DateTime gameTimeUtc;
  final SimulationSpeed speed;
  final bool criticalEventPauseEnabled;

  SimulationClock copyWith({DateTime? gameTimeUtc, SimulationSpeed? speed}) =>
      SimulationClock(
        gameTimeUtc: gameTimeUtc ?? this.gameTimeUtc,
        speed: speed ?? this.speed,
        criticalEventPauseEnabled: criticalEventPauseEnabled,
      );
}

class CompanyProgression {
  const CompanyProgression({required this.level, required this.xp});
  final int level;
  final int xp;

  bool get alliancesUnlocked => level >= 5;
  bool get usedMarketplaceUnlocked => level >= 6;
  bool get investmentMarketUnlocked => level >= 10;
}

class CompanyState {
  const CompanyState({
    required this.id,
    required this.accountId,
    required this.name,
    required this.cashCents,
    required this.reputation,
    required this.progression,
    required this.simulation,
    required this.revision,
  });

  final String id;
  final String accountId;
  final String name;
  final int cashCents;
  final double reputation;
  final CompanyProgression progression;
  final SimulationClock simulation;
  final int revision;
}

class EquipmentComponent {
  const EquipmentComponent({
    required this.id,
    required this.type,
    required this.conditionPercent,
    this.mileage = 0,
    this.engineHours = 0,
  });

  final String id;
  final EquipmentType type;
  final double conditionPercent;
  final int mileage;
  final int engineHours;
}

class EquipmentAsset {
  const EquipmentAsset({
    required this.id,
    required this.ownerCompanyId,
    required this.type,
    required this.year,
    required this.make,
    required this.model,
    required this.conditionPercent,
    required this.components,
    this.unitNumber,
    this.mileage = 0,
  });

  final String id;
  final String ownerCompanyId;
  final EquipmentType type;
  final int year;
  final String make;
  final String model;
  final String? unitNumber;
  final int mileage;
  final double conditionPercent;
  final List<EquipmentComponent> components;
}

class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.sellerCompanyId,
    required this.assetId,
    required this.type,
    required this.askingPriceCents,
    required this.createdAtUtc,
    this.auctionEndsAtUtc,
  });

  final String id;
  final String sellerCompanyId;
  final String assetId;
  final MarketplaceListingType type;
  final int askingPriceCents;
  final DateTime createdAtUtc;
  final DateTime? auctionEndsAtUtc;
}

class GameCommand {
  const GameCommand({
    required this.commandId,
    required this.accountId,
    required this.companyId,
    required this.deviceId,
    required this.expectedRevision,
    required this.type,
    required this.issuedAtUtc,
    this.payload = const {},
  });

  final String commandId;
  final String accountId;
  final String companyId;
  final String deviceId;
  final int expectedRevision;
  final String type;
  final DateTime issuedAtUtc;
  final Map<String, Object?> payload;
}

class GameEvent {
  const GameEvent({
    required this.eventId,
    required this.companyId,
    required this.revision,
    required this.type,
    required this.gameTimeUtc,
    this.payload = const {},
  });

  final String eventId;
  final String companyId;
  final int revision;
  final String type;
  final DateTime gameTimeUtc;
  final Map<String, Object?> payload;
}
