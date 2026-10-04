import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/insurance_provider.dart';
import '../../widgets/insurance_tile.dart';

class InsuranceScreen extends ConsumerWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(insurancesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت بیمه')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/insurance/add'),
        icon: const Icon(Icons.add), label: const Text('بیمه جدید')),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('بیمه‌ای ثبت نشده است'))
            : ListView(children: list.map((i) => InsuranceTile(insurance: i)).toList()),
      ),
    );
  }
}
