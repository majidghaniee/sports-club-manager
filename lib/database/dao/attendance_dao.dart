import 'package:drift/drift.dart';
import '../app_database.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [AttendancesTable])
class AttendanceDao extends DatabaseAccessor<AppDatabase> with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  Stream<List<Attendance>> watchByDate(String date) =>
      (select(attendancesTable)..where((t) => t.date.equals(date))
        ..orderBy([(t) => OrderingTerm.desc(t.checkIn)])).watch();

  Stream<List<Attendance>> watchByMember(int memberId) =>
      (select(attendancesTable)..where((t) => t.memberId.equals(memberId))
        ..orderBy([(t) => OrderingTerm.desc(t.checkIn)])).watch();

  Future<int> insertAttendance(AttendancesTableCompanion e) =>
      into(attendancesTable).insert(e);

  Future<int> checkOut(int id, DateTime out) =>
      (update(attendancesTable)..where((t) => t.id.equals(id)))
          .write(AttendancesTableCompanion(checkOut: Value(out)));

  Future<Attendance?> openAttendance(int memberId, String date) =>
      (select(attendancesTable)
            ..where((t) => t.memberId.equals(memberId) &
                t.date.equals(date) & t.checkOut.isNull()))
          .getSingleOrNull();

  Future<int> deleteAttendance(int id) =>
      (delete(attendancesTable)..where((t) => t.id.equals(id))).go();

  Future<int> countForDate(String date) async {
    final c = attendancesTable.id.count();
    final q = selectOnly(attendancesTable)
      ..addColumns([c])..where(attendancesTable.date.equals(date));
    return await q.getSingle().then((r) => r.read(c) ?? 0);
  }

  Future<List<Attendance>> range(String from, String to) =>
      (select(attendancesTable)
            ..where((t) => t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerOrEqualValue(to)))
          .get();
}
