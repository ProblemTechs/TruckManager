enum VehicleClass { pickup, van, boxTruck, semi }
enum DriverDutyStatus { offDuty, sleeper, driving, onDuty }
enum LoadStatus { available, accepted, assigned, inTransit, delivered, cancelled }
enum MaintenanceStatus { due, scheduled, inProgress, complete }
enum SafetySeverity { info, attention, important, critical }

class Truck {
  const Truck({required this.id, required this.companyId, required this.unitNumber, required this.vehicleClass, required this.mileage, required this.conditionPercent, required this.fuelPercent, this.driverId, this.terminalId, this.level = 1});
  final String id, companyId, unitNumber;
  final VehicleClass vehicleClass;
  final int mileage, level;
  final double conditionPercent, fuelPercent;
  final String? driverId, terminalId;
}

class Driver {
  const Driver({required this.id, required this.companyId, required this.name, required this.cdlClass, required this.endorsements, required this.medicalCardExpiresUtc, required this.dutyStatus, required this.milesDriven, this.truckId, this.teamDriverId, this.level = 1});
  final String id, companyId, name, cdlClass;
  final Set<String> endorsements;
  final DateTime medicalCardExpiresUtc;
  final DriverDutyStatus dutyStatus;
  final int milesDriven, level;
  final String? truckId, teamDriverId;
}

class FreightLoad {
  const FreightLoad({required this.id, required this.origin, required this.destination, required this.cargo, required this.miles, required this.rateCents, required this.pickupUtc, required this.deliveryUtc, required this.status, this.requiredEndorsement, this.truckId, this.driverId});
  final String id, origin, destination, cargo;
  final int miles, rateCents;
  final DateTime pickupUtc, deliveryUtc;
  final LoadStatus status;
  final String? requiredEndorsement, truckId, driverId;
}

class Terminal {
  const Terminal({required this.id, required this.companyId, required this.name, required this.city, required this.state, required this.level, required this.parkingCapacity, required this.shopBays});
  final String id, companyId, name, city, state;
  final int level, parkingCapacity, shopBays;
}

class MaintenanceJob {
  const MaintenanceJob({required this.id, required this.assetId, required this.description, required this.estimatedCostCents, required this.status});
  final String id, assetId, description;
  final int estimatedCostCents;
  final MaintenanceStatus status;
}

class SafetyEvent {
  const SafetyEvent({required this.id, required this.companyId, required this.description, required this.severity, required this.occurredAtUtc, this.driverId, this.truckId});
  final String id, companyId, description;
  final SafetySeverity severity;
  final DateTime occurredAtUtc;
  final String? driverId, truckId;
}
