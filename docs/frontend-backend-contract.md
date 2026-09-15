# Truck Manager Frontend → Backend Contract

The Flutter frontend is designed around a management-only v1. Driver Mode is deferred.

## Backend domains expected

- Company: identity, cash, reputation, economy difficulty, progression.
- Simulation clock: pause, 1x, 2x, 5x, 10x, critical-event pause.
- Fleet: permanent ID, editable unit number/name, equipment class/specs, mileage, fuel, condition, maintenance, terminal, driver assignment, level, lifetime economics.
- Drivers: permanent ID, CDL, endorsements, medical card, HOS/duty status, qualifications, mileage, safety, level, truck/team assignment.
- Loads: origin/destination, cargo, equipment requirements, appointments, mileage, rate, costs, projected/actual profit, status.
- Dispatch: AUTO/STAFF/MANUAL, compatibility checks, HOS, deadhead, rate/mile, fuel, future market and staff skill.
- Team operations: automatic legal driver switching and rest tracking.
- Terminals/facilities: ownership/lease, capacity, parking, shops, fuel, staff, upgrades and regional assignment.
- Staff: dispatcher, load planner, safety, maintenance, recruiting and management roles with skill/capacity.
- Safety: DQ files, medical expiration, CDL/endorsement status, training, DOT inspections, violations, accidents, HOS and out-of-service events.
- Maintenance: PM schedules, defects, repairs, breakdowns, shop queue, roadside/tow/swap decisions.
- Customers/contracts: spot freight, dedicated agreements, commitments, service targets, reputation and renewal/loss.
- Finance: revenue, payroll, fuel, maintenance, insurance, debt, property, tolls, taxes, permits, fines, cost/mile and operating ratio.
- Alerts/events: INFO, ATTENTION, IMPORTANT, CRITICAL with actions and optional staff delegation.
- Reports: profitability/utilization/safety by company, region, terminal, division, fleet, truck and driver.

## Frontend actions requiring backend commands

createCompany, setSimulationSpeed, purchaseVehicle, leaseVehicle, hireEmployee, terminateEmployee, assignDriver, assignTeamDriver, setDispatchMode, acceptLoad, assignLoad, acceptContract, declineContract, purchaseTerminal, leaseTerminal, upgradeFacility, scheduleMaintenance, authorizeRepair, transferLoad, renewMedicalCard, scheduleTraining, resolveSafetyEvent, saveGame, loadGame.

## Backend event stream expected

simulationTick, truckMoved, loadStatusChanged, driverDutyChanged, teamDriverSwitched, hosWarning, maintenanceDue, breakdownOccurred, inspectionOccurred, safetyViolation, medicalCardWarning, contractOffered, terminalUpdated, financeUpdated, criticalAlert.

## Frontend completion state

Core v1 screens and action surfaces are represented: company setup, dashboard, U.S. operations map, dispatch, loads, fleet, drivers, terminals, staff, safety, maintenance, customers/contracts, finance, reports, alerts, settings and company action workflows. Mock data should be replaced by backend state without changing the primary navigation or visual system.
