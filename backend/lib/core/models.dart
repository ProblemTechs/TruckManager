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
  CompanyState({
    required this.id,
    required this.accountId,
    required this.name,
    required this.cashCents,
    required this.reputation,
    required this.progression,
    required this.simulation,
    required this.revision,
    this.debtCents = 0,
    this.startingCity = 'Dallas, TX',
    List<FleetVehicle> fleet = const [],
    List<CompanyDriver> drivers = const [],
    List<CompanyLoad> loads = const [],
  }) : fleet = List.unmodifiable(fleet),
       drivers = List.unmodifiable(drivers),
       loads = List.unmodifiable(loads);
  final String id, accountId, name, startingCity;
  final int cashCents, revision, debtCents;
  final double reputation;
  final CompanyProgression progression;
  final SimulationClock simulation;
  final List<FleetVehicle> fleet;
  final List<CompanyDriver> drivers;
  final List<CompanyLoad> loads;
  int get truckCount => fleet.length;
  int get driverCount => drivers.length;
  int get activeLoads => loads.where((l) => !l.delivered).length;

  CompanyState copyWith({
    int? cashCents,
    int? debtCents,
    List<FleetVehicle>? fleet,
    List<CompanyDriver>? drivers,
    List<CompanyLoad>? loads,
    CompanyProgression? progression,
    SimulationClock? simulation,
  }) => CompanyState(
    id: id,
    accountId: accountId,
    name: name,
    startingCity: startingCity,
    cashCents: cashCents ?? this.cashCents,
    reputation: reputation,
    progression: progression ?? this.progression,
    simulation: simulation ?? this.simulation,
    revision: revision + 1,
    debtCents: debtCents ?? this.debtCents,
    fleet: fleet ?? this.fleet,
    drivers: drivers ?? this.drivers,
    loads: loads ?? this.loads,
  );
}

class FleetVehicle {
  const FleetVehicle({
    required this.id,
    required this.unitNumber,
    required this.catalogId,
    required this.name,
    required this.vehicleClass,
    required this.used,
    required this.year,
    required this.purchasePriceCents,
    required this.mileage,
    required this.conditionPercent,
    required this.city,
    required this.latitude,
    required this.longitude,
  });
  final String id, unitNumber, catalogId, name, vehicleClass, city;
  final bool used;
  final int year, purchasePriceCents, mileage, conditionPercent;
  final double latitude, longitude;
  FleetVehicle movedTo(GameCity destination, int miles) => FleetVehicle(
    id: id,
    unitNumber: unitNumber,
    catalogId: catalogId,
    name: name,
    vehicleClass: vehicleClass,
    used: used,
    year: year,
    purchasePriceCents: purchasePriceCents,
    mileage: mileage + miles,
    conditionPercent: conditionPercent,
    city: destination.name,
    latitude: destination.latitude,
    longitude: destination.longitude,
  );
}

class CompanyDriver {
  const CompanyDriver({
    required this.id,
    required this.name,
    this.truckId,
    this.milesDriven = 0,
    this.cdlClass = 'Class A',
  });
  final String id, name, cdlClass;
  final String? truckId;
  final int milesDriven;
  CompanyDriver assignedTo(String? id) => CompanyDriver(
    id: this.id,
    name: name,
    truckId: id,
    milesDriven: milesDriven,
    cdlClass: cdlClass,
  );
  CompanyDriver addMiles(int miles) => CompanyDriver(
    id: id,
    name: name,
    truckId: truckId,
    milesDriven: milesDriven + miles,
    cdlClass: cdlClass,
  );
}

class CompanyLoad {
  const CompanyLoad({
    required this.id,
    required this.truckId,
    required this.driverId,
    required this.origin,
    required this.destination,
    this.delivered = false,
    this.miles = 263,
    this.revenueCents = 250000,
  });
  final String id, truckId, driverId, origin, destination;
  final bool delivered;
  final int miles, revenueCents;
  CompanyLoad complete() => CompanyLoad(
    id: id,
    truckId: truckId,
    driverId: driverId,
    origin: origin,
    destination: destination,
    delivered: true,
    miles: miles,
    revenueCents: revenueCents,
  );
}

class GameCity {
  const GameCity(this.name, this.latitude, this.longitude);
  final String name;
  final double latitude, longitude;
}

const gameCities = [
  GameCity('Dallas, TX', 32.7767, -96.7970),
  GameCity('Atlanta, GA', 33.7490, -84.3880),
  GameCity('Chicago, IL', 41.8781, -87.6298),
  GameCity('Denver, CO', 39.7392, -104.9903),
  GameCity('Phoenix, AZ', 33.4484, -112.0740),
  GameCity('Los Angeles, CA', 34.0522, -118.2437),
  GameCity('Newark, NJ', 40.7357, -74.1724),
  GameCity('Tulsa, OK', 36.1540, -95.9928),
];
GameCity? findGameCity(String name) {
  for (final city in gameCities) {
    if (city.name == name) return city;
  }
  return null;
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
