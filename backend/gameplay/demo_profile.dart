class DemoProfile {
  const DemoProfile({
    this.playerName = 'Player',
    this.maxPowerUnits = 5,
    this.maxCompanyLevel = 3,
    this.demo = true,
  });
  final String playerName;
  final int maxPowerUnits, maxCompanyLevel;
  final bool demo;
}

const defaultDemoProfile = DemoProfile();
