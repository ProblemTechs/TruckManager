enum InspectionResult { pass, warning, violation, outOfService }

class DotInspection {
  const DotInspection({required this.id, required this.truckId, required this.driverId, required this.occurredAtUtc, required this.result, this.notes = ''});
  final String id, truckId, driverId, notes;
  final DateTime occurredAtUtc;
  final InspectionResult result;
}

double safetyScoreImpact(InspectionResult result) => switch (result) { InspectionResult.pass => 0.2, InspectionResult.warning => -0.5, InspectionResult.violation => -2.0, InspectionResult.outOfService => -5.0 };
