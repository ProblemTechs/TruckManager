class RestorationQuote {
  const RestorationQuote({required this.assetId, required this.partsCostCents, required this.laborCostCents, required this.days, required this.resultingConditionPercent});
  final String assetId;
  final int partsCostCents, laborCostCents, days;
  final double resultingConditionPercent;
  int get totalCents => partsCostCents + laborCostCents;
}

RestorationQuote quoteRestoration({required String assetId, required double currentConditionPercent, required int shopLevel}) {
  final target = 95.0;
  final missing = (target - currentConditionPercent).clamp(0.0, 95.0);
  final efficiency = 1 + shopLevel * .08;
  return RestorationQuote(assetId: assetId, partsCostCents: (missing * 9000 / efficiency).round(), laborCostCents: (missing * 4500 / efficiency).round(), days: (missing / (5 + shopLevel)).ceil(), resultingConditionPercent: target);
}
