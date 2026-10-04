import 'package:drift/drift.dart';
import '../app_database.dart';

part 'members_dao.g.dart';

@DriftAccessor(tables: [MembersTable])
class MembersDao extends DatabaseAccessor<AppDatabase> with _$MembersDaoMixin {
  MembersDao(super.db);

  Stream<List<Member>> watchAll({String? search, String? sport, bool? activeOnly}) {
    final query = select(membersTable);
    if (search != null && search.trim().isNotEmpty) {
      query.where((t) => t.name.like('%${search.trim()}%'));
    }
    if (sport != null && sport != 'همه') {
      query.where((t) => t.sport.equals(sport));
    }
    if (activeOnly == true) query.where((t) => t.isActive.equals(true));
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  Future<Member> getById(int id) =>
      (select(membersTable)..where((t) => t.id.equals(id))).getSingle();

  Stream<Member> watchById(int id) =>
      (select(membersTable)..where((t) => t.id.equals(id))).watchSingle();

  Future<int> insertMember(MembersTableCompanion e) => into(membersTable).insert(e);
  Future<bool> updateMember(Member m) => update(membersTable).replace(m);
  Future<int> deleteMember(int id) =>
      (delete(membersTable)..where((t) => t.id.equals(id))).go();

  Stream<int> watchTotalCount() {
    final c = membersTable.id.count();
    final q = selectOnly(membersTable)..addColumns([c]);
    return q.map((row) => row.read(c) ?? 0).watchSingle();
  }
}
