class TripEconomics {
  const TripEconomics({required this.revenueCents, required this.fuelCents, required this.driverPayCents, required this.tollsCents, required this.maintenanceReserveCents, this.otherCents = 0});
  final int revenueCents, fuelCents, driverPayCents, tollsCents, maintenanceReserveCents, otherCents;
  int get totalCostCents => fuelCents + driverPayCents + tollsCents + maintenanceReserveCents + otherCents;
  int get profitCents => revenueCents - totalCostCents;
}

TripEconomics estimateTrip({required int miles, required int revenueCents, double mpg = 7.0, int dieselCentsPerGallon = 400, int driverPayCentsPerMile = 60, int maintenanceCentsPerMile = 18, int tollsCents = 0}) {
  final gallons = miles / mpg;
  return TripEconomics(revenueCents: revenueCents, fuelCents: (gallons * dieselCentsPerGallon).round(), driverPayCents: miles * driverPayCentsPerMile, tollsCents: tollsCents, maintenanceReserveCents: miles * maintenanceCentsPerMile);
}
