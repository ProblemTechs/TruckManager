import '../core/models.dart';

const saveSchemaVersion = 1;

Map<String, Object?> encodeCompany(CompanyState c) => {
  'schemaVersion': saveSchemaVersion,
  'id': c.id,
  'accountId': c.accountId,
  'name': c.name,
  'cashCents': c.cashCents,
  'reputation': c.reputation,
  'level': c.progression.level,
  'xp': c.progression.xp,
  'gameTimeUtc': c.simulation.gameTimeUtc.toIso8601String(),
  'speed': c.simulation.speed.name,
  'revision': c.revision,
};
