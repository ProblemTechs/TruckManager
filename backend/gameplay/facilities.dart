class FacilityUpgrade {
  const FacilityUpgrade({required this.level, required this.parkingCapacity, required this.shopBays, required this.costCents});
  final int level, parkingCapacity, shopBays, costCents;
}

const facilityUpgrades = <FacilityUpgrade>[
  FacilityUpgrade(level: 1, parkingCapacity: 10, shopBays: 0, costCents: 0),
  FacilityUpgrade(level: 2, parkingCapacity: 25, shopBays: 1, costCents: 25000000),
  FacilityUpgrade(level: 3, parkingCapacity: 60, shopBays: 3, costCents: 75000000),
  FacilityUpgrade(level: 4, parkingCapacity: 125, shopBays: 6, costCents: 175000000),
  FacilityUpgrade(level: 5, parkingCapacity: 300, shopBays: 12, costCents: 400000000),
];
