import 'package:flutter/foundation.dart';

class TruckGameState extends ChangeNotifier {
  TruckGameState({this.playerName = 'ProblemTechs'});

  String playerName;
  String companyName = 'ProblemTechs Transport';
  int cashCents = 10000000;
  int debtCents = 0;
  int creditLimitCents = 25000000;
  int companyLevel = 1;
  int companyXp = 0;
  int truckCount = 0;
  int driverCount = 0;
  int activeLoads = 0;
  bool paused = true;
  int speed = 0;

  double get cash => cashCents / 100;
  double get debt => debtCents / 100;
  double get availableCredit => (creditLimitCents - debtCents) / 100;
  bool get usedMarketAvailable => true;

  void setStartingCapital(int cents) {
    cashCents = cents;
    debtCents = 0;
    notifyListeners();
  }

  bool borrowMoney(int amountCents) {
    if (amountCents <= 0 || debtCents + amountCents > creditLimitCents) return false;
    debtCents += amountCents;
    cashCents += amountCents;
    notifyListeners();
    return true;
  }

  bool repayLoan(int amountCents) {
    if (amountCents <= 0 || cashCents < amountCents || debtCents <= 0) return false;
    final payment = amountCents > debtCents ? debtCents : amountCents;
    cashCents -= payment;
    debtCents -= payment;
    notifyListeners();
    return true;
  }

  bool purchaseStarterTruck({int priceCents = 12500000}) {
    if (cashCents < priceCents) return false;
    cashCents -= priceCents;
    truckCount++;
    notifyListeners();
    return true;
  }

  void hireDriver({int hiringCostCents = 100000}) {
    if (cashCents < hiringCostCents) return;
    cashCents -= hiringCostCents;
    driverCount++;
    notifyListeners();
  }

  bool acceptLoad() {
    if (truckCount <= activeLoads || driverCount <= activeLoads) return false;
    activeLoads++;
    notifyListeners();
    return true;
  }

  void completeLoad({int revenueCents = 250000, int xp = 100}) {
    if (activeLoads == 0) return;
    activeLoads--;
    cashCents += revenueCents;
    companyXp += xp;
    final nextLevel = 1 + companyXp ~/ 1000;
    if (nextLevel > companyLevel) companyLevel = nextLevel;
    notifyListeners();
  }

  void setSpeed(int multiplier) {
    speed = multiplier;
    paused = multiplier == 0;
    notifyListeners();
  }
}

final truckGameState = TruckGameState();
