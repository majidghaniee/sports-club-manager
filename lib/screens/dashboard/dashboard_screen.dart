import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../providers/members_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/payments_provider.dart';
import '../../providers/insurance_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(clubSettingsProvider);
    final total = ref.watch(totalMembersProvider).valueOrNull ?? 0;
    final todayAtt = ref.watch(todayAttendanceCountProvider).valueOrNull ?? 0;
    final unpaid = ref.watch(unpaidPaymentsProvider).valueOrNull?.length ?? 0;
    final insurances = ref.watch(insurancesProvider).valueOrNull ?? [];
    final expiring = insurances
        .where((i) => insuranceStatus(i.endDate) != InsuranceStatus.valid)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(settings.clubName)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            padding: const EdgeInsets.all(12),
            children: [
              StatCard(title: 'کل اعضا', value: '$total', icon: Icons.groups, onTap: () => context.go('/members')),
              StatCard(title: 'حضور امروز', value: '$todayAtt', icon: Icons.fact_check, onTap: () => context.go('/attendance')),
              StatCard(title: 'پرداخت‌های معوق', value: '$unpaid', icon: Icons.account_balance_wallet, warn: unpaid > 0, onTap: () => context.go('/payments')),
              StatCard(title: 'بیمه‌های نیازمند تمدید', value: '$expiring', icon: Icons.health_and_safety, warn: expiring > 0, onTap: () => context.go('/insurance')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('دسترسی سریع', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.add_person),
            title: const Text('افزودن عضو جدید'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/members/add'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('ثبت حضور با QR'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/attendance/scan'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('ثبت پرداخت'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/payments/add'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('تنظیمات باشگاه'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
