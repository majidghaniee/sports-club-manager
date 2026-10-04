import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';
import '../database/app_database.dart';
import '../providers/payments_provider.dart';

class PaymentTile extends ConsumerWidget {
  final Payment payment;
  const PaymentTile({super.key, required this.payment});

  bool get _overdue {
    if (payment.isPaid) return false;
    final d = _parseShamsi(payment.dueDate);
    return d != null && d.isBefore(DateTime.now());
  }

  DateTime? _parseShamsi(String s) {
    try {
      final p = s.split('/');
      return Jalali(int.parse(p[0]), int.parse(p[1]), int.parse(p[2])).toDateTime();
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final overdue = _overdue;
    final amount = intl.NumberFormat.decimalPattern().format(payment.amount);
    return Card(
      color: overdue ? cs.secondary.withOpacity(0.10) : null,
      child: ListTile(
        leading: Icon(
          payment.isPaid ? Icons.check_circle : (overdue ? Icons.warning_amber_rounded : Icons.schedule),
          color: payment.isPaid ? cs.primary : (overdue ? cs.secondary : cs.outline)),
        title: Text('$amount تومان'),
        subtitle: Text('سرسید: ${payment.dueDate}'
            '${payment.receiptNumber != null ? ' • رسید: ${payment.receiptNumber}' : ''}'),
        trailing: payment.isPaid
            ? const Icon(Icons.done_all)
            : TextButton(
                onPressed: () => ref.read(paymentActionsProvider).markPaid(payment.id),
                child: const Text('ثبت پرداخت')),
      ),
    );
  }
}
