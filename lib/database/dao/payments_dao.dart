import 'package:drift/drift.dart';
import '../app_database.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase> with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Stream<List<Payment>> watchAll({bool? paidOnly}) {
    final q = select(paymentsTable);
    if (paidOnly != null) q.where((t) => t.isPaid.equals(paidOnly));
    q.orderBy([(t) => OrderingTerm.desc(t.dueDate)]);
    return q.watch();
  }

  Stream<List<Payment>> watchByMember(int memberId) =>
      (select(paymentsTable)..where((t) => t.memberId.equals(memberId))
        ..orderBy([(t) => OrderingTerm.desc(t.dueDate)])).watch();

  Future<int> insertPayment(PaymentsTableCompanion e) => into(paymentsTable).insert(e);
  Future<bool> updatePayment(Payment p) => update(paymentsTable).replace(p);
  Future<int> deletePayment(int id) =>
      (delete(paymentsTable)..where((t) => t.id.equals(id))).go();

  Future<int> markPaid(int id, String payDate, String receipt) =>
      (update(paymentsTable)..where((t) => t.id.equals(id)))
          .write(PaymentsTableCompanion(
              isPaid: const Value(true), paymentDate: Value(payDate),
              receiptNumber: Value(receipt)));

  Future<List<Payment>> unpaid() =>
      (select(paymentsTable)..where((t) => t.isPaid.equals(false))).get();

  Future<List<Payment>> range(String from, String to) =>
      (select(paymentsTable)
            ..where((t) => t.dueDate.isBiggerOrEqualValue(from) &
                t.dueDate.isSmallerOrEqualValue(to)))
          .get();
}
