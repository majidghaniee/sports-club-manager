import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:shamsi_date/shamsi_date.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

final insurancesProvider = StreamProvider<List<Insurance>>(
    (ref) => ref.watch(databaseProvider).insuranceDao.watchAll());

final insuranceByMemberProvider = StreamProvider.family<List<Insurance>, int>((ref, id) =>
    ref.watch(databaseProvider).insuranceDao.watchByMember(id));

/// پایان بیمه به شمسی ذخیره می‌شود؛ برای مقایسه به میلادی تبدیل می‌کنیم
DateTime? parseShamsi(String? s) {
  if (s == null || s.length < 8) return null;
  try {
    final p = s.split('/');
    final j = Jalali(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    return j.toDateTime();
  } catch (_) {
    return null;
  }
}

int daysUntil(String? shamsiEnd) {
  final d = parseShamsi(shamsiEnd);
  if (d == null) return 9999;
  return d.difference(DateTime.now()).inDays;
}

/// true: منقضی، false: به‌زودی منقضی (<=30 روز)، null: سالم
InsuranceStatus insuranceStatus(String? endDate) {
  final days = daysUntil(endDate);
  if (days < 0) return InsuranceStatus.expired;
  if (days <= 30) return InsuranceStatus.expiringSoon;
  return InsuranceStatus.valid;
}

enum InsuranceStatus { valid, expiringSoon, expired }

class InsuranceActions {
  final Ref ref;
  InsuranceActions(this.ref);
  AppDatabase get _db => ref.read(databaseProvider);
  Future<void> add(InsurancesTableCompanion e) => _db.insuranceDao.insertInsurance(e);
  Future<void> update(Insurance i) => _db.insuranceDao.updateInsurance(i);
  Future<void> delete(int id) => _db.insuranceDao.deleteInsurance(id);
}

final insuranceActionsProvider = Provider<InsuranceActions>((ref) => InsuranceActions(ref));
