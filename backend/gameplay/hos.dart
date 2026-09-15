import 'models.dart';

class HosClock {
  const HosClock({this.drivingMinutes = 0, this.onDutyMinutes = 0, this.cycleMinutes = 0, this.breakMinutes = 0});
  final int drivingMinutes, onDutyMinutes, cycleMinutes, breakMinutes;
  int get driveRemaining => (11 * 60 - drivingMinutes).clamp(0, 11 * 60);
  int get dutyRemaining => (14 * 60 - onDutyMinutes).clamp(0, 14 * 60);
  bool get breakRequired => drivingMinutes >= 8 * 60 && breakMinutes < 30;
  bool get canDrive => driveRemaining > 0 && dutyRemaining > 0 && !breakRequired;
}

class TeamAssignment {
  const TeamAssignment({required this.primaryDriverId, required this.secondaryDriverId, required this.activeDriverId});
  final String primaryDriverId, secondaryDriverId, activeDriverId;
  String switchDriver() => activeDriverId == primaryDriverId ? secondaryDriverId : primaryDriverId;
}
