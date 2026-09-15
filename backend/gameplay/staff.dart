enum StaffRole { dispatcher, loadPlanner, safetyManager, maintenanceManager, recruiter, terminalManager }

class StaffMember {
  const StaffMember({required this.id, required this.companyId, required this.name, required this.role, required this.skill, required this.weeklyPayCents, required this.capacity});
  final String id, companyId, name;
  final StaffRole role;
  final int skill, weeklyPayCents, capacity;
}
