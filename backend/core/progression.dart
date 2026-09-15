class LevelUnlock {
  const LevelUnlock({required this.level, required this.key, required this.name});
  final int level;
  final String key;
  final String name;
}

const defaultLevelUnlocks = <LevelUnlock>[
  LevelUnlock(level: 1, key: 'company_core', name: 'Company Operations'),
  LevelUnlock(level: 1, key: 'used_marketplace', name: 'Used Equipment & Parts Market'),
  LevelUnlock(level: 2, key: 'expanded_equipment', name: 'Expanded Equipment'),
  LevelUnlock(level: 3, key: 'contracts', name: 'Dedicated Contracts'),
  LevelUnlock(level: 4, key: 'facility_upgrades', name: 'Advanced Facility Upgrades'),
  LevelUnlock(level: 5, key: 'alliances', name: 'Alliances'),
  LevelUnlock(level: 6, key: 'player_marketplace', name: 'Player-to-Player Equipment Marketplace'),
  LevelUnlock(level: 10, key: 'investment_market', name: 'Truck Manager Exchange'),
];

int xpRequiredForLevel(int level) {
  if (level <= 1) return 0;
  return 1000 * (level - 1) * (level - 1);
}

Set<String> unlockedFeaturesForLevel(int level) => defaultLevelUnlocks
    .where((unlock) => level >= unlock.level)
    .map((unlock) => unlock.key)
    .toSet();
