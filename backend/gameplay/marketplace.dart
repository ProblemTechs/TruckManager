enum OfferStatus { pending, accepted, rejected, countered, expired }

class MarketOffer {
  const MarketOffer({required this.id, required this.listingId, required this.buyerCompanyId, required this.amountCents, required this.createdAtUtc, this.status = OfferStatus.pending});
  final String id, listingId, buyerCompanyId;
  final int amountCents;
  final DateTime createdAtUtc;
  final OfferStatus status;
}

bool marketplacePriceNeedsReview({required int askingPriceCents, required int estimatedMarketValueCents}) {
  if (estimatedMarketValueCents <= 0) return true;
  final ratio = askingPriceCents / estimatedMarketValueCents;
  return ratio < 0.25 || ratio > 4.0;
}
