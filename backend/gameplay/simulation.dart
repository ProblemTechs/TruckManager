import 'models.dart';

class TripProgress {
  const TripProgress({required this.loadId, required this.totalMiles, required this.completedMiles});
  final String loadId;
  final int totalMiles, completedMiles;
  bool get delivered => completedMiles >= totalMiles;
  double get percent => totalMiles <= 0 ? 1 : (completedMiles / totalMiles).clamp(0, 1);

  TripProgress advance(int miles) => TripProgress(loadId: loadId, totalMiles: totalMiles, completedMiles: (completedMiles + miles).clamp(0, totalMiles));
}

int simulatedMilesForMinutes({required int minutes, double averageMph = 55}) => (averageMph * minutes / 60).floor();
