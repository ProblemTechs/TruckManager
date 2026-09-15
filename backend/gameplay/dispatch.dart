import 'models.dart';

class DispatchDecision {
  const DispatchDecision(this.allowed, {this.reason});
  final bool allowed;
  final String? reason;
}

DispatchDecision validateAssignment({required FreightLoad load, required Truck truck, required Driver driver, required DateTime gameTimeUtc}) {
  if (truck.driverId != null && truck.driverId != driver.id) return const DispatchDecision(false, reason: 'Truck is assigned to another driver.');
  if (driver.truckId != null && driver.truckId != truck.id) return const DispatchDecision(false, reason: 'Driver is assigned to another truck.');
  if (driver.medicalCardExpiresUtc.isBefore(gameTimeUtc)) return const DispatchDecision(false, reason: 'Driver medical card is expired.');
  if (load.requiredEndorsement != null && !driver.endorsements.contains(load.requiredEndorsement)) return const DispatchDecision(false, reason: 'Driver lacks required endorsement.');
  if (driver.dutyStatus == DriverDutyStatus.driving) return const DispatchDecision(false, reason: 'Driver is already driving.');
  if (truck.conditionPercent <= 20) return const DispatchDecision(false, reason: 'Truck condition is too low for dispatch.');
  return const DispatchDecision(true);
}
