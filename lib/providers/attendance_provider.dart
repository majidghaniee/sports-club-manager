import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:shamsi_date/shamsi_date.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

String shamsiToday() {
  final j = Jalali.now();
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

String toShamsi(DateTime d) {
  final j = d.toJalali();
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

final attendanceByDateProvider = StreamProvider.family<List<Attendance>, String>((ref, date) =>
    ref.watch(databaseProvider).attendanceDao.watchByDate(date));

final attendanceByMemberProvider = StreamProvider.family<List<Attendance>, int>((ref, id) =>
    ref.watch(databaseProvider).attendanceDao.watchByMember(id));

final todayAttendanceCountProvider = StreamProvider<int>((ref) async* {
  final db = ref.watch(databaseProvider);
  final dao = db.attendanceDao;
  yield* db.membersDao.watchTotalCount().asyncMap((_) => dao.countForDate(shamsiToday()));
});

class AttendanceActions {
  final Ref ref;
  AttendanceActions(this.ref);
  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> checkIn(int memberId, {String? note}) async {
    final date = shamsiToday();
    await _db.attendanceDao.insertAttendance(AttendancesTableCompanion(
      memberId: Value(memberId),
      checkIn: Value(DateTime.now()),
      date: Value(date),
      note: Value(note),
    ));
  }

  Future<void> checkOut(Attendance a) async {
    await _db.attendanceDao.checkOut(a.id, DateTime.now());
  }
}

final attendanceActionsProvider = Provider<AttendanceActions>((ref) => AttendanceActions(ref));
