import 'package:drift/drift.dart';
import '../app_database.dart';

part 'insurance_dao.g.dart';

@DriftAccessor(tables: [InsurancesTable])
class InsuranceDao extends DatabaseAccessor<AppDatabase> with _$InsuranceDaoMixin {
  InsuranceDao(super.db);

  Stream<List<Insurance>> watchAll() =>
      (select(insurancesTable)..orderBy([(t) => OrderingTerm.asc(t.endDate)])).watch();

  Stream<List<Insurance>> watchByMember(int memberId) =>
      (select(insurancesTable)..where((t) => t.memberId.equals(memberId))).watch();

  Future<int> insertInsurance(InsurancesTableCompanion e) =>
      into(insurancesTable).insert(e);
  Future<bool> updateInsurance(Insurance i) => update(insurancesTable).replace(i);
  Future<int> deleteInsurance(int id) =>
      (delete(insurancesTable)..where((t) => t.id.equals(id))).go();

  Future<List<Insurance>> all() => select(insurancesTable).get();
}
