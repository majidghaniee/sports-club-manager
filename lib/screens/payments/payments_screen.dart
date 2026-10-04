import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/payments_provider.dart';
import '../../widgets/payment_tile.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});
  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool? _paidFilter;

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentsProvider(_paidFilter));
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت مالی')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/add'),
        icon: const Icon(Icons.add), label: const Text('پرداخت جدید')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ChoiceChip(label: const Text('همه'), selected: _paidFilter == null,
              onSelected: (_) => setState(() => _paidFilter = null)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('پرداخت‌شده'), selected: _paidFilter == true,
              onSelected: (_) => setState(() => _paidFilter = true)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('پرداخت‌نشده'), selected: _paidFilter == false,
              onSelected: (_) => setState(() => _paidFilter = false)),
          ]),
        ),
        Expanded(
          child: payments.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطا: $e')),
            data: (items) => items.isEmpty
                ? const Center(child: Text('پرداختی ثبت نشده است'))
                : ListView(children: items.map((p) => PaymentTile(payment: p)).toList()),
          ),
        ),
      ]),
    );
  }
}
