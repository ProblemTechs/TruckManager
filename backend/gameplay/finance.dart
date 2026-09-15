class FinanceLedgerEntry {
  const FinanceLedgerEntry({required this.id, required this.companyId, required this.amountCents, required this.category, required this.description, required this.gameTimeUtc});
  final String id, companyId, category, description;
  final int amountCents;
  final DateTime gameTimeUtc;
}

class FinanceSummary {
  const FinanceSummary(this.entries);
  final List<FinanceLedgerEntry> entries;
  int get revenueCents => entries.where((e) => e.amountCents > 0).fold(0, (a, e) => a + e.amountCents);
  int get expenseCents => -entries.where((e) => e.amountCents < 0).fold(0, (a, e) => a + e.amountCents);
  int get profitCents => entries.fold(0, (a, e) => a + e.amountCents);
  double get operatingRatio => revenueCents == 0 ? 0 : expenseCents / revenueCents;
}
