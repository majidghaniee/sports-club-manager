import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/members_provider.dart';
import '../../widgets/attendance_tile.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late String _date = shamsiToday();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context,
        initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = toShamsi(picked));
  }

  Future<void> _manualCheckIn() async {
    final members = ref.watch(membersProvider(const MembersFilter())).valueOrNull ?? [];
    if (!mounted) return;
    final id = await showModalBottomSheet<int>(
      context: context,
      builder: (c) => SafeArea(child: ListView(
        shrinkWrap: true,
        children: [
          const Padding(padding: EdgeInsets.all(12), child: Text('انتخاب عضو برای ورود:')),
          for (final m in members)
            ListTile(title: Text(m.name), subtitle: Text(m.sport),
              onTap: () => c.pop(m.id)),
        ],
      )),
    );
    if (id != null) await ref.read(attendanceActionsProvider).checkIn(id);
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(attendanceByDateProvider(_date));
    return Scaffold(
      appBar: AppBar(
        title: Text('حضورغیاب — $_date'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/attendance/scan')),
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _pickDate),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _manualCheckIn,
        icon: const Icon(Icons.login), label: const Text('ثبت ورود')),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('برای این روز حضوری ثبت نشده است'))
            : ListView(children: items.map((a) => AttendanceTile(attendance: a, memberId: a.memberId)).toList()),
      ),
    );
  }
}
