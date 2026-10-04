import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'dao/members_dao.dart';
import 'dao/attendance_dao.dart';
import 'dao/payments_dao.dart';
import 'dao/insurance_dao.dart';

part 'app_database.g.dart';

class MembersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get birthDate => text().nullable()();       // تاریخ شمسی YYYY/MM/DD
  TextColumn get sport => text().withDefault(const Constant('عمومی'))();
  TextColumn get membershipType => text().withDefault(const Constant('عادی'))();
  TextColumn get membershipExpiry => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AttendancesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().references(MembersTable, #id)();
  DateTimeColumn get checkIn => dateTime()();
  DateTimeColumn get checkOut => dateTime().nullable()();
  TextColumn get date => text()(); // YYYY/MM/DD شمسی
  TextColumn get note => text().nullable()();
}

class PaymentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().references(MembersTable, #id)();
  RealColumn get amount => real()();
  TextColumn get paymentDate => text().nullable()();
  TextColumn get dueDate => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  TextColumn get receiptNumber => text().nullable()();
}

class InsurancesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get memberId => integer().references(MembersTable, #id)();
  TextColumn get insuranceNumber => text()();
  TextColumn get provider => text()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [MembersTable, AttendancesTable, PaymentsTable, InsurancesTable],
    daos: [MembersDao, AttendanceDao, PaymentsDao, InsuranceDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(name: 'sports_club');
}
