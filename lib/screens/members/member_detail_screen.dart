import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/members_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/payments_provider.dart';
import '../../providers/insurance_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/attendance_tile.dart';
import '../../widgets/payment_tile.dart';
import '../../widgets/insurance_tile.dart';

class MemberDetailScreen extends ConsumerWidget {
  final int memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('حذف عضو'),
      content: const Text('آیا از حذف این عضو مطمئن هستید؟ تمام سوابق او حذف خواهد شد؟ (سوابق مرتبط باقی می‌مانند)'),
      actions: [
        TextButton(onPressed: () => c.pop(false), child: const Text('انصراف')),
        FilledButton(onPressed: () => c.pop(true), child: const Text('حذف')),
      ],
    ));
    if (ok == true && context.mounted) {
      await ref.read(databaseProvider).membersDao.deleteMember(memberId);
      if (context.mounted) context.go('/members');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberByIdProvider(memberId));
    final attendance = ref.watch(attendanceByMemberProvider(memberId)).valueOrNull ?? [];
    final payments = ref.watch(paymentsByMemberProvider(memberId)).valueOrNull ?? [];
    final insurances = ref.watch(insuranceByMemberProvider(memberId)).valueOrNull ?? [];

    return memberAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطا: $e'))),
      data: (m) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(m.name),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/members/$memberId/edit')),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref)),
            ],
            bottom: const TabTabBar(),
          ),
          body: TabBarView(
            children: [
              // پروفایل
              ListView(padding: const EdgeInsets.all(16), children: [
                Center(
                  child: Column(children: [
                    CircleAvatar(radius: 48,
                      backgroundImage: m.photoPath != null ? NetworkImage(m.photoPath!) : null,
                      child: m.photoPath == null ? const Icon(Icons.person, size: 40) : null),
                    const SizedBox(height: 8),
                    Text(m.name, style: Theme.of(context).textTheme.titleLarge),
                    Chip(label: Text(m.sport), backgroundColor: m.isActive ? null : Theme.of(context).colorScheme.errorContainer),
                  ]),
                ),
                _infoRow('تلفن', m.phone ?? '—'),
                _infoRow('کد ملی', m.nationalId ?? '—'),
                _infoRow('تاریخ تولد', m.birthDate ?? '—'),
                _infoRow('نوع عضویت', m.membershipType),
                _infoRow('انقضای عضویت', m.membershipExpiry ?? '—'),
                _infoRow('وضعیت', m.isActive ? 'فعال' : 'غیرفعال'),
                const SizedBox(height: 24),
                Center(child: Column(children: [
                  const Text('کد QR حضورغیاب'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: QrImageView(data: 'member:${m.id}', size: 180),
                  ),
                ])),
              ]),
              // حضورغیاب
              attendance.isEmpty
                  ? const Center(child: Text('سابقه‌ای نیست'))
                  : ListView(children: attendance.map((a) => AttendanceTile(attendance: a)).toList()),
              // مالی
              payments.isEmpty
                  ? const Center(child: Text('پرداختی ثبت نشده'))
                  : ListView(children: payments.map((p) => PaymentTile(payment: p)).toList()),
              // بیمه
              insurances.isEmpty
                  ? const Center(child: Text('بیمه‌ای ثبت نشده'))
                  : ListView(children: insurances.map((i) => InsuranceTile(insurance: i)).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(value)),
    ]),
  );
}

class TabTabBar extends StatelessWidget implements PreferredSizeWidget {
  const TabTabBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => const TabBar(tabs: [
    Tab(text: 'پروفایل'),
    Tab(text: 'حضورغیاب'),
    Tab(text: 'مالی'),
    Tab(text: 'بیمه'),
  ]);
}
