import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import '../database/app_database.dart';
import 'database_provider.dart';

final paymentsProvider = StreamProvider.family<List<Payment>, bool?>((ref, paidOnly) =>
    ref.watch(databaseProvider).paymentsDao.watchAll(paidOnly: paidOnly));

final paymentsByMemberProvider = StreamProvider.family<List<Payment>, int>((ref, id) =>
    ref.watch(databaseProvider).paymentsDao.watchByMember(id));

final unpaidPaymentsProvider = FutureProvider<List<Payment>>(
    (ref) => ref.watch(databaseProvider).paymentsDao.unpaid());

class PaymentActions {
  final Ref ref;
  PaymentActions(this.ref);
  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> add(PaymentsTableCompanion e) => _db.paymentsDao.insertPayment(e);
  Future<void> update(Payment p) => _db.paymentsDao.updatePayment(p);
  Future<void> delete(int id) => _db.paymentsDao.deletePayment(id);
  Future<void> markPaid(int id) =>
      _db.paymentsDao.markPaid(id, toShamsiNow(), 'R-$id-${DateTime.now().millisecondsSinceEpoch % 100000}');
  String toShamsiNow() {
    final j = DateTime.now().toJalali();
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }
}

final paymentActionsProvider = Provider<PaymentActions>((ref) => PaymentActions(ref));
