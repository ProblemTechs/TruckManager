/// Fictional game catalogue prices, not live real-world offers.
class VehicleOffer {
  const VehicleOffer(
    this.id,
    this.name,
    this.vehicleClass,
    this.year,
    this.priceCents,
    this.mileage,
    this.conditionPercent, {
    this.used = true,
  });
  final String id, name, vehicleClass;
  final int year, priceCents, mileage, conditionPercent;
  final bool used;
}

const vehicleCatalog = [
  VehicleOffer(
    'used-pickup',
    'Used Work Pickup',
    'Pickup / Hotshot',
    2012,
    800000,
    180000,
    65,
  ),
  VehicleOffer(
    'used-van',
    'Used Cargo Van',
    'Cargo Van',
    2014,
    1200000,
    155000,
    70,
  ),
  VehicleOffer(
    'used-box',
    'Used Box Truck',
    'Box Truck',
    2015,
    2200000,
    238000,
    68,
  ),
  VehicleOffer(
    'used-daycab',
    'Used Day Cab Tractor',
    'Semi / Day Cab',
    2014,
    3200000,
    612000,
    62,
  ),
  VehicleOffer(
    'used-sleeper',
    'Used Sleeper Tractor',
    'Semi / Sleeper',
    2016,
    4500000,
    498000,
    72,
  ),
  VehicleOffer(
    'new-van',
    'New Cargo Van',
    'Cargo Van',
    2026,
    4800000,
    0,
    100,
    used: false,
  ),
  VehicleOffer(
    'new-box',
    'New Box Truck',
    'Box Truck',
    2026,
    9200000,
    0,
    100,
    used: false,
  ),
  VehicleOffer(
    'new-sleeper',
    'New Sleeper Tractor',
    'Semi / Sleeper',
    2026,
    18400000,
    0,
    100,
    used: false,
  ),
];
VehicleOffer? findVehicleOffer(String id) {
  for (final offer in vehicleCatalog) {
    if (offer.id == id) return offer;
  }
  return null;
}
