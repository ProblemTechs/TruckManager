enum ContractStatus { offered, active, completed, failed, declined }

class CustomerContract {
  const CustomerContract({required this.id, required this.customerName, required this.originRegion, required this.destinationRegion, required this.loadsRequired, required this.ratePerLoadCents, required this.serviceTargetPercent, required this.status});
  final String id, customerName, originRegion, destinationRegion;
  final int loadsRequired, ratePerLoadCents;
  final double serviceTargetPercent;
  final ContractStatus status;
}
